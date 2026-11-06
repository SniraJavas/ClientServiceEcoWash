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

# EcoWash
## Developer Onboarding & Docker Setup Guide

**Project:** EcoWash  
**Architecture:** .NET Microservices  
**Infrastructure:** Docker, PostgreSQL 16, RabbitMQ  
**Development environment:** Windows, PowerShell, Docker Desktop, Visual Studio

---

## 1. Project Overview

EcoWash is a microservices-based application built using .NET. Each microservice owns its own database and is responsible for a specific business capability.

### Repository Structure

```text
EcoWash/
│
├── database/
│   └── init/
│       ├── init-databases.sql
│       └── apply-all.ps1
│
├── ClientService/
│   ├── docker-compose.yml
│   ├── Client.Api/
│   ├── Client.Application/
│   ├── Client.Infrastructure/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
│
├── IdentityService/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
│
├── BookingService/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
│
├── WasherService/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
│
├── PricingService/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
│
├── PaymentService/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
│
├── NotificationService/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
│
└── EcoWash.Gateway/
```

**Important architectural conventions:**

1. Each microservice owns its database.
2. Each service maintains its own `schema.sql` and `seed.sql`.
3. The repository-level `database/init` directory contains shared database initialisation scripts.
4. `EcoWash.Gateway` is a separate project, not a microservice.
5. Docker Compose infrastructure is currently configured in `ClientService/docker-compose.yml`.

---

## 2. Prerequisites

Install the following tools before onboarding.

| Software | Purpose |
|---|---|
| Git | Source control |
| Docker Desktop | Container management |
| .NET SDK | Build and run .NET services |
| Visual Studio 2022 | Development IDE |
| PostgreSQL client / pgAdmin | Database inspection |
| Postman | API testing |

Verify installations:

```powershell
git --version
docker --version
docker compose version
dotnet --version
```

Ensure Docker Desktop is running and configured to use Linux containers.

---

## 3. Clone the Repository

Clone the repository:

```powershell
git clone <REPOSITORY_URL>
```

Navigate into the repository:

```powershell
cd EcoWash
```

The expected repository location in the current development environment is:

```text
C:\Users\ADMIN\source\repos\EcoWash
```

---

## 4. Configure Docker Infrastructure

EcoWash uses Docker Compose to manage its infrastructure dependencies.

The Compose file is located at:

```text
ClientService/docker-compose.yml
```

### Infrastructure Components

| Component | Docker image | Container | Port |
|---|---|---|---|
| PostgreSQL | postgres:16 | ecowash-postgres | 5432 |
| RabbitMQ | Configured in Compose | ecowash-rabbitmq | 5672 |
| RabbitMQ Management | Same RabbitMQ container | ecowash-rabbitmq | 15672 |

### Start PostgreSQL

From the repository root:

```powershell
docker compose -f .\ClientService\docker-compose.yml up -d postgres
```

### Start PostgreSQL and RabbitMQ

```powershell
docker compose -f .\ClientService\docker-compose.yml up -d postgres rabbitmq
```

Alternatively, from inside `ClientService`:

```powershell
docker compose up -d
```

The last command starts all services defined in that Compose file. Check the configured services before using it.

### Verify running containers

```powershell
docker ps
```

Check Compose service status:

```powershell
docker compose -f .\ClientService\docker-compose.yml ps
```

### Check PostgreSQL readiness

```powershell
docker exec ecowash-postgres pg_isready -U postgres
```

Expected result:

```text
/var/run/postgresql:5432 - accepting connections
```

---

## 5. Database Initialisation

EcoWash uses PostgreSQL with database-per-service architecture.

### Database Initialisation Script

The shared SQL initialisation script is located at:

```text
database/init/init-databases.sql
```

It is responsible for creating the service-specific PostgreSQL roles and databases.

The current database configuration is:

| Database | Database role |
|---|---|
| client_db | client_svc |
| identity_db | identity_svc |
| booking_db | booking_svc |
| washer_db | washer_svc |
| matching_db | matching_svc |
| payment_db | payment_svc |
| notification_db | notification_svc |

**Note:** The current database configuration contains `matching_db`, while the repository structure also contains `PricingService`. Confirm the intended service-to-database mapping before changing or adding database definitions.

### First-time Initialisation

The SQL file is mounted into PostgreSQL's initialisation directory through Docker Compose.

PostgreSQL automatically executes initialisation scripts when its data directory is first created.

For an existing database volume, these scripts are not automatically executed again.

To execute the script manually when required:

```powershell
docker cp .\database\init\init-databases.sql ecowash-postgres:/tmp/init-databases.sql
```

Execute:

```powershell
docker exec ecowash-postgres psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/init-databases.sql
```

Check the script for existing databases and roles before re-executing it.

### Verify Databases

```powershell
docker exec -it ecowash-postgres psql -U postgres -c "\l"
```

### Verify Roles

```powershell
docker exec -it ecowash-postgres psql -U postgres -c "\du"
```

### Apply Service Schemas and Seed Data

The repository also contains:

```text
database/init/apply-all.ps1
```

Inspect the script before execution:

```powershell
Get-Content .\database\init\apply-all.ps1
```

Execute it according to its defined parameters and prerequisites.

If no parameters are required:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\database\init\apply-all.ps1
```

The service-specific database scripts follow this convention:

```text
ClientService/
└── database/
    ├── schema.sql
    └── seed.sql
