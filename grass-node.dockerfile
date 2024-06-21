FROM theasp/novnc:latest

# Set build arguments
ARG EXTENSION_IDS
ARG EXTENSION_URLS
ARG CRX_DOWNLOAD_URLS

# Set environment variables
# Comma-separated list of extension IDs (extension chrome webstore id)
ENV EXTENSION_IDS=${EXTENSION_IDS}
# Comma-separated list of extension URLs (app dashboard website url)
ENV EXTENSION_URLS=${EXTENSION_URLS}
# Comma-separated list of CRX download URLs (either direct URLs or Chrome Web Store URLs)
ENV CRX_DOWNLOAD_URLS=${CRX_DOWNLOAD_URLS}
# In case of error multiply all backoff-timings of this value
ENV MAX_RETRY_MULTIPLIER=3


# Install necessary packages then clean up to reduce image size
RUN set -ex; \
    apt update && \
    apt upgrade -y && \
    apt install -qqy \
    curl \
    wget \
    git \
    chromium \
    chromium-driver \
    python3 \
    python3-requests \
    python3-selenium \
    coreutils \
    bash && \
    apt autoremove --purge -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the Supervisor configuration and Python script
COPY grass-node_main.py /app/grass-node_main.py
#COPY conf.d/grass-node.conf /app/conf.d/grass-node.conf

# Copy the entrypoint wrapper script
COPY entrypoint-wrapper.sh /app/entrypoint-wrapper.sh
RUN chmod +x /app/entrypoint-wrapper.sh

WORKDIR /app

# Expose noVNC port
EXPOSE 8080

# Use the base image's entrypoint
ENTRYPOINT ["/app/entrypoint-wrapper.sh"]
