# Dockerfile for Ubuntu LTS Webserver
FROM ubuntu:22.04

# Install lighttpd
RUN apt-get update && \
    apt-get install -y lighttpd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom config
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf

# Add site content and ensure correct permissions to avoid 403 Forbidden
COPY index.html /var/www/html/index.html
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

EXPOSE 8080

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
