-- WasherService / washer_db : DEV SAMPLE DATA. Local development only.
-- identity_subject_id matches the washer user seeded in identity_db (washer@ecowash.local).

INSERT INTO washers (id, identity_subject_id, full_name, phone, status, rating_avg, is_verified) VALUES
    ('00000000-0000-4000-8000-0000000001d1', '00000000-0000-4000-8000-0000000000d1', 'Test Washer', '+10000000002', 'Active', 4.80, true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO washer_documents (id, washer_id, type, file_url, verified_at) VALUES
    ('00000000-0000-4000-8000-0000000002d1', '00000000-0000-4000-8000-0000000001d1', 'IdCard',    'https://files.example.invalid/dev/id-card.pdf',   now()),
    ('00000000-0000-4000-8000-0000000003d1', '00000000-0000-4000-8000-0000000001d1', 'Insurance', 'https://files.example.invalid/dev/insurance.pdf', now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO washer_availability (id, washer_id, day, start_time, end_time) VALUES
    ('00000000-0000-4000-8000-0000000004d1', '00000000-0000-4000-8000-0000000001d1', 1, '08:00', '17:00'),
    ('00000000-0000-4000-8000-0000000005d1', '00000000-0000-4000-8000-0000000001d1', 2, '08:00', '17:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO washer_service_areas (id, washer_id, city, radius_km) VALUES
    ('00000000-0000-4000-8000-0000000006d1', '00000000-0000-4000-8000-0000000001d1', 'Sampletown', 15)
ON CONFLICT (id) DO NOTHING;
