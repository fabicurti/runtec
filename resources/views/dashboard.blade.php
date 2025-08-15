<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Bem-vinda, {{ Auth::user()->name }}!
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                <div class="flex gap-6">
                    <!-- Menu lateral -->
                    <div class="w-1/4 bg-gray-50 p-4 rounded-lg shadow">
                        <h3 class="text-lg font-bold mb-4">Menu Principal</h3>
                        <ul class="space-y-2">
                            <li><a href="javascript:void(0)" class="btn-menu text-blue-600 hover:underline" data-section="listar">Lista de notícias</a></li>
                            <li><a href="javascript:void(0)" id="abrir-modal-exibir" class="text-blue-600 hover:underline">Exibir notícia</a></li>
                            <li><a href="javascript:void(0)" class="btn-menu text-blue-600 hover:underline" data-section="criar">Nova notícia</a></li>
                            <li><a href="javascript:void(0)" id="abrir-modal-editar" class="text-blue-600 hover:underline">Editar notícia</a></li>
                            <li><a href="javascript:void(0)" class="btn-menu text-blue-600 hover:underline" data-section="sincronizar">Sincronizar notícias</a></li>
                            <li>
                                <form method="POST" action="{{ route('logout') }}">
                                    @csrf
                                    <button type="submit" class="text-red-600 hover:underline">Sair do sistema</button>
                                </form>
                            </li>
                        </ul>
                    </div>

                    <!-- Conteúdo principal -->
                    <div class="w-3/4">
                        <div id="conteudo" class="w-3/4 p-6"></div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Modal Editar Notícia -->
    <div id="modal-editar" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden">
        <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
            <h2 class="text-xl font-bold mb-4">Editar Notícia</h2>

            <label for="noticia-select" class="block mb-2 text-sm font-medium text-gray-700">Selecione a notícia:</label>
            <select id="noticia-select" class="w-full border border-gray-300 rounded p-2"></select>

            <div class="mt-6 flex justify-end gap-4">
                <button id="btn-cancelar" class="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300">Cancelar</button>
                <button id="btn-editar" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Editar</button>
            </div>
        </div>
    </div>
    <!-- Modal Exibir Notícia -->
    <div id="modal-exibir" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden">
        <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
            <h2 class="text-xl font-bold mb-4">Exibir Notícia</h2>

            <label for="noticia-select-exibir" class="block mb-2 text-sm font-medium text-gray-700">Selecione a notícia:</label>
            <select id="noticia-select-exibir" class="w-full border border-gray-300 rounded p-2"></select>

            <div class="mt-6 flex justify-end gap-4">
                <button id="btn-cancelar-exibir" class="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300">Cancelar</button>
                <button id="btn-exibir" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Ler</button>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- Select2 -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    @vite(['resources/js/dashboard.js'])
</x-app-layout>