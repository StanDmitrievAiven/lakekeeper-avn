#!/bin/bash
set -e

# --- Environment Variable Check ---
# Ensure the critical DB connection strings are set
if [ -z "$LAKEKEEPER__PG_DATABASE_URL_READ" ] || [ -z "$LAKEKEEPER__PG_DATABASE_URL_WRITE" ]; then
    echo "ERROR: Database connection variables LAKEKEEPER__PG_DATABASE_URL_READ and LAKEKEEPER__PG_DATABASE_URL_WRITE must be set."
    exit 1
fi
echo "Database configuration variables found. Proceeding with application startup."
echo "---"

# --- Run Migration ---
echo "Starting database migration using Lakekeeper binary..."
# The 'migrate' command connects to the DB using the environment variables
/home/nonroot/lakekeeper migrate

if [ $? -eq 0 ]; then
    echo "✅ Database migration complete and successful."
    echo "---"
else
    echo "❌ Database migration failed."
    exit $?
fi

# --- Start Server ---
echo "Starting Lakekeeper service with command: $@"
# Execute the command passed to the container (which is typically 'serve')
exec /home/nonroot/lakekeeper "$@"
