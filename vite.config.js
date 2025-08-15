import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
                'resources/js/dashboard.js',
                'resources/js/sections/criar.js',
                'resources/js/sections/editar.js',
                'resources/js/sections/exibir.js',
                'resources/js/sections/listar.js',
                'resources/js/sections/sincronizar.js',
            ],
            refresh: false,
            base: process.env.VITE_ASSET_URL || '/', // 👈 ESSENCIAL
        }),
    ],
    build: {
        manifest: true,
        outDir: 'public/build',
        manifestFile: 'manifest.json',
        rollupOptions: {
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
                'resources/js/dashboard.js',
                'resources/js/sections/criar.js',
                'resources/js/sections/editar.js',
                'resources/js/sections/exibir.js',
                'resources/js/sections/listar.js',
                'resources/js/sections/sincronizar.js',
            ],
        },
    },
});
