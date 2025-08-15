FROM php:8.2-apache

# 1. Instala dependências (PHP + Node.js)
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl gnupg \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && a2enmod rewrite

# 2. Configura Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Configura diretório de trabalho
WORKDIR /var/www/html

# 4. Copia arquivos
COPY . .

# 5. Configura Apache
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername && \
    sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Instala dependências e build
RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    npm install && \
    npm run build && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache

EXPOSE 80
CMD ["apache2-foreground"]