<h2 class="text-xl font-bold mb-4">➕ Criar Notícia</h2>

<form id="form-criar" method="POST">
    @csrf
    <label>Título:</label>
    <input type="text" id="titulo" value="" class="border p-2 w-full mb-4">

    <label>Conteúdo:</label>
    <div id="editor-container" style="height: 300px;"></div>


    <div class="flex justify-between items-center mt-5">
        <button type="button" onclick="carregarSecao('listar')" class="text-blue-600 hover:underline">← Voltar</button>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded ">Salvar</button>
    </div>
</form>
