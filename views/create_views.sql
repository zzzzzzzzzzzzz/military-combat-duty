CREATE OR REPLACE VIEW personnel_info AS
SELECT
	p_id,
	surname,
	name,
	patronymic,
	shortname,
	description
FROM
	personnel
INNER JOIN
	personnel_status
ON personnel.status = personnel_status.id;


CREATE OR REPLACE VIEW group_info AS
SELECT
	gr_id,
	array_agg(full_name) as brief
FROM
	(SELECT
		gr_id,
		CASE WHEN is_commander=TRUE 
			THEN CONCAT(personnel.p_id::text, ':', 'КОМАНДИР:', surname, ' ', name, ' ', patronymic)
			ELSE CONCAT(personnel.p_id::text, ':', surname, ' ', name, ' ', patronymic)
		END as full_name
	FROM
		groups_personnel
	INNER JOIN
		personnel
	ON personnel.p_id = groups_personnel.p_id) as x
GROUP BY gr_id
ORDER BY gr_id;


CREATE OR REPLACE VIEW inventory_info AS
SELECT
	name,
	range,
	n_persons,
	serial_number,
	active
FROM
	inventory
INNER JOIN
	radar_station
ON inventory.rs_name = radar_station.name
ORDER BY name;


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


CREATE OR REPLACE VIEW inventory_usage AS
SELECT
	serial_number,
	equipment_usage,
	rs_name
FROM
	(SELECT 
		serial_number,
		CASE WHEN usage IS NULL THEN 0 ELSE usage END as equipment_usage,
		rs_name
	FROM
		inventory
	LEFT OUTER JOIN
		(
		SELECT equipment, COUNT(*) as usage FROM duty_groups_log GROUP BY equipment
		) as x
	ON
		inventory.serial_number = x.equipment) as pre_final
ORDER BY equipment_usage DESC;

