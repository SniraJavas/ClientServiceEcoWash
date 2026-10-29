-- PaymentService / payment_db
-- Baseline schema (0001_baseline). Applied once by database/apply-all.ps1 as role payment_svc.
-- Later changes go in migrations/NNNN_name.sql (see database/README.md).
BEGIN;

CREATE TABLE schema_migrations (
    version    varchar(100) PRIMARY KEY,
    applied_at timestamptz  NOT NULL DEFAULT now()
);

-- Financial rows are never cascade-deleted: foreign keys use RESTRICT.
CREATE TABLE payments (
    id              uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id      uuid          NOT NULL,                 -- logical ref to booking_db.bookings.id
    client_id       uuid          NOT NULL,                 -- logical ref to client_db.clients.id
    amount          numeric(12,2) NOT NULL,
    currency        varchar(3)    NOT NULL DEFAULT 'USD',   -- set per market
    status          varchar(20)   NOT NULL DEFAULT 'Pending',
    provider_ref    varchar(100)  NULL,
    idempotency_key varchar(100)  NOT NULL,
    created_at      timestamptz   NOT NULL DEFAULT now(),
    CONSTRAINT ux_payments_idempotency_key UNIQUE (idempotency_key),
    CONSTRAINT ck_payments_amount CHECK (amount > 0),
    CONSTRAINT ck_payments_currency CHECK (currency ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_payments_status CHECK (status IN ('Pending','Authorized','Captured','Failed','Refunded'))
);
CREATE INDEX ix_payments_booking ON payments (booking_id);
CREATE INDEX ix_payments_client  ON payments (client_id, created_at DESC);
-- Guards against double-charging: only one live payment per booking (failed attempts may repeat).
CREATE UNIQUE INDEX ux_payments_one_live_per_booking
    ON payments (booking_id) WHERE status IN ('Pending','Authorized','Captured');

CREATE TABLE refunds (
    id         uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id uuid          NOT NULL REFERENCES payments (id) ON DELETE RESTRICT,
    amount     numeric(12,2) NOT NULL,
    reason     varchar(300)  NOT NULL,
    status     varchar(20)   NOT NULL DEFAULT 'Pending',
    created_at timestamptz   NOT NULL DEFAULT now(),
    CONSTRAINT ck_refunds_amount CHECK (amount > 0),
    CONSTRAINT ck_refunds_status CHECK (status IN ('Pending','Completed','Failed'))
);
CREATE INDEX ix_refunds_payment ON refunds (payment_id);

-- Only the payment provider's token is stored. Never card numbers or CVV.
CREATE TABLE payment_methods (
    id             uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id      uuid         NOT NULL,
    provider_token varchar(200) NOT NULL,
    brand          varchar(30)  NOT NULL,
    last4          varchar(4)   NOT NULL,
    is_default     boolean      NOT NULL DEFAULT false,
    created_at     timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT ck_payment_methods_last4 CHECK (last4 ~ '^[0-9]{4}$'),
    CONSTRAINT ux_payment_methods_token UNIQUE (client_id, provider_token)
);
CREATE UNIQUE INDEX ux_payment_methods_one_default ON payment_methods (client_id) WHERE is_default;

CREATE TABLE washer_payouts (
    id         uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
    washer_id  uuid          NOT NULL,                      -- logical ref to washer_db.washers.id
    booking_id uuid          NOT NULL,                      -- logical ref to booking_db.bookings.id
    amount     numeric(12,2) NOT NULL,
    status     varchar(20)   NOT NULL DEFAULT 'Pending',
    paid_at    timestamptz   NULL,
    created_at timestamptz   NOT NULL DEFAULT now(),
    CONSTRAINT ux_washer_payouts_booking UNIQUE (booking_id),   -- one payout per booking
    CONSTRAINT ck_washer_payouts_amount CHECK (amount > 0),
    CONSTRAINT ck_washer_payouts_status CHECK (status IN ('Pending','Paid','Failed')),
    CONSTRAINT ck_washer_payouts_paid CHECK ((status = 'Paid') = (paid_at IS NOT NULL))
);
CREATE INDEX ix_washer_payouts_washer ON washer_payouts (washer_id, status);

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
