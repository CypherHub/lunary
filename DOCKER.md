# Docker Setup for Lunary

This document provides comprehensive instructions for running Lunary using Docker and Docker Compose.

## Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd lunary-some
```

### 2. Environment Configuration
Create a `.env` file in the root directory with the following required variables:

```bash
# Required Configuration
DATABASE_URL=postgresql://lunary:lunary123@db:5432/lunary
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
APP_URL=http://localhost:8080
API_URL=http://localhost:3333
NEXT_PUBLIC_API_URL=http://localhost:3333

# Optional Configuration
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM=noreply@lunary.ai

# OAuth Providers (optional)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

# Stripe (optional)
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=

# Sentry (optional)
SENTRY_DSN=
```

### 3. Run with Docker Compose

#### Production Mode (Recommended)
```bash
# Start the full application (backend + frontend + database)
docker-compose up app

# Or run in background
docker-compose up -d app
```

#### Development Mode
```bash
# Start in development mode with hot reloading
docker-compose --profile development up dev
```

#### Individual Services
```bash
# Backend only
docker-compose --profile backend-only up backend

# Frontend only (requires backend to be running)
docker-compose --profile frontend-only up frontend
```

## Access Points

- **Frontend Dashboard**: http://localhost:8080
- **Backend API**: http://localhost:3333
- **Database**: localhost:5432

## Docker Compose Services

### `app` (Production)
- Runs both backend and frontend in a single container
- Automatically runs database migrations on startup
- Includes health checks
- Best for production deployments

### `dev` (Development)
- Runs both backend and frontend in development mode
- Includes hot reloading with volume mounts
- Enables debug logging
- Best for local development

### `backend` (Backend Only)
- Runs only the backend API service
- Useful for API-only deployments
- Includes health checks

### `frontend` (Frontend Only)
- Runs only the frontend service
- Requires backend to be running separately
- Useful for frontend-only deployments

### `db` (Database)
- PostgreSQL 15 database
- Includes health checks
- Persistent data storage
- Automatically runs migrations from `packages/db/`

## Environment Variables

### Required Variables
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret key for JWT token signing
- `APP_URL`: Frontend application URL
- `API_URL`: Backend API URL
- `NEXT_PUBLIC_API_URL`: Public API URL for frontend

### Optional Variables
- `SMTP_*`: Email configuration for notifications
- `GOOGLE_*`, `GITHUB_*`: OAuth provider credentials
- `STRIPE_*`: Billing integration
- `SENTRY_DSN`: Error tracking
- `LUNARY_DEBUG`: Enable debug logging

## Docker Commands

### Build Images
```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build app
```

### View Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs app
docker-compose logs backend
docker-compose logs frontend
docker-compose logs db
```

### Database Operations
```bash
# Run migrations manually
docker-compose exec app bun run migrate:db

# Access database shell
docker-compose exec db psql -U lunary -d lunary

# Reset database
docker-compose down -v
docker-compose up db
```

### Cleanup
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v

# Remove all images
docker-compose down --rmi all
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Ensure PostgreSQL is running and accessible
   - Check `DATABASE_URL` format
   - Verify database credentials

2. **Port Already in Use**
   - Change port mappings in `docker-compose.yml`
   - Stop conflicting services

3. **Migration Errors**
   - Check database permissions
   - Ensure database exists
   - Run migrations manually: `docker-compose exec app bun run migrate:db`

4. **Frontend Build Errors**
   - Check Node.js version compatibility
   - Clear build cache: `docker-compose build --no-cache frontend`

### Health Checks

All services include health checks. Check status with:
```bash
docker-compose ps
```

### Debug Mode

Enable debug logging by setting:
```bash
LUNARY_DEBUG=true
```

## Production Deployment

For production deployments:

1. **Security**
   - Change all default passwords and secrets
   - Use strong JWT secrets
   - Enable HTTPS
   - Configure proper firewall rules

2. **Database**
   - Use managed PostgreSQL service
   - Enable backups
   - Configure connection pooling

3. **Monitoring**
   - Set up Sentry for error tracking
   - Configure log aggregation
   - Set up health check monitoring

4. **Scaling**
   - Use load balancers for multiple instances
   - Consider separate database instances
   - Implement proper caching strategies

## Development Workflow

1. **Local Development**
   ```bash
   # Start development environment
   docker-compose --profile development up dev
   
   # Make changes to code (hot reloading enabled)
   # View logs: docker-compose logs dev
   ```

2. **Testing Changes**
   ```bash
   # Run tests
   docker-compose exec dev bun run test
   ```

3. **Database Changes**
   ```bash
   # Create new migration
   # Add SQL file to packages/db/
   # Restart services to apply
   docker-compose restart app
   ```

## Support

For issues and questions:
- Check the logs: `docker-compose logs`
- Verify environment variables
- Ensure all required services are running
- Check the main project README for additional setup instructions
