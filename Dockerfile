# Define an ARG to make the image source configurable if needed
# Must be declared before any FROM that uses it
ARG LAKEKEEPER_IMAGE=quay.io/lakekeeper/catalog:latest-main

# Stage 1: Use a shell-enabled image to prepare files with correct permissions
FROM alpine:latest AS file-preparer
COPY entrypoint.sh /tmp/entrypoint.sh
RUN chmod +x /tmp/entrypoint.sh

# Stage 2: Use the specified Lakekeeper image from your docker-compose
FROM ${LAKEKEEPER_IMAGE} AS lakekeeper-app

# Set the base environment variables
ENV LAKEKEEPER__PG_ENCRYPTION_KEY="This-is-NOT-Secure!"
ENV LAKEKEEPER__AUTHZ_BACKEND="allowall"

# Copy the entrypoint script from the preparer stage (already has executable permissions)
COPY --from=file-preparer /tmp/entrypoint.sh /usr/local/bin/entrypoint.sh

# Use the entrypoint script to run migration and then the server
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# The default command will be "serve", which is passed to the entrypoint script
CMD ["serve"]

# Aiven App Runtime uses port 8080 by default, check if the Lakekeeper image respects
# a PORT variable or if you need to configure it to listen on 8080
# EXPOSE 8181