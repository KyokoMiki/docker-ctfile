#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Create config directory
mkdir -p /config

# Take ownership of the storage directory.
take-ownership --not-recursive --skip-if-writable /storage

# Make sure CTFile has execute permissions
chmod +x /opt/ctfile/AppRun 2>/dev/null || true
chmod +x /opt/ctfile/ctfile 2>/dev/null || true
chmod +x /opt/ctfile/ctfile-desktop 2>/dev/null || true

# Prepare the D-Bus system bus runtime directory (writable by the app user)
mkdir -p /run/dbus
rm -f /run/dbus/pid /run/dbus/system_bus_socket
chmod 1777 /run/dbus

# Set AppImage environment
export APPIMAGE_EXTRACT_AND_RUN=1

echo "CTFile initialization complete."

# vim:ft=sh:ts=4:sw=4:et:sts=4
