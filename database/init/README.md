# EcoWash database scripts

One database and one owner role per microservice (see init-databases.sql). Each service keeps
its own folder of SQL next to its code:

    <Service>/database/schema.sql        baseline structure (creates schema_migrations)
    <Service>/database/seed.sql          reference data: idempotent, safe in EVERY environment
    <Service>/database/seed.dev.sql      sample data: local development ONLY
    <Service>/database/migrations/       numbered changes after the first release

## Run it

    cd ClientService ; docker compose up -d     # Postgres + RabbitMQ, creates the 7 databases
    cd ..\database ; .\apply-all.ps1 -Dev       # schema + reference data + sample data

Drop `-Dev` for anything that is not your own machine. To start from scratch:
`docker compose down -v` (deletes the volume), then repeat.

## Rules

1. schema.sql is the baseline. Never edit it after a release: add a migration instead.
2. A migration is `migrations/0002_short_name.sql`. It runs in a transaction and its last
   statement records itself:

       INSERT INTO schema_migrations (version) VALUES ('0002_short_name');

   apply-all.ps1 runs only migrations whose file name is not yet in schema_migrations.
3. seed.sql must be idempotent (ON CONFLICT ...), because it runs on every deployment.
4. No foreign keys between databases. Columns that point at another service's rows are plain uuids.
5. Plain ASCII only in these files (Windows PowerShell mangles UTF-8 on pipes).

## EF Core mapping

These scripts are the source of truth, so EF only maps to them; it does not create or migrate:
- do not run `dotnet ef migrations` or `Database.EnsureCreated()`
- call `.UseSnakeCaseNamingConvention()` (EFCore.NamingConventions) next to `UseNpgsql(...)`
- remove `HasData(...)` calls: seeding now lives in seed.sql
