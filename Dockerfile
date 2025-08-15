FROM php:8.2-apache

# Instala extensões necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia o projeto
COPY . /var/www/html

# Define diretório de trabalho
WORKDIR /var/www/html

# Permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Instala dependências e gera cache
RUN composer install --no-interaction --prefer-dist \
    && php artisan config:clear \
    && php artisan cache:clear \
    && php artisan view:clear \
    && php artisan route:clear \
    && php artisan config:cache

# Habilita mod_rewrite
RUN a2enmod rewrite

# Define porta
EXPOSE 80
