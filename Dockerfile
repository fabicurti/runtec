# ========= ASSETS BUILD (Vite) =========
FROM node:20-alpine AS assets
WORKDIR /app

# Copia apenas arquivos de dependência e configs para aproveitar cache
COPY package*.json vite.config.js ./
# Caso use Tailwind/PostCSS/etc., descomente:
# COPY tailwind.config.* postcss.config.* ./

# Instala dependências do Node
RUN npm ci

# Copia restante do código-fonte
COPY . .

# Gera os assets (public/build + manifest.json)
RUN npm run build \
 && ls -l public/build \
 && test -f public/build/manifest.json


# ========= APP (PHP + Apache) =========
FROM php:8.2-apache

# 1) Dependências do sistema e extensões PHP
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libxml2-dev zip curl gnupg \
 && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# 2) Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3) Diretório de trabalho
WORKDIR /var/www/html

# 4) Copia o código do projeto
COPY . .

# 5) Copia os assets construídos do estágio "assets"
COPY --from=assets /app/public/build ./public/build

# 6) Instala dependências do PHP (sem dev) e otimiza autoloader
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 7) Ajusta permissões do Laravel e dos assets
RUN chown -R www-data:www-data storage bootstrap/cache public/build \
 && chmod -R 775 storage bootstrap/cache public/build

# 8) Configuração do Apache (vhost apontando para /public)
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername \
 && a2dissite default-ssl 000-default.conf.default || true \
 && a2ensite 000-default

# 9) Porta e entrypoint
EXPOSE 80
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
