# Использовать образ с PHP и Apache
FROM php:7.4-apache

# Установить необходимые пакеты для WordPress
RUN apt-get update && \
    apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libzip-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql zip

# Загрузить выбранную версию WordPress из официального источника
ARG WORDPRESS_VERSION
RUN curl -O https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz && \
    tar -xzvf wordpress-${WORDPRESS_VERSION}.tar.gz && \
    rm wordpress-${WORDPRESS_VERSION}.tar.gz && \
    mv wordpress /var/www/html && \
    chown -R www-data:www-data /var/www/html/wordpress && \
    find /var/www/html/wordpress/ -type d -exec chmod 755 {} \; && \
    find /var/www/html/wordpress/ -type f -exec chmod 644 {} \;

# Копировать настройки Apache
COPY ./apache-config.conf /etc/apache2/sites-available/000-default.conf

# Открыть порт для доступа к веб-серверу
EXPOSE 80