FROM php:8.2-fpm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip \
    git \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libxslt1-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libgd-dev \
    zlib1g-dev \
    wget \
    cron \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath intl gd soap xsl sockets ftp

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Debug: Check if Composer is installed and in PATH
RUN which composer && composer --version


# Set recommended PHP configuration for Magento
RUN echo "memory_limit = 6G" >> /usr/local/etc/php/conf.d/magento.ini \
    && echo "max_execution_time = 4600" >> /usr/local/etc/php/conf.d/magento.ini \
    && echo "zlib.output_compression = On" >> /usr/local/etc/php/conf.d/magento.ini

WORKDIR /var/www/html

COPY . .
RUN composer config --global http-basic.repo.magento.com f5b75676ef89ce20351c84fb4e4f56fb b2af391ca0c97ae23c2cea6e7c9ef7af 
RUN composer install

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html