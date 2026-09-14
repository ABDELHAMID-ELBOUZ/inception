FROM debian:bookworm

# Install nginx and openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate a self-signed certificate (valid for 365 days)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/CN=${DOMAIN_NAME}"

# Copy custom nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Remove default site (optional)
RUN rm -f /etc/nginx/sites-enabled/default

# Expose port 443 only (as per subject)
EXPOSE 443

# Start nginx in foreground (no daemon, so it becomes PID 1)
CMD ["nginx", "-g", "daemon off;"]