-- PaymentService / payment_db : DEV SAMPLE DATA. Local development only.
-- The token below is a fake placeholder, not a real card.

INSERT INTO payment_methods (id, client_id, provider_token, brand, last4, is_default) VALUES
    ('00000000-0000-4000-8000-000000e00002', '00000000-0000-4000-8000-0000000001c1', 'tok_dev_visa', 'Visa', '4242', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO payments (id, booking_id, client_id, amount, currency, status, provider_ref, idempotency_key) VALUES
    ('00000000-0000-4000-8000-000000e00001', '00000000-0000-4000-8000-0000000001b1', '00000000-0000-4000-8000-0000000001c1', 35.00, 'USD', 'Captured', 'dev_charge_1', 'dev-payment-1')
ON CONFLICT (id) DO NOTHING;

INSERT INTO washer_payouts (id, washer_id, booking_id, amount, status) VALUES
    ('00000000-0000-4000-8000-000000e00003', '00000000-0000-4000-8000-0000000001d1', '00000000-0000-4000-8000-0000000001b1', 28.00, 'Pending')
ON CONFLICT (id) DO NOTHING;
