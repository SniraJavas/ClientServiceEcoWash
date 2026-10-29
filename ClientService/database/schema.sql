-- ClientService / client_db
-- Baseline schema (0001_baseline). Applied once by database/apply-all.ps1 as role client_svc.
-- Later changes go in migrations/NNNN_name.sql (see database/README.md).
BEGIN;

CREATE TABLE schema_migrations (
    version    varchar(100) PRIMARY KEY,
    applied_at timestamptz  NOT NULL DEFAULT now()
);

CREATE TABLE clients (
    id                  uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    identity_subject_id uuid         NOT NULL,            -- logical ref to identity_db.users.id
    full_name           varchar(200) NOT NULL,
    email               varchar(320) NOT NULL,
    phone               varchar(20)  NOT NULL,
    is_verified         boolean      NOT NULL DEFAULT false,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT ux_clients_identity_subject_id UNIQUE (identity_subject_id)
);
CREATE UNIQUE INDEX ux_clients_email_lower ON clients (lower(email));

CREATE TABLE vehicles (
    id        uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id uuid         NOT NULL REFERENCES clients (id) ON DELETE CASCADE,
    make      varchar(100) NOT NULL,
    model     varchar(100) NOT NULL,
    plate     varchar(20)  NOT NULL,
    CONSTRAINT ux_vehicles_client_plate UNIQUE (client_id, plate)
);

-- Defence in depth: the aggregate already enforces "at most 5 vehicles".
CREATE FUNCTION enforce_max_vehicles() RETURNS trigger AS $$
BEGIN
    IF (SELECT count(*) FROM vehicles WHERE client_id = NEW.client_id) >= 5 THEN
        RAISE EXCEPTION 'A client may register at most 5 vehicles.' USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_vehicles_max_5 BEFORE INSERT ON vehicles
    FOR EACH ROW EXECUTE FUNCTION enforce_max_vehicles();

CREATE TABLE addresses (
    id          uuid             PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id   uuid             NOT NULL REFERENCES clients (id) ON DELETE CASCADE,
    label       varchar(50)      NOT NULL,                 -- Home, Work
    street      varchar(200)     NOT NULL,
    city        varchar(100)     NOT NULL,
    postal_code varchar(20)      NOT NULL,
    latitude    double precision NULL CHECK (latitude  BETWEEN -90  AND 90),
    longitude   double precision NULL CHECK (longitude BETWEEN -180 AND 180),
    is_default  boolean          NOT NULL DEFAULT false
);
CREATE INDEX ix_addresses_client_id ON addresses (client_id);
CREATE UNIQUE INDEX ux_addresses_one_default ON addresses (client_id) WHERE is_default;

-- Read-model fed by Booking events. booking id and vehicle_id belong to other tables/services,
-- so there is deliberately no foreign key.
CREATE TABLE client_booking_history (
    id             uuid        PRIMARY KEY,               -- booking id
    client_id      uuid        NOT NULL,
    vehicle_id     uuid        NOT NULL,
    requested_time timestamptz NOT NULL,
    status         varchar(30) NOT NULL,
    updated_at_utc timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_client_booking_history_status
        CHECK (status IN ('Requested','Matched','InProgress','Completed','Cancelled','Unmatched'))
);
CREATE INDEX ix_client_booking_history_client ON client_booking_history (client_id, requested_time DESC);

-- Transactional outbox: events are written here in the same transaction as the data change,
-- then published to RabbitMQ by the outbox worker.
CREATE TABLE outbox_messages (
    id           uuid         PRIMARY KEY,
    type         varchar(200) NOT NULL,
    payload      jsonb        NOT NULL,
    created_at   timestamptz  NOT NULL DEFAULT now(),
    published_at timestamptz  NULL
);
CREATE INDEX ix_outbox_messages_unpublished ON outbox_messages (created_at) WHERE published_at IS NULL;

-- Inbox: remembers which messages this service already processed (idempotent consumers).
CREATE TABLE inbox_messages (
    message_id   uuid         NOT NULL,
    consumer     varchar(200) NOT NULL,
    processed_at timestamptz  NOT NULL DEFAULT now(),
    PRIMARY KEY (message_id, consumer)
);

INSERT INTO schema_migrations (version) VALUES ('0001_baseline');

COMMIT;
