-- EcoWash: one database and one owner role per microservice.
-- Runs once, the first time the Postgres container starts (docker-entrypoint-initdb.d).
-- DEV passwords only. In any shared environment create roles with real secrets instead.

CREATE ROLE identity_svc     LOGIN PASSWORD 'change-me';
CREATE ROLE client_svc       LOGIN PASSWORD 'change-me';
CREATE ROLE washer_svc       LOGIN PASSWORD 'change-me';
CREATE ROLE booking_svc      LOGIN PASSWORD 'change-me';
CREATE ROLE matching_svc     LOGIN PASSWORD 'change-me';
CREATE ROLE payment_svc      LOGIN PASSWORD 'change-me';
CREATE ROLE notification_svc LOGIN PASSWORD 'change-me';

CREATE DATABASE identity_db     OWNER identity_svc;
CREATE DATABASE client_db       OWNER client_svc;
CREATE DATABASE washer_db       OWNER washer_svc;
CREATE DATABASE booking_db      OWNER booking_svc;
CREATE DATABASE matching_db     OWNER matching_svc;
CREATE DATABASE payment_db      OWNER payment_svc;
CREATE DATABASE notification_db OWNER notification_svc;

-- Only the owning service role may connect to its database.
REVOKE ALL ON DATABASE identity_db, client_db, washer_db, booking_db,
                       matching_db, payment_db, notification_db FROM PUBLIC;

-- Store and compare every timestamp in UTC.
ALTER DATABASE identity_db     SET timezone TO 'UTC';
ALTER DATABASE client_db       SET timezone TO 'UTC';
ALTER DATABASE washer_db       SET timezone TO 'UTC';
ALTER DATABASE booking_db      SET timezone TO 'UTC';
ALTER DATABASE matching_db     SET timezone TO 'UTC';
ALTER DATABASE payment_db      SET timezone TO 'UTC';
ALTER DATABASE notification_db SET timezone TO 'UTC';
