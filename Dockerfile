FROM node:20-alpine

WORKDIR /app

# Copy all files
COPY . .

# Install dependencies
RUN npm install

# Expose ports
EXPOSE 3333 8080

# Run development server
CMD ["npm", "run", "dev"]
