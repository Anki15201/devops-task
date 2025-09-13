# Dockerfile (multi-stage)
# Stage 1 - build
FROM node:22 AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./

RUN npm install

# Copy app code
COPY . .

# Stage 2 - runtime
FROM node:22-slim

WORKDIR /app

COPY --from=builder /app .

# Expose the app port
EXPOSE 3000

# start container
CMD ["npm", "start"]

