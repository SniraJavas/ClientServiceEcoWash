<#
.SYNOPSIS
  Applies schema, pending migrations and seeds to every EcoWash database running in Docker.
.EXAMPLE
  .\apply-all.ps1          # schema + migrations + reference data (safe for any environment)
.EXAMPLE
  .\apply-all.ps1 -Dev     # also loads seed.dev.sql sample data (local development only)
#>
param(
    [switch]$Dev,
    [string]$Container = "ecowash-postgres"
)

# Native tools write progress to stderr, so check $LASTEXITCODE explicitly instead of stopping.
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot

$services = @(
    @{ Folder = "IdentityService";     Db = "identity_db";     Role = "identity_svc" },
    @{ Folder = "ClientService";       Db = "client_db";       Role = "client_svc" },
    @{ Folder = "WasherService";       Db = "washer_db";       Role = "washer_svc" },
    @{ Folder = "BookingService";      Db = "booking_db";      Role = "booking_svc" },
    @{ Folder = "MatchingService";     Db = "matching_db";     Role = "matching_svc" },
    @{ Folder = "PaymentService";      Db = "payment_db";      Role = "payment_svc" },
    @{ Folder = "NotificationService"; Db = "notification_db"; Role = "notification_svc" }
)

function Invoke-Query($s, [string]$sql) {
    $out = docker exec $Container psql -h localhost -U $s.Role -d $s.Db -tA -c $sql
    if ($LASTEXITCODE -ne 0) { throw "Query failed on $($s.Db): $sql" }
    return ($out -join "").Trim()
}

function Invoke-SqlFile($s, [string]$path) {
    # docker cp avoids PowerShell piping/encoding problems
    docker cp $path "${Container}:/tmp/apply.sql" | Out-Null
    docker exec $Container psql -h localhost -U $s.Role -d $s.Db -v ON_ERROR_STOP=1 -q -f /tmp/apply.sql
    if ($LASTEXITCODE -ne 0) { throw "Failed: $path" }
}

foreach ($s in $services) {
    $dir = Join-Path $root "$($s.Folder)\database"
    Write-Host "== $($s.Db)" -ForegroundColor Cyan

    # 1. baseline schema, only on a fresh database
    $hasTable = Invoke-Query $s "SELECT to_regclass('public.schema_migrations') IS NOT NULL;"
    if ($hasTable -ne "t") {
        Write-Host "   schema.sql"
        Invoke-SqlFile $s (Join-Path $dir "schema.sql")
    } else {
        Write-Host "   schema.sql (already applied)"
    }

    # 2. pending migrations, in file-name order. Each file records itself in schema_migrations.
    $migrations = Get-ChildItem (Join-Path $dir "migrations") -Filter *.sql -ErrorAction SilentlyContinue | Sort-Object Name
    foreach ($m in $migrations) {
        $version = $m.BaseName
        $done = Invoke-Query $s "SELECT 1 FROM schema_migrations WHERE version = '$version';"
        if ($done -ne "1") {
            Write-Host "   migration $version"
            Invoke-SqlFile $s $m.FullName
        }
    }

    # 3. reference data (idempotent), then optional dev sample data
    $seed = Join-Path $dir "seed.sql"
    if (Test-Path $seed) { Write-Host "   seed.sql"; Invoke-SqlFile $s $seed }
    if ($Dev) {
        $devSeed = Join-Path $dir "seed.dev.sql"
        if (Test-Path $devSeed) { Write-Host "   seed.dev.sql"; Invoke-SqlFile $s $devSeed }
    }
}
Write-Host "Done." -ForegroundColor Green
