#!/usr/bin/env bash
set -euo pipefail

# Ensure WAL archive directory exists and is owned by postgres so archive_command can write.
mkdir -p /var/lib/postgresql/wal-archive
chown -R postgres:postgres /var/lib/postgresql/wal-archive

exec /usr/local/bin/docker-entrypoint.sh "$@"
