# Define an ARG to make the image source configurable if needed
# Must be declared before any FROM that uses it
ARG LAKEKEEPER_IMAGE=quay.io/lakekeeper/catalog:latest-main

# Stage 1: Extract the lakekeeper binary from the distroless image
FROM ${LAKEKEEPER_IMAGE} AS lakekeeper-binary
# This stage just holds the binary for copying

# Stage 2: Use Debian slim as the base (has shell support and glibc compatibility)
FROM debian:bookworm-slim AS lakekeeper-app

# Install shell and basic utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set the base environment variables
ENV LAKEKEEPER__PG_ENCRYPTION_KEY="This-is-NOT-Secure!"
ENV LAKEKEEPER__AUTHZ_BACKEND="allowall"

# Copy the lakekeeper binary and preserve directory structure
# Copy everything from /home/nonroot to maintain any library dependencies
RUN mkdir -p /home/nonroot
COPY --from=lakekeeper-binary /home/nonroot/ /home/nonroot/
RUN chmod +x /home/nonroot/lakekeeper

# Copy and set up the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the entrypoint script to run migration and then the server
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# The default command will be "serve", which is passed to the entrypoint script
CMD ["serve"]

# Aiven App Runtime uses port 8080 by default, check if the Lakekeeper image respects
# a PORT variable or if you need to configure it to listen on 8080
# EXPOSE 8181