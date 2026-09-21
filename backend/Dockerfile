FROM php:8.3-cli-bookworm AS app

ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libpq-dev libicu-dev libzip-dev \
    && docker-php-ext-install pdo_pgsql pgsql intl mbstring bcmath zip opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN composer create-project laravel/laravel:^12.0 /tmp/laravel --no-interaction --prefer-dist \
    && cd /tmp/laravel \
    && php artisan install:api --no-interaction

COPY composer.json /tmp/composer.json
RUN cp /tmp/composer.json /tmp/laravel/composer.json \
    && rm -f /tmp/laravel/composer.lock \
    && cd /tmp/laravel \
    && composer update --no-interaction --no-dev --prefer-dist --optimize-autoloader

COPY . /tmp/kurdistan

RUN cp -R /tmp/kurdistan/app/. /tmp/laravel/app/ \
    && cp -R /tmp/kurdistan/bootstrap/. /tmp/laravel/bootstrap/ \
    && cp -R /tmp/kurdistan/config/. /tmp/laravel/config/ \
    && cp -R /tmp/kurdistan/database/. /tmp/laravel/database/ \
    && cp -R /tmp/kurdistan/routes/. /tmp/laravel/routes/ \
    && cp /tmp/kurdistan/.env.example /tmp/laravel/.env.example \
    && rm -rf /tmp/kurdistan

WORKDIR /tmp/laravel

RUN cat > /usr/local/bin/start.sh <<'SH'
#!/bin/sh
set -eu

php artisan config:clear
php artisan route:clear
php artisan migrate --force
php artisan db:seed --force

exec php artisan serve --host=0.0.0.0 --port="${PORT:-10000}"
SH

RUN chmod +x /usr/local/bin/start.sh \
    && php artisan view:clear \
    && mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

EXPOSE 10000
CMD ["/usr/local/bin/start.sh"]
