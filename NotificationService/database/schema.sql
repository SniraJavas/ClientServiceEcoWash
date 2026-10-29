-- NotificationService / notification_db
-- Baseline schema (0001_baseline). Applied once by database/apply-all.ps1 as role notification_svc.
-- Later changes go in migrations/NNNN_name.sql (see database/README.md).
BEGIN;

CREATE TABLE schema_migrations (
    version    varchar(100) PRIMARY KEY,
    applied_at timestamptz  NOT NULL DEFAULT now()
);

CREATE TABLE notification_templates (
    id      uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    key     varchar(100) NOT NULL,                      -- e.g. verify-email
    channel varchar(20)  NOT NULL,
    subject varchar(200) NOT NULL,
    body    text         NOT NULL,                      -- placeholders look like {{full_name}}
    CONSTRAINT ux_notification_templates_key_channel UNIQUE (key, channel),
    CONSTRAINT ck_notification_templates_channel CHECK (channel IN ('email','push','sms'))
);

CREATE TABLE notifications (
    id             uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id   uuid         NOT NULL,               -- client, washer or staff id (logical ref)
    recipient_type varchar(20)  NOT NULL,
    channel        varchar(20)  NOT NULL,
    template_key   varchar(100) NOT NULL,               -- logical ref to notification_templates.key
    payload        jsonb        NOT NULL DEFAULT '{}'::jsonb,   -- template values + delivery address
    status         varchar(20)  NOT NULL DEFAULT 'Pending',
    created_at     timestamptz  NOT NULL DEFAULT now(),
    sent_at        timestamptz  NULL,
    CONSTRAINT ck_notifications_recipient_type CHECK (recipient_type IN ('client','washer','staff')),
    CONSTRAINT ck_notifications_channel CHECK (channel IN ('email','push','sms')),
    CONSTRAINT ck_notifications_status CHECK (status IN ('Pending','Sent','Failed')),
    CONSTRAINT ck_notifications_sent CHECK ((status = 'Sent') = (sent_at IS NOT NULL))
);
CREATE INDEX ix_notifications_recipient ON notifications (recipient_id, created_at DESC);
CREATE INDEX ix_notifications_pending   ON notifications (created_at) WHERE status = 'Pending';

CREATE TABLE delivery_attempts (
    id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id uuid        NOT NULL REFERENCES notifications (id) ON DELETE CASCADE,
    attempted_at    timestamptz NOT NULL DEFAULT now(),
    success         boolean     NOT NULL,
    error           text        NULL
);
CREATE INDEX ix_delivery_attempts_notification ON delivery_attempts (notification_id);

CREATE TABLE device_tokens (
    id         uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    uuid         NOT NULL,
    platform   varchar(20)  NOT NULL,
    token      varchar(500) NOT NULL,
    created_at timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT ux_device_tokens_token UNIQUE (token),
    CONSTRAINT ck_device_tokens_platform CHECK (platform IN ('ios','android','web'))
);
CREATE INDEX ix_device_tokens_user ON device_tokens (user_id);

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
