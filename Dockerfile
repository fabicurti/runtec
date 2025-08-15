FROM php:8.2-apache

# 1. Instala dependências do sistema + Node.js 20 (LTS)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 2. Instala Composer globalmente
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Configura Apache para Laravel
RUN a2enmod rewrite && \
    sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf && \
    sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 4. Define diretório de trabalho
WORKDIR /var/www/html

# 5. Copia os arquivos do projeto
COPY . .

# 6. Instala dependências do Laravel
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# 7. Instala dependências do frontend
RUN npm install --legacy-peer-deps && npm run build

EXPOSE 80
