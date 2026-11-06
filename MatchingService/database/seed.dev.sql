-- MatchingService / matching_db : DEV SAMPLE DATA. Local development only.

INSERT INTO washer_locations (washer_id, latitude, longitude, is_available, updated_at) VALUES
    ('00000000-0000-4000-8000-0000000001d1', 10.0100, 20.0100, true, now())
ON CONFLICT (washer_id) DO NOTHING;

INSERT INTO match_requests (id, booking_id, status, latitude, longitude, requested_at, completed_at) VALUES
    ('00000000-0000-4000-8000-000000a00001', '00000000-0000-4000-8000-0000000001b1', 'Matched',   10.0000, 20.0000, now() - interval '2 days 2 hours 5 minutes', now() - interval '2 days 2 hours'),
    ('00000000-0000-4000-8000-000000a00003', '00000000-0000-4000-8000-0000000002b1', 'Searching', 10.0000, 20.0000, now(), NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO match_candidates (id, match_request_id, washer_id, distance_km, score, offered_at, responded_at, response) VALUES
    ('00000000-0000-4000-8000-000000a00002', '00000000-0000-4000-8000-000000a00001', '00000000-0000-4000-8000-0000000001d1', 1.50, 92.50,
     now() - interval '2 days 2 hours 4 minutes', now() - interval '2 days 2 hours', 'Accepted')
ON CONFLICT (id) DO NOTHING;
