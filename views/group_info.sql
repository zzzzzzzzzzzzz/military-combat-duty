-- Показывает составы дежурных расчётов на данный момент
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

SELECT * FROM group_info;
