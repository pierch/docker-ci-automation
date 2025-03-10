# Base Stage
FROM nginx:1.27-alpine AS base

# Create a non-root user
RUN adduser -u 10001 -D -g "" appuser

# Ensure necessary directories exist and set proper ownership
RUN mkdir -p /var/cache/nginx /var/run /etc/nginx /etc/nginx/conf.d && \
    chown -R appuser:appuser /var/cache/nginx /var/run /etc/nginx /etc/nginx/nginx.conf /etc/nginx/conf.d

# Install necessary utilities
RUN apk add --no-cache curl

WORKDIR /test
COPY . .

# Remove 'user nginx;' directive to avoid warnings
RUN sed -i 's/^user nginx;//g' /etc/nginx/nginx.conf || true

# Remove `pid` directive to prevent conflicts
RUN sed -i '/^pid /d' /etc/nginx/nginx.conf || true

# Switch to non-root user AFTER configuring permissions
USER appuser

#########################
# Test Stage
FROM base AS test

# Add testing tools
RUN apk add --no-cache apache2-utils

# Healthcheck
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1

#########################
# Final Stage
FROM base AS final

# This layer gets built by default unless you set target to "test"

# Override CMD to force Nginx to use a writable PID file
CMD ["nginx", "-g", "daemon off; pid /tmp/nginx.pid;"]
