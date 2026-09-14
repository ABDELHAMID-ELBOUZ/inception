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
    -subj "/CN=aelbouz.42.fr"

# Copy custom nginx configuration
COPY conf/nginx.conf  /etc/nginx/conf.d/inception.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]