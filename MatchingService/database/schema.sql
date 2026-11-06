-- MatchingService / matching_db
-- Baseline schema (0001_baseline). Applied once by database/apply-all.ps1 as role matching_svc.
-- Later changes go in migrations/NNNN_name.sql (see database/README.md).
BEGIN;

CREATE TABLE schema_migrations (
    version    varchar(100) PRIMARY KEY,
    applied_at timestamptz  NOT NULL DEFAULT now()
);

CREATE TABLE match_requests (
    id               uuid             PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id       uuid             NOT NULL,             -- logical ref to booking_db.bookings.id
    status           varchar(20)      NOT NULL DEFAULT 'Searching',
    latitude         double precision NULL,                 -- copied from BookingCreatedEvent
    longitude        double precision NULL,
    search_radius_km numeric(6,2)     NOT NULL DEFAULT 15,
    requested_at     timestamptz      NOT NULL DEFAULT now(),
    completed_at     timestamptz      NULL,
    CONSTRAINT ux_match_requests_booking UNIQUE (booking_id),
    CONSTRAINT ck_match_requests_status CHECK (status IN ('Searching','Matched','Failed','Cancelled')),
    CONSTRAINT ck_match_requests_latitude  CHECK (latitude  IS NULL OR latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_match_requests_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    CONSTRAINT ck_match_requests_radius CHECK (search_radius_km > 0)
);
CREATE INDEX ix_match_requests_searching ON match_requests (requested_at) WHERE status = 'Searching';

CREATE TABLE match_candidates (
    id               uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    match_request_id uuid         NOT NULL REFERENCES match_requests (id) ON DELETE CASCADE,
    washer_id        uuid         NOT NULL,                 -- logical ref to washer_db.washers.id
    distance_km      numeric(6,2) NOT NULL,
    score            numeric(5,2) NOT NULL,
    offered_at       timestamptz  NOT NULL DEFAULT now(),
    responded_at     timestamptz  NULL,
    response         varchar(20)  NULL,
    CONSTRAINT ux_match_candidates_request_washer UNIQUE (match_request_id, washer_id),
    CONSTRAINT ck_match_candidates_response CHECK (response IS NULL OR response IN ('Accepted','Declined','Timeout'))
);
-- At most one washer can accept a given request.
CREATE UNIQUE INDEX ux_match_candidates_one_accepted
    ON match_candidates (match_request_id) WHERE response = 'Accepted';

-- Read-model fed by Washer events (WasherLocationUpdatedEvent). Matching never calls Washer.
CREATE TABLE washer_locations (
    washer_id    uuid             PRIMARY KEY,
    latitude     double precision NOT NULL,
    longitude    double precision NOT NULL,
    is_available boolean          NOT NULL DEFAULT false,
    updated_at   timestamptz      NOT NULL,
    CONSTRAINT ck_washer_locations_latitude  CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_washer_locations_longitude CHECK (longitude BETWEEN -180 AND 180)
);
CREATE INDEX ix_washer_locations_available ON washer_locations (latitude, longitude) WHERE is_available;

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
