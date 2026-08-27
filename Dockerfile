#
# CTFile Dockerfile
#
# https://github.com/KyokoMiki/docker-ctfile
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG CTFILE_VERSION=5.1.15
ARG CTFILE_URL=https://imgstatic.ctcontents.com/apps/CTFile-${CTFILE_VERSION}.AppImage

# Stage 1: Extract AppImage using Debian
FROM debian:13-slim AS extractor
ARG CTFILE_URL
ARG CTFILE_VERSION

WORKDIR /tmp

# Install required tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        aria2 \
        ca-certificates \
        file && \
    rm -rf /var/lib/apt/lists/*

# Download and extract AppImage
RUN echo "Downloading CTFile ${CTFILE_VERSION}..." && \
    aria2c -d /tmp -o CTFile.AppImage "${CTFILE_URL}" && \
    chmod +x /tmp/CTFile.AppImage && \
    # Extract AppImage without running it
    cd /tmp && \
    /tmp/CTFile.AppImage --appimage-extract && \
    # Move to a clean directory
    mkdir -p /opt/ctfile && \
    mv squashfs-root/* /opt/ctfile/ && \
    # List contents for debugging
    ls -la /opt/ctfile/

# Stage 2: Build final image with Debian
FROM jlesage/baseimage-gui:debian-13-v4

ARG DOCKER_IMAGE_VERSION
ARG CTFILE_VERSION

# Define working directory.
WORKDIR /tmp

# Prevent systemd from being installed
RUN echo 'Package: systemd\nPin: release *\nPin-Priority: -1' > /etc/apt/preferences.d/no-systemd && \
    echo 'Package: systemd-sysv\nPin: release *\nPin-Priority: -1' >> /etc/apt/preferences.d/no-systemd && \
    # Ensure /var/log is a directory for fontconfig
    rm -rf /var/log && mkdir -p /var/log

# Install runtime dependencies for CTFile (only missing libraries from ldd output)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        dbus-daemon \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libatspi2.0-0 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libegl1 \
        libexpat1 \
        libgbm1 \
        libgl1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libx11-6 \
        libxcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxkbcommon0 \
        libxrandr2 && \
    rm -rf /var/lib/apt/lists/*

# Copy extracted AppImage from extractor stage
COPY --from=extractor /opt/ctfile /opt/ctfile

# Make application files readable by any user
RUN chmod -R a+rX /opt/ctfile

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://www.ctfile.com/img/logo.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Ensure startapp.sh is executable
RUN chmod +x /startapp.sh

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "CTFile" && \
    set-cont-env APP_VERSION "$CTFILE_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Set public environment variables.
ENV \
    KEEP_APP_RUNNING=1

# Define mountable directories.
VOLUME ["/config"]

# Metadata.
LABEL \
      org.label-schema.name="ctfile" \
      org.label-schema.description="Docker container for CTFile" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/KyokoMiki/docker-ctfile" \
      org.label-schema.schema-version="1.0"
