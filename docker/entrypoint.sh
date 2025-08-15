#!/bin/bash
set -e

# Porta que o Render fornece
PORT="${PORT:-8080}"

echo "[DEBUG] VirtualHosts ativos:"
apache2ctl -S

# Ajusta Apache para escutar na PORT do ambiente
if grep -q "Listen 80" /etc/apache2/ports.conf; then
  sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
fi
if grep -q "<VirtualHost *:80>" /etc/apache2/sites-available/000-default.conf; then
  sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:${PORT}>/" /etc/apache2/sites-available/000-default.conf
fi

# Opcional: define ServerName para evitar warnings
: "${SERVER_NAME:=localhost}"
echo "ServerName ${SERVER_NAME}" > /etc/apache2/conf-available/servername.conf || true
a2enconf servername >/dev/null 2>&1 || true

# Permissões essenciais
chown -R www-data:www-data /var/www/html
chmod -R 775 storage bootstrap/cache public/build || true

# Limpa caches Laravel
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

echo "Apache ouvindo na porta ${PORT}"
echo "[DEBUG] Conteúdo de /var/www/html:"
ls -la /var/www/html

echo "[DEBUG] Conteúdo de /var/www/html/public:"
ls -la /var/www/html/public

exec apache2-foreground
