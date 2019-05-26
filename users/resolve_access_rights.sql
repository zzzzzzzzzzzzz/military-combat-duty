-- запускать из под пользователя postgres
REVOKE ALL ON DATABASE combat_duty FROM authority;
REVOKE ALL ON FUNCTION get_groups(timestamp with time zone, integer) FROM authority;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM authority;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authority;
REVOKE ALL ON DATABASE combat_duty FROM people;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM people;
DROP USER IF EXISTS general;
DROP USER IF EXISTS duty_commander;
DROP GROUP IF EXISTS authority;
DROP GROUP IF EXISTS people;


CREATE GROUP authority;
CREATE GROUP people;
CREATE USER general WITH PASSWORD 'general';
CREATE USER duty_commander WITH PASSWORD 'duty_commander';
ALTER GROUP authority ADD USER general;
ALTER GROUP people ADD USER duty_commander;

GRANT SELECT ON duty_groups_log, groups_personnel, duty_groups TO GROUP people;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO GROUP authority;
GRANT EXECUTE ON FUNCTION get_groups(timestamp with time zone, integer) TO GROUP authority;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO GROUP authority;