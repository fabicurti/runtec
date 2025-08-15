#!/bin/bash

# Gera assets se não existirem
if [ ! -f "public/build/manifest.json" ]; then
  npm install
  npm run build
fi

# Inicia Apache
exec apache2-foreground