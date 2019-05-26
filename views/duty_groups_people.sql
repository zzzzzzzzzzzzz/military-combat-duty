-- Для каждого дежурного расчёта выводит информацию о том сколько людей необходимо, а сколько имеется,
-- а также назначен ли в группе командир 
CREATE OR REPLACE VIEW duty_groups_people AS
SELECT
	duty_groups.gr_id,
	radar_station.n_persons as "Потребное кол-во людей",
	onboard as "Имеющееся кол-во людей",
	commander as "Назначен ли командир"
FROM
	duty_groups
INNER JOIN
	radar_station
ON 
	duty_groups.for_station = radar_station.name
INNER JOIN
	(SELECT 
		gr_id, 
		COUNT(p_id) as onboard,
		bool_or(is_commander) as commander
	 FROM
		groups_personnel
	 GROUP BY gr_id) as cnt
ON
	duty_groups.gr_id = cnt.gr_id;
	
SELECT * FROM duty_groups_people;
