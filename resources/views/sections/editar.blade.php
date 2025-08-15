<h2 class="text-xl font-bold mb-4">✒ Editar Notícia</h2>

<form id="form-editar" method="POST">
    @csrf
    <input type="hidden" id="noticia-id" value="{{ $noticia->id }}">

    <label>Título:</label>
    <input type="text" id="titulo" value="{{ $noticia->titulo }}" class="border p-2 w-full mb-4">

    <label>Conteúdo:</label>
    <div id="editor-container" style="height: 300px;" data-conteudo="{{ $noticia->conteudo }}"></div>


    <div class="flex justify-between items-center mt-5">
        <button type="button" onclick="carregarSecao('noticia', {{ $noticia->id }})" class="text-blue-600 hover:underline">← Voltar</button>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded ">Salvar</button>
    </div>
</form>
