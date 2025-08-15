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
RUN echo "memory_limit = 4G" >> /usr/local/etc/php/conf.d/magento.ini \
    && echo "max_execution_time = 4600" >> /usr/local/etc/php/conf.d/magento.ini \
    && echo "zlib.output_compression = On" >> /usr/local/etc/php/conf.d/magento.ini

WORKDIR /var/www/html

COPY . .

RUN composer config --global http-basic.repo.magento.com ${COMPOSER_USER} ${COMPOSER_PASSWORD} 
RUN composer install

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# RUN ["php", "bin/magento", "setup:install", \
#     "--base-url=${MAGENTO_BASE_URL}", \
#     "--db-host=${DB_HOST}", \
#     "--db-name=${DB_NAME}", \
#     "--db-user=root", \
#     "--db-password=${DB_PASSWORD}", \
#     "--search-engine=opensearch", \
#     "--opensearch-host=${OPENSEARCH_HOST}", \
#     "--opensearch-port=9200", \
#     "--admin-firstname=Admin", \
#     "--admin-lastname=User", \
#     "--admin-email=admin@yourdomain.com", \
#     "--admin-user=${MAGENTO_ADMIN_USER}", \
#     "--admin-password=${MAGENTO_ADMIN_PASSWORD}", \
#     "--language=en_US", \
#     "--currency=KWD", \
#     "--timezone=UTC", \
#     "--use-rewrites=1"]

# # Enable custom module and set developer mode
# RUN ["php", "bin/magento", "module:enable", "Bede_PaymentGateway"]
# RUN ["php", "bin/magento", "deploy:mode:set", "developer"]

# # Upgrade, compile and deploy static content
# RUN ["php", "bin/magento", "setup:upgrade"]
# RUN ["php", "bin/magento", "setup:di:compile"]
# RUN ["php", "bin/magento", "setup:static-content:deploy", "-f"]

# # Clear cache
# RUN ["php", "bin/magento", "cache:clean"]
# RUN ["php", "bin/magento", "cache:flush"]

