-- WasherService / washer_db
-- Baseline schema (0001_baseline). Applied once by database/apply-all.ps1 as role washer_svc.
-- Later changes go in migrations/NNNN_name.sql (see database/README.md).
BEGIN;

CREATE TABLE schema_migrations (
    version    varchar(100) PRIMARY KEY,
    applied_at timestamptz  NOT NULL DEFAULT now()
);

CREATE TABLE washers (
    id                  uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    identity_subject_id uuid         NOT NULL,            -- logical ref to identity_db.users.id
    full_name           varchar(200) NOT NULL,
    phone               varchar(20)  NOT NULL,
    status              varchar(20)  NOT NULL DEFAULT 'Pending',
    rating_avg          numeric(3,2) NOT NULL DEFAULT 0,
    is_verified         boolean      NOT NULL DEFAULT false,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT ux_washers_identity_subject_id UNIQUE (identity_subject_id),
    CONSTRAINT ck_washers_status CHECK (status IN ('Pending','Active','Suspended')),
    CONSTRAINT ck_washers_rating CHECK (rating_avg BETWEEN 0 AND 5),
    CONSTRAINT ck_washers_active_needs_verification CHECK (status <> 'Active' OR is_verified)
);

CREATE TABLE washer_documents (
    id          uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    washer_id   uuid         NOT NULL REFERENCES washers (id) ON DELETE CASCADE,
    type        varchar(30)  NOT NULL,
    file_url    varchar(500) NOT NULL,
    verified_at timestamptz  NULL,
    CONSTRAINT ck_washer_documents_type CHECK (type IN ('IdCard','License','Insurance','Other'))
);
CREATE INDEX ix_washer_documents_washer_id ON washer_documents (washer_id);

CREATE TABLE washer_availability (
    id         uuid     PRIMARY KEY DEFAULT gen_random_uuid(),
    washer_id  uuid     NOT NULL REFERENCES washers (id) ON DELETE CASCADE,
    day        smallint NOT NULL,                  -- 0 = Sunday ... 6 = Saturday
    start_time time     NOT NULL,
    end_time   time     NOT NULL,
    CONSTRAINT ck_washer_availability_day  CHECK (day BETWEEN 0 AND 6),
    CONSTRAINT ck_washer_availability_span CHECK (end_time > start_time),
    CONSTRAINT ux_washer_availability_slot UNIQUE (washer_id, day, start_time)
);

CREATE TABLE washer_service_areas (
    id        uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    washer_id uuid         NOT NULL REFERENCES washers (id) ON DELETE CASCADE,
    city      varchar(100) NOT NULL,
    radius_km numeric(6,2) NOT NULL,
    CONSTRAINT ck_washer_service_areas_radius CHECK (radius_km > 0),
    CONSTRAINT ux_washer_service_areas_city UNIQUE (washer_id, city)
);

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
