FROM php:8.2-apache

# 1. Instala dependências (PHP + Node.js)
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl gnupg \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && a2enmod rewrite

# 2. Configura Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Configura diretório de trabalho
WORKDIR /var/www/html

# 4. Copia arquivos (excluindo node_modules para otimização)
COPY . .

# 5. Configura Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    && a2ensite 000-default

# 6. Instala dependências e build
RUN composer install --no-interaction --prefer-dist --optimize-autoloader \
    && npm install \
    && npm run build \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache public/build

# 7. Health check (opcional para Render)
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80
CMD ["apache2-foreground"]