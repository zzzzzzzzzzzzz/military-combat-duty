DROP TRIGGER IF EXISTS commander_check ON duty_groups_log;
DROP FUNCTION IF EXISTS check_commander();
CREATE FUNCTION check_commander() RETURNS trigger AS $check_commander$
DECLARE pid INTEGER;
    BEGIN
        IF NEW.gr_id THEN
            SELECT p_id INTO pid FROM groups_personnel WHERE is_commander=TRUE AND gr_id=NEW.gr_id;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Командир не назначен для группы %', NEW.gr_id;
            END IF;
        END IF;
        RETURN NEW;
    END;
$check_commander$ LANGUAGE plpgsql;

CREATE TRIGGER commander_check BEFORE INSERT OR UPDATE ON duty_groups_log
    FOR EACH ROW EXECUTE PROCEDURE check_commander();

-- Проверим работу триггера
BEGIN;
SAVEPOINT my_savepoint;
-- не выкинет исключение
--INSERT INTO  duty_groups_log (duty_start, duty_end, equipment, gr_id) VALUES ('2019-04-02 18:00:00', '2019-04-03 18:00:00', 9073260, 10);--ok
UPDATE groups_personnel SET is_commander=FALSE WHERE p_id=74 AND gr_id=10;
-- выкинет исключение
INSERT INTO  duty_groups_log (duty_start, duty_end, equipment, gr_id) VALUES ('2019-04-02 18:00:00', '2019-04-03 18:00:00', 9073260, 10);
ROLLBACK TO my_savepoint;
COMMIT;


