FROM php:8.2-apache

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && a2enmod rewrite

# Copia o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Define diretório de trabalho
WORKDIR /var/www/html

# Copia arquivos do projeto
COPY . .

# Copia configuração do Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Instala dependências do Laravel
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Permissões corretas para cache e storage
RUN chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Testa se Laravel está funcionando
RUN php artisan config:clear \
    && php artisan route:list

RUN php artisan migrate --force

EXPOSE 80

CMD ["apache2-foreground"]
