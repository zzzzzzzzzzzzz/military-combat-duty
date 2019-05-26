-- Показывает сколько раз использовалась в дежурстве имеющаяся техника
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

select * from inventory_usage;
