FROM php:8.3-cli-bookworm

ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev libicu-dev libzip-dev unzip \
    && docker-php-ext-install pdo_pgsql pgsql intl mbstring bcmath zip opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY backend/ .

RUN composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader \
    && mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && chmod -R ug+rw storage bootstrap/cache

RUN cat > /usr/local/bin/start.sh <<'SH'
#!/bin/sh
set -eu

if [ -z "${APP_KEY:-}" ]; then
  export APP_KEY="$(php artisan key:generate --show)"
fi

mkdir -p /data/storage/framework/cache /data/storage/framework/sessions /data/storage/framework/views /data/bootstrap-cache
rm -rf storage bootstrap/cache
ln -s /data/storage storage
ln -s /data/bootstrap-cache bootstrap/cache

php artisan config:clear
php artisan route:clear
php artisan migrate --force

if php artisan db:seed --class=TourismLocationsSeeder --force; then
  echo "Tourism seed completed."
else
  echo "Tourism seed skipped/failed; API will continue."
fi

exec php artisan serve --host=0.0.0.0 --port="${PORT:-10000}"
SH

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 10000
CMD ["/usr/local/bin/start.sh"]
