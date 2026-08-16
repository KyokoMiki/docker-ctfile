#!/bin/sh

set -u # Treat unset variables as an error.

# Set APPDIR so AppRun can find the executable
export APPDIR=/opt/ctfile

# Set DISPLAY for X server
export DISPLAY=:0

# Check if AppRun exists
if [ ! -f "$APPDIR/AppRun" ]; then
    echo "Error: AppRun not found in $APPDIR"
    exit 1
fi

# Start CTFile via AppRun with Electron flags for Docker
# Use exec so the exit status is properly propagated
cd "$APPDIR"
exec "$APPDIR/AppRun" --no-sandbox "$@"