```

Each service maintains its own database structure and initial development data.

---

## 6. PostgreSQL Database Access

PostgreSQL is exposed on:

```text
localhost:5432
```

The development administrator connection uses:

| Setting | Value |
|---|---|
| Host | localhost |
| Port | 5432 |
| Username | postgres |
| Database | postgres |

The database initialisation script currently defines development service credentials. Check the SQL script for the actual configured values.

Do not use development credentials in production or commit real credentials to source control.

### Connect using Docker

```powershell
docker exec -it ecowash-postgres psql -U postgres
```

List databases:

```sql
\l
```

Connect to ClientService's database:

```sql
\c client_db
```

List tables:

```sql
\dt
```

Inspect a table:

```sql
\d table_name
```

Exit:

```sql
\q
```

---

## 7. Persistent Database Storage

PostgreSQL uses a Docker named volume to persist database data.

Configured volume:

```text
clientservice_pgdata
```

Container storage:

```text
/var/lib/postgresql/data
```

This ensures database records remain available when containers are stopped and restarted.

### Stop containers without deleting database data

```powershell
docker compose -f .\ClientService\docker-compose.yml down
```

### Start again

```powershell
docker compose -f .\ClientService\docker-compose.yml up -d
```

**WARNING:** Avoid the following command unless you intentionally want to delete the PostgreSQL data volume:

```powershell
docker compose down -v
```

Deleting the volume removes the persistent database contents.

---

## 8. Build and Run the .NET Applications

Once infrastructure is running and the required databases are initialised, you can build and run the .NET applications.

### Locate the solution

From the repository root:

```powershell
Get-ChildItem -Recurse -Filter *.sln
```

Restore dependencies:

```powershell
dotnet restore <PATH_TO_SOLUTION>
```

Build:

```powershell
dotnet build <PATH_TO_SOLUTION> -c Debug
```

### Run an individual microservice

For example, to run ClientService:

```powershell
dotnet run --project <PATH_TO_CLIENT_API_CSPROJ>
```

Repeat for the other service API projects and the gateway.

Use the actual project paths and configured launch profiles.

### Configuration

Before running an application, inspect its configuration files:

- `appsettings.json`
- `appsettings.Development.json`
- User Secrets
- Environment variables

Ensure the PostgreSQL connection strings reference the correct database, credentials and host.

When applications run directly on Windows, use `localhost` for PostgreSQL and RabbitMQ connections exposed by Docker.

When applications run inside Docker, use the relevant Compose service names as hostnames instead of `localhost`.

Never commit production passwords, signing keys, API keys or other secrets.

---

## 9. Common Docker Commands

| Command | Description |
|---|---|
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker images` | List downloaded images |
| `docker volume ls` | List Docker volumes |
| `docker network ls` | List Docker networks |
| `docker logs ecowash-postgres` | View PostgreSQL logs |
| `docker logs ecowash-rabbitmq` | View RabbitMQ logs |
| `docker restart ecowash-postgres` | Restart PostgreSQL |
| `docker exec -it ecowash-postgres bash` | Open a container shell |
| `docker compose down` | Stop and remove Compose containers and network |
| `docker compose up -d` | Start Compose services in the background |

---

## 10. Troubleshooting

### PostgreSQL is not accepting connections

Check:

```powershell
docker ps
docker logs ecowash-postgres
```

Then:

```powershell
docker exec ecowash-postgres pg_isready -U postgres
```

### Port 5432 is already in use

Identify the process:

```powershell
Get-NetTCPConnection -LocalPort 5432
```

Check whether another PostgreSQL instance or container is already using the port.

### Database does not exist

Check:

```powershell
docker exec -it ecowash-postgres psql -U postgres -c "\l"
```

Check the shared initialisation script and confirm it completed successfully.

### Tables are missing

Check whether the service-specific `schema.sql` has been applied.

Inspect the `apply-all.ps1` script and its execution output.

### Docker container is running but the API cannot connect

Check:

1. PostgreSQL container status.
2. Port mappings.
3. Database name.
4. Username and password.
5. Connection string hostname.
6. Whether the application runs on Windows or inside Docker.

Remember: `localhost` inside a container refers to that container itself, not the PostgreSQL container.

---

## 11. Recommended Onboarding Sequence

For a new developer joining EcoWash, follow this sequence:

- [ ] Install Git, Docker Desktop, .NET SDK and Visual Studio.
- [ ] Clone the EcoWash repository.
- [ ] Review the repository structure.
- [ ] Start Docker Desktop.
- [ ] Start PostgreSQL and RabbitMQ.
- [ ] Verify the infrastructure containers.
- [ ] Initialise the databases and service roles.
- [ ] Apply the service schemas and seed data.
- [ ] Verify database tables and permissions.
- [ ] Configure application connection strings and development secrets.
- [ ] Restore NuGet dependencies.
- [ ] Build the solution.
- [ ] Start the required microservices.
- [ ] Start EcoWash.Gateway.
- [ ] Test the API endpoints using Postman or Swagger.

---

## 12. Development Guidelines

To maintain consistency across the EcoWash microservices:

1. Each microservice owns its business logic and database.
2. Avoid directly accessing another service's database.
3. Use API communication or messaging for cross-service integration.
4. Keep database scripts inside the respective service's `database` folder.
5. Keep shared database initialisation scripts in the repository-level `database/init` directory.
6. Do not commit credentials or local development secrets.
7. Use Docker Compose for local infrastructure.
8. Test changes before merging them into the main development branch.

---

## 13. Useful References

- Docker Documentation: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- RabbitMQ Documentation: https://www.rabbitmq.com/docs
- Microsoft .NET Documentation: https://learn.microsoft.com/dotnet/

---

**End of EcoWash Developer Onboarding Guide**

*This document describes the current development setup. Update it whenever Docker Compose configuration, database initialisation, service ports or application startup requirements change.*
