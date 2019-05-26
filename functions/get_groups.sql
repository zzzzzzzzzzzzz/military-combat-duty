DROP FUNCTION IF EXISTS get_groups(ForTime TIMESTAMP WITH TIME ZONE, RelaxDaysLimit INTEGER);
-- Функция получает список расчётов, которые будут дежурить на дату ForTime с учётом положенного отдыха RelaxDaysLimit
-- Она приоретизирует покрытие территории (просто по сумме range), то как давно использовалась техника, и то как давно на этой технике работал каждый расчёт
-- Таким образом достигается а) максимальное покрытие территории, б) соблюдается режим отыдха, в) используется вся доступная работающая техника
-- ЗАМЕЧАНИЕ: 
-- функция не пытается подстроиться под график 1 через 2, она пытается задействовать все возможные расчёты, проверяя ограничения.
-- Важна инициализация таблицы duty_groups_log. Можно задать её так, что график 1 через 2 будет выполняться автоматически.
-- В данной демонстрации (fill_tables.sql) именно так и сделано.
CREATE OR REPLACE FUNCTION get_groups(ForTime TIMESTAMP WITH TIME ZONE, RelaxDaysLimit INTEGER) 
 RETURNS TABLE (
 d_start TIMESTAMP,
 d_end TIMESTAMP,
 g_id INTEGER,
 s_number INTEGER
) AS $$
DECLARE 
    var_r record;
    buffer INTEGER[];
    elem INTEGER;
BEGIN
d_start := ForTime;
d_end := ForTime + INTERVAL '1 DAY';
 FOR var_r IN(
SELECT
	--serial_number,
	--rs_name,
	--range,
	--array_agg(gr_id ORDER BY gr_id ASC) as gr_ids
	gr_id,
	array_agg(serial_number ORDER BY serial_number ASC) as serial_numbers
FROM
	(SELECT
		serial_number,
		rs_name,
		range,
		gr_id,
		DENSE_RANK() OVER (PARTITION BY serial_number, rs_name ORDER BY range DESC, last_duty_rank DESC, equipment_last_duty_rank DESC, equipment_global_rank DESC) as priority
	FROM
		(SELECT 
			serial_number,
			rs_name,
			range,
			gr_id,
			MIN(since_last_duty_days) OVER (PARTITION BY gr_id) AS last_duty_days_for_group,
			DENSE_RANK() OVER (ORDER BY equipment_last_duty_days ASC) as equipment_global_rank,
			DENSE_RANK() OVER (PARTITION BY gr_id ORDER BY equipment_last_duty_days ASC) as equipment_last_duty_rank,
			DENSE_RANK() OVER (ORDER BY since_last_duty_days ASC) as last_duty_rank
		FROM
			(SELECT
				serial_number,
				rs_name,
				range,
				joined_with_log.gr_id,
				CASE WHEN equipment IS NULL THEN 1000 ELSE since_last_duty_days END as equipment_last_duty_days,
				CASE WHEN since_last_duty_days IS NULL THEN 1000 ELSE since_last_duty_days END as since_last_duty_days 
			FROM
				(SELECT 
					serial_number,
					rs_name,
					range,
					n_persons,
					x.gr_id,
					equipment,
					since_last_duty_days
				FROM
					(SELECT
						serial_number,
						rs_name,
						range,
						n_persons,
						gr_id
					FROM
						(SELECT 
							serial_number,
							rs_name,
							range,
							n_persons 
						FROM 
							inventory as a
							INNER JOIN
							radar_station as b
							ON  a.rs_name = b.name
						WHERE 
							active=TRUE) as rs

					INNER JOIN
						duty_groups
					ON rs.rs_name = duty_groups.for_station
					ORDER BY range DESC) as x

				LEFT OUTER JOIN

					(SELECT
						gr_id,
						equipment,
						MIN(DATE_PART('DAY', ForTime - duty_end)) OVER (PARTITION BY gr_id, equipment) as since_last_duty_days
					FROM
						duty_groups_log
					WHERE duty_end > ForTime - INTERVAL '7 DAY') as y

				ON x.gr_id = y.gr_id AND x.serial_number = y.equipment) as joined_with_log

			INNER JOIN

				(SELECT
					gr_id,
					COUNT(*) as onboard
				FROM
					groups_personnel
				GROUP BY 
					gr_id
				) as people_in_groups

			ON joined_with_log.gr_id = people_in_groups.gr_id
			WHERE n_persons - onboard = 0)as source) as dense
	WHERE last_duty_days_for_group >= RelaxDaysLimit
	) as pre_final
WHERE priority = 1
GROUP BY gr_id
 )  
 LOOP
        g_id := var_r.gr_id; 
	FOREACH elem IN ARRAY var_r.serial_numbers
	LOOP
		IF (NOT (buffer @> ARRAY[elem::int]) OR buffer IS NULL) THEN
			s_number := elem;
			EXIT;
		END IF;
	END LOOP;
	buffer := array_append(buffer, s_number);
        RETURN NEXT;
 END LOOP;
END; $$ 
LANGUAGE 'plpgsql';


