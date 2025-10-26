# Multi-stage Dockerfile for Node.js/npm

# Base stage with Node.js 20
FROM node:20-alpine AS base
WORKDIR /app

# Dependencies stage
FROM base AS dependencies

# Copy package files for all workspaces
COPY package.json package-lock.json* ./
COPY packages/backend/package.json ./packages/backend/
COPY packages/frontend/package.json ./packages/frontend/
COPY packages/shared/package.json ./packages/shared/
COPY packages/tokenizer/package.json ./packages/tokenizer/

# Install root dependencies
RUN npm ci

# Install workspace dependencies
RUN npm ci --workspace=packages/backend
RUN npm ci --workspace=packages/frontend
RUN npm ci --workspace=packages/shared
RUN npm ci --workspace=packages/tokenizer

# Frontend build stage
FROM base AS frontend-builder
WORKDIR /app

# Copy all files
COPY . .

# Copy node_modules from dependencies
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=dependencies /app/packages/frontend/node_modules ./packages/frontend/node_modules
COPY --from=dependencies /app/packages/shared/node_modules ./packages/shared/node_modules
COPY --from=dependencies /app/packages/tokenizer/node_modules ./packages/tokenizer/node_modules

# Build frontend
RUN cd packages/frontend && npm run build

# Production stage - Backend
FROM node:20-alpine AS backend
WORKDIR /app

# Copy package files
COPY packages/backend/package.json ./packages/backend/
COPY packages/shared/package.json ./packages/shared/
COPY package.json ./

# Install production dependencies only
RUN npm ci --omit=dev --workspace=packages/backend --prefix packages/backend
RUN npm ci --omit=dev --workspace=packages/shared --prefix packages/shared

# Copy source code
COPY packages/backend ./packages/backend
COPY packages/shared ./packages/shared
COPY packages/db ./packages/db

WORKDIR /app/packages/backend

EXPOSE 3333

CMD ["node", "src/index.ts"]

# Production stage - Frontend
FROM node:20-alpine AS frontend
WORKDIR /app

# Copy package files
COPY packages/frontend/package.json ./packages/frontend/
COPY packages/shared/package.json ./packages/shared/
COPY package.json ./

# Install production dependencies
RUN npm ci --omit=dev --workspace=packages/frontend --prefix packages/frontend
RUN npm ci --omit=dev --workspace=packages/shared --prefix packages/shared

# Copy built frontend and source
COPY --from=frontend-builder /app/packages/frontend/.next ./packages/frontend/.next
COPY --from=frontend-builder /app/packages/frontend/public ./packages/frontend/public
COPY packages/frontend ./packages/frontend
COPY packages/shared ./packages/shared

WORKDIR /app/packages/frontend

# Make load-env.sh executable
RUN chmod +x load-env.sh

EXPOSE 8080

CMD ["node", "server.js"]
