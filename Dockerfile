# ========= ASSETS BUILD (Vite) =========
FROM node:20-alpine AS assets
WORKDIR /app

# Copia dependências e código necessários para o build
COPY package*.json vite.config.js ./
# Se você usa Tailwind/PostCSS/etc., descomente as linhas abaixo:
# COPY tailwind.config.* postcss.config.* ./

# Instala dependências do Node
RUN npm ci

# Copia restante do código-fonte
COPY . .

# Gera os assets e garante que o manifest esteja no lugar certo
RUN npm run build \
 && if [ -f public/build/.vite/manifest.json ]; then \
      mv public/build/.vite/manifest.json public/build/manifest.json; \
    fi \
 && ls -l public/build \
 && test -f public/build/manifest.json



# ========= APP (PHP + Apache) =========
FROM php:8.2-apache

# 1) Dependências do sistema e extensões PHP
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libxml2-dev zip curl gnupg libonig-dev \
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

# Adiciona escuta nas portas 80 e 10000
RUN echo "Listen 80" >> /etc/apache2/ports.conf \
 && echo "Listen 10000" >> /etc/apache2/ports.conf \
 && echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername \
 && a2dissite default-ssl || true \
 && a2ensite 000-default

# 9) Porta e entrypoint
EXPOSE 80
EXPOSE 10000

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
