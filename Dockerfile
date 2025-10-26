# Base stage with Bun
FROM oven/bun:1 AS base
WORKDIR /app

# Dependencies stage
FROM base AS dependencies

# Copy package files for all workspaces
COPY package.json bun.lock ./
COPY packages/backend/package.json ./packages/backend/
COPY packages/frontend/package.json ./packages/frontend/
COPY packages/shared/package.json ./packages/shared/
COPY packages/tokenizer/package.json ./packages/tokenizer/

# Also copy patches directory (needed for postgres@3.4.5)
COPY patches ./patches

# Install dependencies with Bun workspaces
RUN bun install --frozen-lockfile

# Copy all source code
COPY . .

# Frontend build stage
FROM base AS frontend-builder
WORKDIR /app
COPY --from=dependencies /app .

# Build frontend
RUN cd packages/frontend && bun run build

# Production stage - Backend
FROM base AS backend
WORKDIR /app

# Copy root node_modules (workspace dependencies)
COPY --from=dependencies /app/node_modules ./node_modules

# Copy package-specific node_modules
COPY --from=dependencies /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=dependencies /app/packages/shared/node_modules ./packages/shared/node_modules

# Copy the shared package (needed by backend)
COPY --from=dependencies /app/packages/shared ./packages/shared

# Copy source code
COPY packages/backend ./packages/backend
COPY packages/db ./packages/db

WORKDIR /app/packages/backend

EXPOSE 3333

# Run migrations and start the server
CMD ["bun", "run", "start"]

# Production stage - Frontend
FROM base AS frontend
WORKDIR /app

# Copy root node_modules
COPY --from=dependencies /app/node_modules ./node_modules

# Copy package-specific node_modules
COPY --from=dependencies /app/packages/frontend/node_modules ./packages/frontend/node_modules
COPY --from=dependencies /app/packages/shared/node_modules ./packages/shared/node_modules

# Copy the shared package
COPY --from=dependencies /app/packages/shared ./packages/shared

# Copy built frontend
COPY --from=frontend-builder /app/packages/frontend/.next ./packages/frontend/.next
COPY --from=frontend-builder /app/packages/frontend/public ./packages/frontend/public
COPY --from=frontend-builder /app/packages/frontend/next.config.ts ./packages/frontend/
COPY packages/frontend ./packages/frontend

WORKDIR /app/packages/frontend

# Make load-env.sh executable
RUN chmod +x load-env.sh

EXPOSE 8080

CMD ["bun", "run", "start"]
