-- BookingService / booking_db
-- Baseline schema (0001_baseline). Applied once by database/apply-all.ps1 as role booking_svc.
-- Later changes go in migrations/NNNN_name.sql (see database/README.md).
BEGIN;

CREATE TABLE schema_migrations (
    version    varchar(100) PRIMARY KEY,
    applied_at timestamptz  NOT NULL DEFAULT now()
);

CREATE TABLE service_packages (
    id               uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
    name             varchar(100)  NOT NULL,
    description      varchar(500)  NULL,
    base_price       numeric(10,2) NOT NULL,
    duration_minutes integer       NOT NULL,
    is_active        boolean       NOT NULL DEFAULT true,
    CONSTRAINT ux_service_packages_name UNIQUE (name),
    CONSTRAINT ck_service_packages_price CHECK (base_price >= 0),
    CONSTRAINT ck_service_packages_duration CHECK (duration_minutes > 0)
);

CREATE TABLE bookings (
    id              uuid             PRIMARY KEY,           -- = WashRequestedEvent.RequestId
    client_id       uuid             NOT NULL,              -- logical ref to client_db.clients.id
    vehicle_id      uuid             NOT NULL,              -- logical ref to client_db.vehicles.id
    washer_id       uuid             NULL,                  -- logical ref to washer_db.washers.id
    package_id      uuid             NULL REFERENCES service_packages (id),
    idempotency_key varchar(100)     NOT NULL,
    street          varchar(200)     NOT NULL,              -- address snapshot at booking time
    city            varchar(100)     NOT NULL,
    postal_code     varchar(20)      NOT NULL,
    latitude        double precision NULL,
    longitude       double precision NULL,
    requested_time  timestamptz      NOT NULL,
    status          varchar(20)      NOT NULL DEFAULT 'Requested',
    price_quote     numeric(10,2)    NULL,
    created_at      timestamptz      NOT NULL DEFAULT now(),
    CONSTRAINT ux_bookings_idempotency_key UNIQUE (idempotency_key),     -- retry-safe creates
    CONSTRAINT ck_bookings_status CHECK (status IN ('Requested','Matched','InProgress','Completed','Cancelled','Unmatched')),
    CONSTRAINT ck_bookings_washer_required
        CHECK (status NOT IN ('Matched','InProgress','Completed') OR washer_id IS NOT NULL),
    CONSTRAINT ck_bookings_price CHECK (price_quote IS NULL OR price_quote >= 0),
    CONSTRAINT ck_bookings_latitude  CHECK (latitude  IS NULL OR latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_bookings_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);
CREATE INDEX ix_bookings_client_time ON bookings (client_id, requested_time DESC);
CREATE INDEX ix_bookings_washer      ON bookings (washer_id) WHERE washer_id IS NOT NULL;
CREATE INDEX ix_bookings_status      ON bookings (status);
-- Optimistic concurrency uses Postgres' built-in xmin system column; no column to create.

CREATE TABLE booking_status_history (
    id         uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id uuid         NOT NULL REFERENCES bookings (id) ON DELETE CASCADE,
    status     varchar(20)  NOT NULL,
    reason     varchar(300) NULL,
    changed_at timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT ck_booking_status_history_status CHECK (status IN ('Requested','Matched','InProgress','Completed','Cancelled','Unmatched'))
);
CREATE INDEX ix_booking_status_history_booking ON booking_status_history (booking_id, changed_at);

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
