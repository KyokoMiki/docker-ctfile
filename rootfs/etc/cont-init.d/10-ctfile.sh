#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Create config directory
mkdir -p /config

# Make sure CTFile has execute permissions
chmod +x /opt/ctfile/AppRun 2>/dev/null || true
chmod +x /opt/ctfile/ctfile 2>/dev/null || true
chmod +x /opt/ctfile/ctfile-desktop 2>/dev/null || true

# Set AppImage environment
export APPIMAGE_EXTRACT_AND_RUN=1

echo "CTFile initialization complete."

# vim:ft=sh:ts=4:sw=4:et:sts=4
