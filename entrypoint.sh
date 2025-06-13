#!/bin/bash
set -e

# Remove old server PID if exists
rm -f /app/tmp/pids/server.pid

# Run the container command
exec "$@"