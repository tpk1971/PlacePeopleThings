# Builder: use Flutter SDK image to build web artifacts
FROM cirrusci/flutter:stable AS builder

WORKDIR /app

# Copy source
COPY . /app

# Pre-fetch dependencies
RUN flutter pub get

# Build args
ARG API_BASE=http://api:3000

# Build the web app with API_BASE baked in
RUN flutter build web --release --dart-define=API_BASE=$API_BASE

# Final: serve with nginx
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built web files
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx config to enable SPA fallback
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

