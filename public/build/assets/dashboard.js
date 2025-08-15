document.addEventListener('DOMContentLoaded', function () {
    //Chamando modal para edição de notícias
    const modalEditar = document.getElementById('modal-editar');
    const btnAbrirModal = document.getElementById('abrir-modal-editar');
    const btnCancelar = document.getElementById('btn-cancelar');
    btnAbrirModal.addEventListener('click', () => {
        modalEditar.classList.remove('hidden');
    });
    btnCancelar.addEventListener('click', () => {
        modalEditar.classList.add('hidden');
    });
    $('#noticia-select').select2({
        placeholder: 'Selecione uma notícia',
        width: '100%',
        ajax: {
            url: '/selNoticias',
            dataType: 'json',
            delay: 250,
            data: function (params) {
                return {
                    q: params.term
                };
            },
            processResults: function (data) {
                return {
                    results: data.map(n => ({
                        id: n.id,
                        text: n.titulo
                    }))
                };
            }
        }
    });
    $('#btn-editar').on('click', function () {
        const noticiaId = $('#noticia-select').val();
        if (!noticiaId) {
            alert('Selecione uma notícia para editar.');
            return;
        }
        // Fecha o modal
        $('#modal-editar').addClass('hidden');
        // Chama a função que carrega a seção de edição
        carregarSecao('editar', noticiaId);
    });

    //Chamando modal para exibir de notícias
    const modalExibir = document.getElementById('modal-exibir');
    const btnAbrirModalExibir = document.getElementById('abrir-modal-exibir');
    const btnCancelarExibir = document.getElementById('btn-cancelar-exibir');
    btnAbrirModalExibir.addEventListener('click', () => {
        modalExibir.classList.remove('hidden');
    });
    btnCancelarExibir.addEventListener('click', () => {
        modalExibir.classList.add('hidden');
    });
    $('#noticia-select-exibir').select2({
        placeholder: 'Selecione uma notícia',
        width: '100%',
        ajax: {
            url: '/selNoticias',
            dataType: 'json',
            delay: 250,
            data: function (params) {
                return {
                    q: params.term
                };
            },
            processResults: function (data) {
                return {
                    results: data.map(n => ({
                        id: n.id,
                        text: n.titulo
                    }))
                };
            }
        }
    });
    $('#btn-exibir').on('click', function () {
        const noticiaIdLer = $('#noticia-select-exibir').val();
        if (!noticiaIdLer) {
            alert('Selecione uma notícia para exibir.');
            return;
        }
        // Fecha o modal
        $('#modal-exibir').addClass('hidden');
        // Chama a função que carrega a seção de edição
        carregarSecao('noticia', noticiaIdLer);
    });





    // expondo a função carregarSecao globalmente
    window.carregarSecao = carregarSecao;

    // js para cada seção
    const modulos = {
        listar: () => import('./sections/listar.js'),
        sincronizar: () => import('./sections/sincronizar.js'),
        editar: () => import('./sections/editar.js'),
        criar: () => import('./sections/criar.js'),
        // outros...
    };

    // Carrega a seção
    function carregarSecao(secao, id = null) {
        const url = id ? `/secao/${secao}/${id}` : `/secao/${secao}`;
        fetch(url)
            .then(res => res.text())
            .then(html => {
                const container = document.getElementById('conteudo');

                const observer = new MutationObserver((mutations, obs) => {
                    if (modulos[secao]) {
                        modulos[secao]().then(module => {
                            module.default(); // inicializa JS da seção
                        });
                    }
                    obs.disconnect();
                });

                observer.observe(container, { childList: true });
                container.innerHTML = html;
            });
    }

    //listener para os links do menu
    document.querySelectorAll('.btn-menu').forEach(btn => {
        btn.addEventListener('click', () => {
            const secao = btn.getAttribute('data-section');
            carregarSecao(secao);
        });
    });

    // Carrega a seção inicial
    carregarSecao('listar');
});
