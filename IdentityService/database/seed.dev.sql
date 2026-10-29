-- IdentityService / identity_db : DEV SAMPLE USERS. Never run against a shared or production database.
-- Every account below has the password:  EcoWash!Dev123
-- (ASP.NET Identity V3 PBKDF2 hashes; emails are already confirmed so you can log in at once.)
-- The client and washer user IDs match the rows seeded in client_db and washer_db.

INSERT INTO users (id, user_name, normalized_user_name, email, normalized_email, email_confirmed,
                   password_hash, security_stamp, concurrency_stamp,
                   phone_number_confirmed, two_factor_enabled, lockout_enabled, access_failed_count)
VALUES
    ('00000000-0000-4000-8000-0000000000a1', 'admin@ecowash.local', 'ADMIN@ECOWASH.LOCAL', 'admin@ecowash.local', 'ADMIN@ECOWASH.LOCAL', true,
     'AQAAAAEAAYagAAAAEJjF3dHUDdgSeTWqUBJojR1pvTE2x/+sWvJaD1KIRfL8XJlFxSdV+Uqce3M5Sg9DHg==',
     'KEBA644MHPEP2WKJK2MKP4WMJKZXZSPG', gen_random_uuid()::text, false, false, true, 0),
    ('00000000-0000-4000-8000-0000000000a2', 'support@ecowash.local', 'SUPPORT@ECOWASH.LOCAL', 'support@ecowash.local', 'SUPPORT@ECOWASH.LOCAL', true,
     'AQAAAAEAAYagAAAAEOEy3eprTpvpGIZaepQnI+OptBm0yOnmcKQt/gLXT7vXTLDGB32Ty9rd+Xb4AlxVlA==',
     'FALANQOQZWUJUOPQXM2NCLZVO5YK5WN3', gen_random_uuid()::text, false, false, true, 0),
    ('00000000-0000-4000-8000-0000000000a3', 'finance@ecowash.local', 'FINANCE@ECOWASH.LOCAL', 'finance@ecowash.local', 'FINANCE@ECOWASH.LOCAL', true,
     'AQAAAAEAAYagAAAAEKE3cthHezXjDDVDQj0CreArGm9PlTXFROXr+/qNrDsTZzr6zTdOEJDtyIm+NFru6g==',
     'Z3ML4JDASV3SIPXXKGXKHURWJ3D7KTBA', gen_random_uuid()::text, false, false, true, 0),
    ('00000000-0000-4000-8000-0000000000a4', 'ops@ecowash.local', 'OPS@ECOWASH.LOCAL', 'ops@ecowash.local', 'OPS@ECOWASH.LOCAL', true,
     'AQAAAAEAAYagAAAAEGOxf1sSmHijvUyTdugaPsLzt0/HoRDQw53Ba6wPqDum+Eqbv5lChU7MeBlblWou8Q==',
     'CGL3KIHHDH2N2QMWX6VQVLNIGVXQVUNF', gen_random_uuid()::text, false, false, true, 0),
    ('00000000-0000-4000-8000-0000000000c1', 'client@ecowash.local', 'CLIENT@ECOWASH.LOCAL', 'client@ecowash.local', 'CLIENT@ECOWASH.LOCAL', true,
     'AQAAAAEAAYagAAAAEGrjfV8MRqKWqwONhDhs5MJRXMEGhCIE1yPPP5U23IJhPLMW4GNGxlyz3/moXzau0A==',
     'AP7DSM4TSPZU6MP6EOKTNH7LVCSQUZCI', gen_random_uuid()::text, false, false, true, 0),
    ('00000000-0000-4000-8000-0000000000d1', 'washer@ecowash.local', 'WASHER@ECOWASH.LOCAL', 'washer@ecowash.local', 'WASHER@ECOWASH.LOCAL', true,
     'AQAAAAEAAYagAAAAELxIm43xMEi6hK7Gi6h97Cqy7l2Ck9736L+6FaZzlxwkTlrdBiai8+6tEg7aK0n3MQ==',
     'OJMFL66IGO3NH6E55POOSWROXJH3WYM3', gen_random_uuid()::text, false, false, true, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_roles (user_id, role_id) VALUES
    ('00000000-0000-4000-8000-0000000000a1', '00000000-0000-4000-8000-0000000000e3'),
    ('00000000-0000-4000-8000-0000000000a2', '00000000-0000-4000-8000-0000000000e4'),
    ('00000000-0000-4000-8000-0000000000a3', '00000000-0000-4000-8000-0000000000e5'),
    ('00000000-0000-4000-8000-0000000000a4', '00000000-0000-4000-8000-0000000000e6'),
    ('00000000-0000-4000-8000-0000000000c1', '00000000-0000-4000-8000-0000000000e1'),
    ('00000000-0000-4000-8000-0000000000d1', '00000000-0000-4000-8000-0000000000e2')
ON CONFLICT (user_id, role_id) DO NOTHING;
