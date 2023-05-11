ARG WORDPRESS_VERSION=latest
FROM wordpress:${WORDPRESS_VERSION}

RUN apt-get update && apt-get install -y zip

COPY wp-config.php /var/www/html/
COPY wp-content /var/www/html/wp-content/