# Stage 1: Use the specified Lakekeeper image from your docker-compose
# Define an ARG to make the image source configurable if needed
ARG LAKEKEEPER_IMAGE=quay.io/lakekeeper/catalog:latest-main
FROM ${LAKEKEEPER_IMAGE} AS lakekeeper-app

# Set the base environment variables
ENV LAKEKEEPER__PG_ENCRYPTION_KEY="This-is-NOT-Secure!"
ENV LAKEKEEPER__AUTHZ_BACKEND="allowall"

# Copy the entrypoint script into the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the entrypoint script to run migration and then the server
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# The default command will be "serve", which is passed to the entrypoint script
CMD ["serve"]

# Aiven App Runtime uses port 8080 by default, check if the Lakekeeper image respects
# a PORT variable or if you need to configure it to listen on 8080
# EXPOSE 8181