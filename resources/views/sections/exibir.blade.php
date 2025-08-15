<div id="noticia-view">
    <h2 class="text-2xl font-bold mb-4" id="titulo">{{ $noticia->titulo }}</h2>
    <p class="text-sm text-gray-600 mb-2" id="data">{{ \Carbon\Carbon::parse($noticia->data_publicacao)->format('d/m/Y') }}
        {!! (!empty($noticia->autor))? '| Por: <strong>'.$noticia->autor.'</strong>': '' !!}
    </p>
    <p class="text-sm text-gray-600 mb-2" id="fonte">Fonte: <strong>{{ $noticia->fonte }}</strong></p>
    <div class="mb-4" id="conteudo">{!! $noticia->conteudo !!}</div>
    <div class="flex justify-between items-center">
        <button onclick="carregarSecao('listar')" class="text-blue-600 hover:underline">← Voltar</button>
        <button onclick="carregarSecao('editar', {{$noticia->id}})" class="bg-blue-600 text-white px-4 py-2 rounded ">Editar</button>
    </div>
