#!/bin/sh

set -u # Treat unset variables as an error.

# Set APPDIR so AppRun can find the executable
export APPDIR=/opt/ctfile

# Set DISPLAY for X server
export DISPLAY=:0

# Start the D-Bus system bus if it is not already running
if [ ! -S /run/dbus/system_bus_socket ]; then
    mkdir -p /run/dbus
    rm -f /run/dbus/pid
    dbus-daemon --config-file=/etc/dbus-1/system-ctfile.conf --fork || echo "Warning: failed to start D-Bus system bus"
fi

# Check if AppRun exists
if [ ! -f "$APPDIR/AppRun" ]; then
    echo "Error: AppRun not found in $APPDIR"
    exit 1
fi

# Start CTFile via AppRun with Electron flags for Docker
# Use exec so the exit status is properly propagated
cd "$APPDIR"
exec "$APPDIR/AppRun" --no-sandbox "$@"
