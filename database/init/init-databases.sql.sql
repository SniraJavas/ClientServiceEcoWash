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

REVOKE ALL ON DATABASE identity_db, client_db, washer_db, booking_db,
                       matching_db, payment_db, notification_db FROM PUBLIC;