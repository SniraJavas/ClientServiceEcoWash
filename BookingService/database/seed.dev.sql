-- BookingService / booking_db : DEV SAMPLE DATA. Local development only.
-- IDs line up with the rows seeded in client_db, washer_db, matching_db and payment_db.

INSERT INTO bookings (id, client_id, vehicle_id, washer_id, package_id, idempotency_key,
                      street, city, postal_code, latitude, longitude,
                      requested_time, status, price_quote) VALUES
    ('00000000-0000-4000-8000-0000000001b1', '00000000-0000-4000-8000-0000000001c1', '00000000-0000-4000-8000-0000000002c1', '00000000-0000-4000-8000-0000000001d1', '00000000-0000-4000-8000-0000000000f2', 'dev-booking-1',
     '1 Sample Street', 'Sampletown', '00000', 10.0000, 20.0000,
     now() - interval '2 days', 'Completed', 35.00),
    ('00000000-0000-4000-8000-0000000002b1', '00000000-0000-4000-8000-0000000001c1', '00000000-0000-4000-8000-0000000002c1', NULL, '00000000-0000-4000-8000-0000000000f1', 'dev-booking-2',
     '1 Sample Street', 'Sampletown', '00000', 10.0000, 20.0000,
     now() + interval '1 day', 'Requested', 15.00)
ON CONFLICT (id) DO NOTHING;

INSERT INTO booking_status_history (id, booking_id, status, reason, changed_at) VALUES
    ('00000000-0000-4000-8000-000000b10001', '00000000-0000-4000-8000-0000000001b1', 'Requested',  NULL, now() - interval '2 days 3 hours'),
    ('00000000-0000-4000-8000-000000b10002', '00000000-0000-4000-8000-0000000001b1', 'Matched',    NULL, now() - interval '2 days 2 hours'),
    ('00000000-0000-4000-8000-000000b10003', '00000000-0000-4000-8000-0000000001b1', 'InProgress', NULL, now() - interval '2 days 1 hour'),
    ('00000000-0000-4000-8000-000000b10004', '00000000-0000-4000-8000-0000000001b1', 'Completed',  NULL, now() - interval '2 days'),
    ('00000000-0000-4000-8000-000000b20001', '00000000-0000-4000-8000-0000000002b1', 'Requested',  NULL, now())
ON CONFLICT (id) DO NOTHING;
