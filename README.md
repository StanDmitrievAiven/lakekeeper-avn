# Lakekeeper on Aiven App Runtime

This repository contains a Docker-based deployment configuration for [Lakekeeper](https://lakekeeper.io/) designed to run on Aiven's App Runtime platform.

## Overview

Lakekeeper is a data catalog and governance platform that helps you discover, manage, and govern your data assets. This project provides a containerized setup that:

- Extracts the Lakekeeper binary from the official distroless image
- Runs it on a Debian-based image with shell support (required for migrations)
- Automatically runs database migrations on startup
- Configures the application for Aiven App Runtime deployment

## Prerequisites

- Aiven account with App Runtime access
- PostgreSQL database service in Aiven (for Lakekeeper's metadata storage)
- Git repository access (this repo)

## Required Environment Variables

The following environment variables **must** be set in your Aiven App Runtime configuration:

### Database Connection (Required)

- `LAKEKEEPER__PG_DATABASE_URL_READ` - PostgreSQL connection string for read operations
- `LAKEKEEPER__PG_DATABASE_URL_WRITE` - PostgreSQL connection string for write operations

Example format:
```
postgresql://username:password@hostname:port/database
```

### Configuration (Optional)

- `LAKEKEEPER__PG_ENCRYPTION_KEY` - Encryption key for sensitive data (default: "This-is-NOT-Secure!")
- `LAKEKEEPER__AUTHZ_BACKEND` - Authorization backend (default: "allowall")
- `LAKEKEEPER__LISTEN_PORT` - Port for Lakekeeper to listen on (default: 8181)

## Deployment to Aiven App Runtime

1. **Create a PostgreSQL Service** in Aiven (if you don't have one)
   - This will store Lakekeeper's metadata and catalog information

2. **Create an App Runtime Application**
   - Source: Point to this GitHub repository (`https://github.com/StanDmitrievAiven/lakekeeper-avn.git`)
   - Branch: `main`

3. **Configure Environment Variables**
   - Add the required database connection strings
   - Optionally configure other Lakekeeper settings

4. **Configure Port**
   - Open port **8181** in your App Runtime configuration
   - Lakekeeper's web UI will be accessible on this port

5. **Deploy**
   - Aiven will automatically build and deploy your application
   - Check the logs to verify successful startup and migration

## Accessing the UI

Once deployed, access the Lakekeeper web UI at:

```
https://<your-app-hostname>:8181/ui/
```

**Note:** By default, authentication is disabled (`allowall` backend). For production use, configure OIDC authentication or implement additional security measures.

## Project Structure

```
.
├── Dockerfile          # Multi-stage build configuration
├── entrypoint.sh      # Startup script that runs migrations and starts the server
├── .gitattributes     # Git configuration for line endings
└── README.md          # This file
```

## How It Works

1. **Build Stage 1**: Extracts the Lakekeeper binary from the official distroless image
2. **Build Stage 2**: Creates a Debian-based image with:
   - The Lakekeeper binary copied from stage 1
   - Shell support for running migrations
   - Entrypoint script for automated startup

3. **Runtime**: The entrypoint script:
   - Validates required environment variables
   - Runs database migrations automatically
   - Starts the Lakekeeper server

## Customization

### Using a Different Lakekeeper Image

To use a different Lakekeeper image version, set the build argument:

```dockerfile
ARG LAKEKEEPER_IMAGE=quay.io/lakekeeper/catalog:v0.10.3
```

### Adding Authentication

To enable OIDC authentication, set these environment variables:

```
LAKEKEEPER__OPENID_PROVIDER_URI=<your-oidc-provider-uri>
LAKEKEEPER__OPENID_AUDIENCE=<your-audience>
LAKEKEEPER__UI__OPENID_CLIENT_ID=<your-client-id>
LAKEKEEPER__UI__OPENID_SCOPE=openid profile email
```

See [Lakekeeper Authentication Documentation](https://docs.lakekeeper.io/docs/0.10.x/authentication/) for details.

## Troubleshooting

### Database Connection Issues

- Verify your PostgreSQL connection strings are correct
- Ensure the database is accessible from App Runtime
- Check that the database user has necessary permissions

### Migration Failures

- Check the application logs for specific migration errors
- Ensure the database is empty or compatible with Lakekeeper's schema
- Verify database connection strings are valid

### Port Configuration

- Ensure port 8181 is opened in your App Runtime configuration
- Check that no other service is using the same port
- Verify firewall rules allow traffic on port 8181

## Security Considerations

⚠️ **Important**: The default configuration uses `allowall` authorization backend, which means **authentication is disabled**. This is suitable for development but **NOT for production**.

For production deployments:
1. Configure OIDC authentication with a proper identity provider
2. Use strong encryption keys (`LAKEKEEPER__PG_ENCRYPTION_KEY`)
3. Restrict network access to the application
4. Enable HTTPS/TLS encryption

## Resources

- [Lakekeeper Documentation](https://docs.lakekeeper.io)
- [Lakekeeper GitHub](https://github.com/lakekeeperio/lakekeeper)
- [Aiven App Runtime Documentation](https://docs.aiven.io/docs/products/app-runtime)

## License

This deployment configuration is provided as-is. Please refer to Lakekeeper's license for the application itself.

