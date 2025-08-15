<?php
    use App\Http\Controllers\NoticiaController;
    use App\Http\Controllers\ProfileController;
    use Illuminate\Support\Facades\Route;

    Route::get('/ping', function () {
        return 'pong';
    });

    Route::get('/', function () {
        return view('welcome');
    })->name('home');

    Route::middleware(['auth', 'verified'])->group(function () {
        Route::get('/dashboard', function () {
            return view('dashboard');
        })->name('dashboard');

        // Seções de notícias via controller
        // listar notícias
        Route::get('/secao/listar', [NoticiaController::class, 'listar'])->name('secao.listar');
        Route::get('/noticias/listar', [NoticiaController::class, 'listarPaginado'])->name('noticias.listar');

        //ler notícia
        Route::get('/secao/noticia/{id}', [NoticiaController::class, 'show'])->name('secao.noticia.show');

        Route::get('/secao/criar', [NoticiaController::class, 'create'])->name('secao.create');
        Route::post('/noticias/store', [NoticiaController::class, 'store'])->name('noticias.store');


        //editar notícia
        Route::get('/selNoticias', [NoticiaController::class, 'selNoticias'])->name('secao.selNoticias');
        Route::get('/secao/editar/{id}', [NoticiaController::class, 'editar'])->name('secao.editar');
        Route::patch('/noticias/{id}', [NoticiaController::class, 'update'])->name('noticias.update');

        // 👇 API de notícias
        Route::get('/secao/sincronizar', [NoticiaController::class, 'sincronizar'])->name('secao.sincronizar');
        Route::post('/noticias/sincronizar', [NoticiaController::class, 'sync'])->name('noticias.sync');

        // 👇 Perfil
        Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
        Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
        Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');


        Route::get('/debug-db', function () {
            return DB::select('SHOW TABLES');
        });
    });

    require __DIR__.'/auth.php';
