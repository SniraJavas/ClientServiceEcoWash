-- ClientService / client_db : DEV SAMPLE DATA. Local development only.
-- identity_subject_id matches the client user seeded in identity_db (client@ecowash.local).

INSERT INTO clients (id, identity_subject_id, full_name, email, phone, is_verified) VALUES
    ('00000000-0000-4000-8000-0000000001c1', '00000000-0000-4000-8000-0000000000c1', 'Test Client', 'client@ecowash.local', '+10000000001', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO vehicles (id, client_id, make, model, plate) VALUES
    ('00000000-0000-4000-8000-0000000002c1', '00000000-0000-4000-8000-0000000001c1', 'Toyota', 'Corolla', 'DEV-001')
ON CONFLICT (id) DO NOTHING;

INSERT INTO addresses (id, client_id, label, street, city, postal_code, latitude, longitude, is_default) VALUES
    ('00000000-0000-4000-8000-0000000003c1', '00000000-0000-4000-8000-0000000001c1', 'Home', '1 Sample Street', 'Sampletown', '00000', 10.0000, 20.0000, true)
ON CONFLICT (id) DO NOTHING;

-- Matches the two bookings seeded in booking_db.
INSERT INTO client_booking_history (id, client_id, vehicle_id, requested_time, status) VALUES
    ('00000000-0000-4000-8000-0000000001b1', '00000000-0000-4000-8000-0000000001c1', '00000000-0000-4000-8000-0000000002c1', now() - interval '2 days', 'Completed'),
    ('00000000-0000-4000-8000-0000000002b1', '00000000-0000-4000-8000-0000000001c1', '00000000-0000-4000-8000-0000000002c1', now() + interval '1 day',  'Requested')
ON CONFLICT (id) DO NOTHING;
