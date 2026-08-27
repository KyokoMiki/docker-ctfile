#!/bin/sh

set -u # Treat unset variables as an error.

# Set APPDIR so AppRun can find the executable
export APPDIR=/opt/ctfile

# Set DISPLAY for X server
export DISPLAY=:0

# Start the D-Bus system and session buses if not already running.
# Sockets live under /tmp so they can be created without root privileges.
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/tmp/dbus/system_bus_socket
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus/session_bus_socket
mkdir -p /tmp/dbus
if [ ! -S /tmp/dbus/system_bus_socket ]; then
    dbus-daemon --config-file=/etc/dbus-1/system-ctfile.conf --fork || echo "Warning: failed to start D-Bus system bus"
fi
if [ ! -S /tmp/dbus/session_bus_socket ]; then
    dbus-daemon --session --address="$DBUS_SESSION_BUS_ADDRESS" --fork || echo "Warning: failed to start D-Bus session bus"
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
