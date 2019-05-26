DROP DATABASE IF EXISTS combat_duty;
DROP USER IF EXISTS administrator;
CREATE DATABASE combat_duty;
CREATE USER administrator WITH PASSWORD '123456';
GRANT ALL PRIVILEGES ON DATABASE "combat_duty" to administrator;
ALTER DATABASE combat_duty SET timezone TO 'Europe/Moscow';
