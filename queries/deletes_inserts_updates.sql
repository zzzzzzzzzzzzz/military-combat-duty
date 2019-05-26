-- Переформируем дежурные расчёты
DELETE FROM groups_personnel WHERE gr_id=21 AND p_id=121;
INSERT INTO groups_personnel (gr_id, p_id) VALUES (21,121);


-- Отправляем технику на ремонт или консервируем
UPDATE inventory SET active=FALSE WHERE serial_number=6637779; -- Противник-ГЕ


-- Удалим один из дежурных расчётов, посмотрим что мы увидим в логах
-- До удаления
SELECT * FROM duty_groups_log; 
SELECT * FROM groups_personnel WHERE gr_id=6;

DELETE FROM duty_groups WHERE gr_id=6;

-- После удаления, видно что запись в логе осталась, 
-- мы знаем кто дежурил, и когда, но номер группы выставлен в NULL
SELECT * FROM duty_groups_log; 
-- Из таблицы groups personnel данные удалились в соответствии с CASCADE
SELECT * FROM groups_personnel WHERE gr_id=6;