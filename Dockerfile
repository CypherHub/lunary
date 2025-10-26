FROM node:20-slim

WORKDIR /app

# Install system dependencies required for onnxruntime-node
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy all files
COPY . .

# Install dependencies
RUN npm install

# Expose ports
EXPOSE 3333 8080

RUN npm run migrate:db

# Run development server
CMD ["npm", "run", "dev"]
