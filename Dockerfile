FROM php:8.2-apache

# 1. Instala dependências básicas do PHP
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl gnupg \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && a2enmod rewrite

# 2. Instala Node.js 20.x + npm atualizado
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# 3. Copia Composer do container oficial
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Define diretório de trabalho
WORKDIR /var/www/html

# 5. Copia apenas arquivos de dependências do Node e do PHP para instalar mais rápido
COPY package*.json vite.config.js ./
COPY composer.json composer.lock ./

# 6. Instala dependências do Node
RUN npm ci

# 7. Copia o restante do projeto
WORKDIR /var/www/html
COPY . .

# 8. Gera build do Vite (cria public/build/manifest.json)
RUN npm run build

# 9. Instala dependências do PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 10. Ajusta permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache public/build

# 11. Configura Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    && a2ensite 000-default

# 12. Porta de exposição
EXPOSE 80

# 13. Comando inicial
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

