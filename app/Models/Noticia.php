<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Noticia extends Model
{
    protected $fillable = [
        'titulo',
        'conteudo',
        'data_publicacao',
        'fonte',
        'autor',
        'url',
    ];

}
