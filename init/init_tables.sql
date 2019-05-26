DROP TABLE IF EXISTS duty_groups_log;
DROP TABLE IF EXISTS groups_personnel;
DROP TABLE IF EXISTS duty_groups;
DROP TABLE IF EXISTS personnel;
DROP TABLE IF EXISTS personnel_status;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS radar_station;


CREATE TABLE IF NOT EXISTS radar_station (
    name VARCHAR(255) PRIMARY KEY,
    range INTEGER NOT NULL,
    n_persons SMALLINT NOT NULL,
    CONSTRAINT range_gr_than_zero CHECK (range > 0),
    CONSTRAINT n_persons_gr_than_zero CHECK (n_persons > 0)
);

COMMENT ON TABLE radar_station IS 'Глоссарий радаров доступных в ВС РФ (или в этой ВЧ)';
COMMENT ON COLUMN radar_station.name IS 'Имя (тип) РЛС';  
COMMENT ON COLUMN radar_station.range IS 'Радиус работы на средних и больших высотах (считаем, что зона покрытия примерно круг)'; 
COMMENT ON COLUMN radar_station.n_persons IS 'Кол-во людей, нужное для обслуживания';  


CREATE TABLE IF NOT EXISTS inventory (
    serial_number INTEGER PRIMARY KEY,
    rs_name varchar(255) NOT NULL REFERENCES radar_station (name) ON DELETE RESTRICT,
    active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE inventory IS 'Техника в составе военной части. Расположение РЛС оптимально, и не меняется';

CREATE TABLE IF NOT EXISTS duty_groups (
    gr_id SERIAL PRIMARY KEY,
    for_station VARCHAR(255) REFERENCES radar_station (name) ON DELETE SET NULL
);

COMMENT ON TABLE duty_groups IS 'Дежурные расчёты, и их командиры';
COMMENT ON COLUMN duty_groups.for_station IS 'На каком типе оборудования работает расчёт';

CREATE TABLE IF NOT EXISTS personnel_status (
    id SERIAL PRIMARY KEY,
    shortname VARCHAR(50) UNIQUE,
    description VARCHAR(255)
);

COMMENT ON TABLE personnel_status IS 'Состояния персонала, например, в отпуске или на больничном';

CREATE TABLE IF NOT EXISTS personnel (
    p_id SERIAL PRIMARY KEY,
    surname VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    patronymic VARCHAR(255),
    status INTEGER REFERENCES personnel_status (id) ON DELETE RESTRICT
);

COMMENT ON TABLE personnel IS 'Базовая информация о личном составе';

CREATE TABLE IF NOT EXISTS groups_personnel (
    gr_id INTEGER NOT NULL REFERENCES duty_groups (gr_id) ON DELETE CASCADE,
    p_id INTEGER NOT NULL UNIQUE REFERENCES personnel (p_id) ON DELETE CASCADE,
    is_commander BOOLEAN DEFAULT FALSE,
    CONSTRAINT group_person_pk PRIMARY KEY (gr_id, p_id)
);

COMMENT ON TABLE groups_personnel IS 'Информация о текущем составе расчётов.';
COMMENT ON COLUMN groups_personnel.p_id IS 'Связь 1 к 1. Для простоты закладываем такое ограничение.';
COMMENT ON COLUMN groups_personnel.is_commander IS 'Является ли этот человек командиром расчёта.';

CREATE TABLE IF NOT EXISTS duty_groups_log (
    duty_start TIMESTAMP WITH TIME ZONE NOT NULL,
    duty_end TIMESTAMP WITH TIME ZONE NOT NULL,
    equipment INTEGER NOT NULL REFERENCES inventory (serial_number),
    gr_id INTEGER REFERENCES duty_groups (gr_id) ON DELETE SET NULL,
    brief TEXT[],
    CONSTRAINT log_pk PRIMARY KEY (duty_start, duty_end, equipment)
);

COMMENT ON TABLE duty_groups_log IS 'История работы дежурных расчётов. Кто, когда, где и на чём работали. Все записи уникальны на уровне первичного ключа';
COMMENT ON COLUMN duty_groups_log.brief IS 'Текстовое описание состава дежурства';
