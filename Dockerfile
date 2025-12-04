# Define an ARG to make the image source configurable if needed
# Must be declared before any FROM that uses it
ARG LAKEKEEPER_IMAGE=quay.io/lakekeeper/catalog:latest-main

# Stage 1: Extract the lakekeeper binary from the distroless image
FROM ${LAKEKEEPER_IMAGE} AS lakekeeper-binary
# This stage just holds the binary for copying

# Stage 2: Use Alpine as the base (has shell support)
FROM alpine:latest AS lakekeeper-app

# Install any required runtime dependencies (if needed)
# Most Alpine images are minimal, but we might need ca-certificates for HTTPS
RUN apk add --no-cache ca-certificates

# Set the base environment variables
ENV LAKEKEEPER__PG_ENCRYPTION_KEY="This-is-NOT-Secure!"
ENV LAKEKEEPER__AUTHZ_BACKEND="allowall"

# Copy the lakekeeper binary and any necessary files from the distroless image
# Create the same directory structure as the original image
RUN mkdir -p /home/nonroot
COPY --from=lakekeeper-binary /home/nonroot/lakekeeper /home/nonroot/lakekeeper

# Verify the binary exists and is executable
RUN ls -la /home/nonroot/lakekeeper || echo "Binary not found at expected location"
RUN chmod +x /home/nonroot/lakekeeper 2>/dev/null || true

# Also try to find and copy the binary if it's in a different location
RUN find /home -name "lakekeeper" -type f 2>/dev/null || echo "Searching for lakekeeper binary..."

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