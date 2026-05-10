# =========================
# Stage 1: Build Flutter Web
# =========================

FROM ghcr.io/cirruslabs/flutter:stable AS build

# Prevent analytics + speed up CI
ENV FLUTTER_WEB_AUTO_DETECT=false
ENV CI=true

# Set working directory
WORKDIR /app

# Copy dependency files first for Docker layer caching
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN flutter pub get

# Copy the rest of the app
COPY . .

# Build release web app
RUN flutter build web --release

# =========================
# Stage 2: Serve with Nginx
# =========================

FROM nginx:stable-alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web output
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration for SPA fallback
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Install healthcheck tool
RUN apk add --no-cache wget

# Expose HTTP port
EXPOSE 80

# Healthcheck (good for Kubernetes / Docker Compose)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget --spider -q http://localhost || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]