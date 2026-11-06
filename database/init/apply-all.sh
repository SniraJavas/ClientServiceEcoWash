#!/usr/bin/env bash
set -Eeuo pipefail

# PostgreSQL connection settings
export PGHOST="${PGHOST:-postgres}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"
export PGPASSWORD="${PGPASSWORD:-postgres}"

# Set DEV=true to apply development sample data.
DEV="${DEV:-false}"

SERVICES=(
    "IdentityService:identity_db:identity_svc"
    "ClientService:client_db:client_svc"
    "WasherService:washer_db:washer_svc"
    "BookingService:booking_db:booking_svc"
    "MatchingService:matching_db:matching_svc"
    "PaymentService:payment_db:payment_svc"
    "NotificationService:notification_db:notification_svc"
)

apply_sql_file() {
    local db="$1"
    local file="$2"

    echo "   Applying $(basename "$file")"

    psql -v ON_ERROR_STOP=1 \
        --username="$PGUSER" \
        --dbname="$db" \
        --file="$file"
}

for entry in "${SERVICES[@]}"; do
    IFS=':' read -r service db role <<< "$entry"

   DIR="/workspace/${service}/database"

    echo ""
    echo "========================================"
    echo "Service: $service"
    echo "Database: $db"
    echo "========================================"

    if [[ ! -d "$DIR" ]]; then
        echo "ERROR: Database directory not found: $DIR"
        exit 1
    fi

    # Wait until PostgreSQL is ready.
    until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
        echo "Waiting for PostgreSQL..."
        sleep 2
    done

    # 1. Apply baseline schema if schema_migrations does not exist.
    HAS_TABLE=$(psql -tA -U "$PGUSER" -d "$db" \
        -c "SELECT to_regclass('public.schema_migrations') IS NOT NULL;")

    if [[ "$HAS_TABLE" != "t" ]]; then
        echo "Applying baseline schema..."
        apply_sql_file "$db" "$DIR/schema.sql"
    else
        echo "Baseline schema already applied."
    fi

    # 2. Apply pending migrations in filename order.
    if [[ -d "$DIR/migrations" ]]; then
        while IFS= read -r migration; do
            version="$(basename "$migration" .sql)"

            DONE=$(psql -tA -U "$PGUSER" -d "$db" \
                -c "SELECT EXISTS (
                    SELECT 1 FROM schema_migrations
                    WHERE version = '$version'
                );")

            if [[ "$DONE" != "t" ]]; then
                echo "Applying migration: $version"
                apply_sql_file "$db" "$migration"
            else
                echo "Migration already applied: $version"
            fi
        done < <(find "$DIR/migrations" -maxdepth 1 -type f -name '*.sql' | sort)
    fi

    # 3. Apply reference seed data.
    if [[ -f "$DIR/seed.sql" ]]; then
        apply_sql_file "$db" "$DIR/seed.sql"
    fi

    # 4. Apply development sample data only when DEV=true.
    if [[ "$DEV" == "true" && -f "$DIR/seed.dev.sql" ]]; then
        apply_sql_file "$db" "$DIR/seed.dev.sql"
    fi

done

echo ""
echo "========================================"
echo "EcoWash database initialization completed."
echo "========================================"