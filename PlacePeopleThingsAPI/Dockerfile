# Build image
FROM node:20-alpine AS builder
WORKDIR /app

# Install build deps
COPY package.json package-lock.json* ./
RUN npm install

# Copy sources and build
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# Production image
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Only install production dependencies
COPY package.json ./
RUN npm install --production

# Copy built artifacts
COPY --from=builder /app/dist ./dist

# Copy SQL migrations into the image so migrate runner can find them at runtime
COPY migrations ./migrations

EXPOSE 3000
CMD ["npm", "run", "start"]
