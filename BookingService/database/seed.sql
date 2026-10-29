-- BookingService / booking_db : reference data. Idempotent, safe in every environment.
-- Prices are placeholders; set real prices per market. Currency is handled by Payment.

INSERT INTO service_packages (id, name, description, base_price, duration_minutes, is_active) VALUES
    ('00000000-0000-4000-8000-0000000000f1', 'Express wash',   'Exterior rinse and dry',                    15.00,  30, true),
    ('00000000-0000-4000-8000-0000000000f2', 'Full wash',      'Exterior and interior clean',               35.00,  60, true),
    ('00000000-0000-4000-8000-0000000000f3', 'Premium detail', 'Full wash plus wax and interior detailing', 90.00, 120, true)
ON CONFLICT (name) DO UPDATE
    SET description = EXCLUDED.description,
        base_price = EXCLUDED.base_price,
        duration_minutes = EXCLUDED.duration_minutes;
