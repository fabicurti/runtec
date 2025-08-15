FROM php:8.2-apache

# 1. Instala dependências básicas (PHP)
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl gnupg \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && a2enmod rewrite

# 2. Instala Node.js 20.x (compatível com seu package.json)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# 3. Configura Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Configura diretório de trabalho
WORKDIR /var/www/html

# 5. Copia arquivos de dependências primeiro (otimização de cache Docker)
COPY package.json package-lock.json vite.config.js ./
COPY resources/css resources/css
COPY resources/js resources/js

# 7. Copia o resto do projeto
COPY . .

# 6. Instala dependências do Node e build
RUN npm install && npm run build

# 8. Instala dependências do PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 9. Configura Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    && a2ensite 000-default

# 10. Ajusta permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache public/build

# 10. Ajusta permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache public/build

EXPOSE 80
# Fallback para o manifest (apenas para desenvolvimento)
RUN if [ ! -f "public/build/manifest.json" ]; then \
    mkdir -p public/build && \
    echo '{"resources/js/app.js":{"file":"assets/app.js"}}' > public/build/manifest.json; \
    fi
CMD ["apache2-foreground"]