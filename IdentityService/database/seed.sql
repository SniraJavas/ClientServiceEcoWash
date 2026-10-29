-- IdentityService / identity_db : reference data. Idempotent, safe in every environment.
-- Roles describe WHAT A PERSON MAY DO. Scopes (client, washer, complete-profile, staff)
-- describe WHICH APP/API A TOKEN IS FOR. Clients and washers need roles only to pick the
-- right scope and audience; staff roles also carry permission claims below.

INSERT INTO roles (id, name, normalized_name, concurrency_stamp) VALUES
    ('00000000-0000-4000-8000-0000000000e1', 'client', 'CLIENT', gen_random_uuid()::text),  -- Customer who books washes (client app)
    ('00000000-0000-4000-8000-0000000000e2', 'washer', 'WASHER', gen_random_uuid()::text),  -- Service provider who performs washes (washer app)
    ('00000000-0000-4000-8000-0000000000e3', 'admin', 'ADMIN', gen_random_uuid()::text),  -- Full platform administration
    ('00000000-0000-4000-8000-0000000000e4', 'support', 'SUPPORT', gen_random_uuid()::text),  -- Customer support agent
    ('00000000-0000-4000-8000-0000000000e5', 'finance', 'FINANCE', gen_random_uuid()::text),  -- Payments, refunds and washer payouts
    ('00000000-0000-4000-8000-0000000000e6', 'operations', 'OPERATIONS', gen_random_uuid()::text)  -- Washer onboarding, dispatch and matching oversight
ON CONFLICT (normalized_name) DO NOTHING;

-- Permission claims for staff roles (client and washer have none: they only access their own data).
INSERT INTO role_claims (role_id, claim_type, claim_value)
SELECT r.id, 'permission', p.permission
FROM (VALUES
    ('admin', 'users.read'),
    ('admin', 'users.manage'),
    ('admin', 'clients.read'),
    ('admin', 'clients.manage'),
    ('admin', 'washers.read'),
    ('admin', 'washers.approve'),
    ('admin', 'washers.manage'),
    ('admin', 'bookings.read'),
    ('admin', 'bookings.manage'),
    ('admin', 'matching.read'),
    ('admin', 'matching.override'),
    ('admin', 'payments.read'),
    ('admin', 'payments.refund'),
    ('admin', 'payouts.read'),
    ('admin', 'payouts.approve'),
    ('admin', 'notifications.read'),
    ('admin', 'templates.manage'),
    ('admin', 'roles.manage'),
    ('admin', 'reports.view'),
    ('support', 'users.read'),
    ('support', 'clients.read'),
    ('support', 'washers.read'),
    ('support', 'bookings.read'),
    ('support', 'bookings.manage'),
    ('support', 'matching.read'),
    ('support', 'payments.read'),
    ('support', 'notifications.read'),
    ('finance', 'bookings.read'),
    ('finance', 'payments.read'),
    ('finance', 'payments.refund'),
    ('finance', 'payouts.read'),
    ('finance', 'payouts.approve'),
    ('finance', 'reports.view'),
    ('operations', 'washers.read'),
    ('operations', 'washers.approve'),
    ('operations', 'washers.manage'),
    ('operations', 'bookings.read'),
    ('operations', 'bookings.manage'),
    ('operations', 'matching.read'),
    ('operations', 'matching.override'),
    ('operations', 'notifications.read'),
    ('operations', 'templates.manage')
) AS p (role_name, permission)
JOIN roles r ON r.normalized_name = upper(p.role_name)
ON CONFLICT (role_id, claim_type, claim_value) DO NOTHING;
