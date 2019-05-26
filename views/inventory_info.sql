-- Показывает справочную информацию об имеющемся инвентаре
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

SELECT * FROM inventory_info;
