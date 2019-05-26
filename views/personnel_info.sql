-- Выводит данные о каждом подчиненном, и их текущий статус
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

SELECT * FROM personnel_info;
