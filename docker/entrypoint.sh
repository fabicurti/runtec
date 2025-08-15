#!/bin/bash
set -e

# Ajusta permissões
chown -R www-data:www-data /var/www/html
chmod -R 775 storage bootstrap/cache public/build || true

# Limpa caches Laravel
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Inicia Apache
exec apache2-foreground
