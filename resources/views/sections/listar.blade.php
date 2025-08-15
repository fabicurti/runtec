<h3 class="text-lg font-bold mb-4">📰 Notícias Cadastradas</h3>
<div class="flex flex-wrap items-center gap-4 mb-4">
    <input type="text" id="filtro-titulo" placeholder="Buscar por título..." class="px-4 py-2 border rounded w-full sm:w-1/2" />

    <select id="filtro-mes" class="px-4 py-2 border rounded w-full sm:w-1/4">
        <option value="">Mês</option>
        <option value="01">Janeiro</option>
        <option value="02">Fevereiro</option>
        <option value="03">Março</option>
        <option value="04">Abril</option>
        <option value="05">Maio</option>
        <option value="06">Junho</option>
        <option value="07">Julho</option>
        <option value="08">Agosto</option>
        <option value="09">Setembro</option>
        <option value="10">Outubro</option>
        <option value="11">Novembro</option>
        <option value="12">Dezembro</option>
    </select>

    <input type="number" id="filtro-ano" value="{{ date('Y') }}" class="mt-1 block w-full sm:w-1/4 border-gray-300 rounded-md shadow-sm" placeholder="YYYY">

    <button id="btn-filtrar" type="button" class="px-4 py-2 btn btn-info text-white rounded">Filtrar</button>

</div>

<div id="noticias-loader" class="text-gray-500">Carregando notícias...</div>
<table id="noticias-table" class="min-w-full table-auto">
    <thead>
    <tr class="bg-gray-100">
        <th class="px-4 py-2 text-left">ID</th>
        <th class="px-4 py-2 text-left">Título</th>
        <th class="px-4 py-2 text-left">Ações</th>
    </tr>
    </thead>
    <tbody id="noticias-body">
    <!-- Conteúdo será inserido via JS -->
    </tbody>
</table>
<div id="paginacao" class="mt-4 flex flex-wrap"></div>
