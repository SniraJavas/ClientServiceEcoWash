-- NotificationService / notification_db : reference data. Idempotent, safe in every environment.
-- Re-running updates subject/body, so editing a template here and re-applying is enough.
-- Placeholders use {{name}} syntax; the renderer (for example Fluid or Scriban) fills them from
-- notifications.payload.

INSERT INTO notification_templates (id, key, channel, subject, body) VALUES
    (gen_random_uuid(), 'verify-email', 'email', 'Verify your EcoWash email',
     E'Hi,\n\nPlease confirm your email address to start booking washes:\n{{verification_link}}\n\nThis link expires in 24 hours. If you did not create an account, you can ignore this email.\n\nThe EcoWash team'),
    (gen_random_uuid(), 'welcome-email', 'email', 'Welcome to EcoWash',
     E'Hi {{full_name}},\n\nYour profile is ready. Add a vehicle and book your first wash in the app.\n\nThe EcoWash team'),
    (gen_random_uuid(), 'booking-created', 'email', 'We received your wash request',
     E'Hi {{full_name}},\n\nWe are finding a washer for {{requested_time}}. We will tell you as soon as one accepts.\n\nBooking reference: {{booking_id}}'),
    (gen_random_uuid(), 'booking-created', 'push', 'Request received',
     E'We are finding a washer for {{requested_time}}.'),
    (gen_random_uuid(), 'washer-matched', 'email', 'Your washer is on the way',
     E'Hi {{full_name}},\n\n{{washer_name}} will wash your vehicle. Estimated arrival: {{eta_minutes}} minutes.\n\nBooking reference: {{booking_id}}'),
    (gen_random_uuid(), 'washer-matched', 'push', 'Washer assigned',
     E'{{washer_name}} is on the way. ETA {{eta_minutes}} min.'),
    (gen_random_uuid(), 'booking-completed', 'email', 'Your wash is complete',
     E'Hi {{full_name}},\n\nYour wash is complete. Thank you for using EcoWash.\n\nBooking reference: {{booking_id}}'),
    (gen_random_uuid(), 'payment-captured', 'email', 'Your EcoWash receipt',
     E'Hi {{full_name}},\n\nWe received your payment of {{amount}} {{currency}} for booking {{booking_id}}.'),
    (gen_random_uuid(), 'booking-cancelled', 'email', 'Your booking was cancelled',
     E'Hi {{full_name}},\n\nBooking {{booking_id}} was cancelled. Reason: {{reason}}.'),
    (gen_random_uuid(), 'booking-cancelled', 'push', 'Booking cancelled',
     E'Booking {{booking_id}} was cancelled.'),
    (gen_random_uuid(), 'refund-issued', 'email', 'Your refund is on its way',
     E'Hi {{full_name}},\n\nWe issued a refund of {{amount}} {{currency}} for booking {{booking_id}}.'),
    (gen_random_uuid(), 'job-offer', 'push', 'New wash nearby',
     E'A wash is available {{distance_km}} km away. Open the app to accept.'),
    (gen_random_uuid(), 'washer-approved', 'email', 'You are approved to wash on EcoWash',
     E'Hi {{full_name}},\n\nYour documents are verified. You can now go online and receive job offers.\n\nThe EcoWash team')
ON CONFLICT (key, channel) DO UPDATE
    SET subject = EXCLUDED.subject,
        body    = EXCLUDED.body;
