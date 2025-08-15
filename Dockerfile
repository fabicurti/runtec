# ========= ASSETS BUILD (Vite) =========
FROM node:20-alpine AS assets
WORKDIR /app

# Copia dependências e código necessários para o build
COPY package*.json vite.config.js ./
# Se você usa Tailwind/PostCSS/etc., descomente as linhas abaixo:
# COPY tailwind.config.* postcss.config.* ./
COPY . .

# Instala deps e gera os assets (public/build + manifest.json)
RUN npm ci \
 && npm run build \
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
#    (garante que o public/build final é o gerado pelo Vite)
COPY --from=assets /app/public/build ./public/build

# 6) Instala dependências do PHP (sem dev) e otimiza autoloader
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 7) Verificação de segurança: manifesta precisa existir
RUN ls -l public/build && test -f public/build/manifest.json

# 8) Permissões necessárias para Laravel
RUN chown -R www-data:www-data storage bootstrap/cache public/build \
 && chmod -R 775 storage bootstrap/cache public/build

# 9) Configuração do Apache (vhost apontando para /public)
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername \
 && a2dissite default-ssl 000-default.conf.default || true \
 && a2ensite 000-default

# 10) Porta e entrypoint
EXPOSE 80
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
