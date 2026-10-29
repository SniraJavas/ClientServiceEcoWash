-- NotificationService / notification_db : DEV SAMPLE DATA. Local development only.
-- Notifications are created by events, so there is nothing to sample beyond one device token.

INSERT INTO device_tokens (id, user_id, platform, token) VALUES
    (gen_random_uuid(), '00000000-0000-4000-8000-0000000000c1', 'android', 'dev-device-token-client')
ON CONFLICT (token) DO NOTHING;
