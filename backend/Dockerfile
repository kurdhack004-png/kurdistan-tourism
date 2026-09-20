FROM php:8.3-cli-bookworm AS app

ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libpq-dev libicu-dev libzip-dev \
    && docker-php-ext-install pdo_pgsql intl mbstring bcmath zip opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# The repository keeps the domain code and migrations separately from the
# generated Laravel framework bootstrap. Build a clean Laravel 11 runtime,
# then layer the Kurdistan Tourism application code on top.
RUN composer create-project laravel/laravel:^11.0 /tmp/laravel --no-interaction --prefer-dist \
    && cd /tmp/laravel \
    && php artisan install:api --no-interaction

COPY composer.json /tmp/composer.json
RUN cp /tmp/composer.json /tmp/laravel/composer.json \
    && cd /tmp/laravel \
    && composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader

COPY . /tmp/kurdistan

RUN cp /tmp/kurdistan/bootstrap/app.php /tmp/laravel/bootstrap/app.php \
    && cp -R /tmp/kurdistan/app/Http /tmp/laravel/app/ \
    && cp -R /tmp/kurdistan/app/Models /tmp/laravel/app/ \
    && rm -f /tmp/laravel/database/migrations/*.php \
    && cp -R /tmp/kurdistan/database/migrations /tmp/laravel/database/ \
    && cp /tmp/kurdistan/routes/api.php /tmp/laravel/routes/api.php \
    && cp /tmp/kurdistan/config/database.php /tmp/laravel/config/database.php \
    && cp /tmp/kurdistan/.env.example /tmp/laravel/.env.example \
    && rm -rf /tmp/kurdistan

WORKDIR /tmp/laravel
RUN php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear \
    && chown -R www-data:www-data storage bootstrap/cache

# Render supplies PORT. Laravel listens on all interfaces so the service is
# reachable through Render's proxy.
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-10000}"]
