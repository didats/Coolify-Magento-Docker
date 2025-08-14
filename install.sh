#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

> log.txt
echo "Starting Magento installation..." | tee -a log.txt

# Wait for the database and OpenSearch to be ready
until nc -z $DB_HOST 3306; do
  echo "Waiting for MySQL to be ready..." | tee -a log.txt
  sleep 5
done

until nc -z $OPENSEARCH_HOST 9200; do
  echo "Waiting for OpenSearch to be ready..." | tee -a log.txt
  sleep 5
done

# Run the Magento setup command using environment variables
php bin/magento setup:install \
  --base-url="$MAGENTO_BASE_URL" \
  --db-host="$DB_HOST" \
  --db-name="$DB_NAME" \
  --db-user="$DB_USER" \
  --db-password="$DB_PASSWORD" \
  --search-engine=opensearch \
  --opensearch-host="$OPENSEARCH_HOST" \
  --opensearch-port=9200 \
  --admin-firstname=Admin \
  --admin-lastname=User \
  --admin-email=admin@yourdomain.com \
  --admin-user="$MAGENTO_ADMIN_USER" \
  --admin-password="$MAGENTO_ADMIN_PASSWORD" \
  --language=en_US \
  --currency=USD \
  --timezone=UTC \
  --use-rewrites=1 \
  --cleanup-database

php bin/magento sampledata:deploy

echo "Magento installation complete." | tee -a log.txt

# Deploy static content and compile
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f
php bin/magento cache:clean
php bin/magento cache:flush

echo "Deployment finished." | tee -a log.txt