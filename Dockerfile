# Base stage with Bun
FROM oven/bun:1 AS base
WORKDIR /app

# Dependencies stage
FROM base AS dependencies
COPY package.json bun.lock ./
COPY packages/backend/package.json ./packages/backend/
COPY packages/frontend/package.json ./packages/frontend/
COPY packages/shared/package.json ./packages/shared/
COPY packages/tokenizer/package.json ./packages/tokenizer/

RUN bun install --frozen-lockfile

# Copy all source code
COPY . .

# Frontend build stage
FROM base AS frontend-builder
WORKDIR /app
COPY --from=dependencies /app .
RUN cd packages/frontend && bun run build

# Production stage - Backend
FROM base AS backend
WORKDIR /app

# Copy dependencies
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=dependencies /app/packages/shared/node_modules ./packages/shared/node_modules

# Copy source code
COPY packages/backend ./packages/backend
COPY packages/shared ./packages/shared
COPY packages/db ./packages/db

WORKDIR /app/packages/backend

EXPOSE 3333

# Run migrations and start the server
CMD ["bun", "run", "start"]

# Production stage - Frontend
FROM base AS frontend
WORKDIR /app

# Copy dependencies
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/packages/frontend/node_modules ./packages/frontend/node_modules

# Copy built frontend
COPY --from=frontend-builder /app/packages/frontend/.next ./packages/frontend/.next
COPY --from=frontend-builder /app/packages/frontend/public ./packages/frontend/public
COPY packages/frontend ./packages/frontend

WORKDIR /app/packages/frontend

EXPOSE 8080

# Make load-env.sh executable
RUN chmod +x load-env.sh

CMD ["bun", "run", "start"]
