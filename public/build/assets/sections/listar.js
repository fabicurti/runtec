export default function carregarNoticiasInit() {
    const btnFiltrar = document.getElementById('btn-filtrar');
    if (btnFiltrar) {
        btnFiltrar.addEventListener('click', () => {
            carregarNoticias(1);
        });
    }

    // Carrega a primeira página ao abrir
    carregarNoticias(1);

}

function carregarNoticias(pagina = 1) {
    const titulo = document.getElementById('filtro-titulo').value;
    const mes = document.getElementById('filtro-mes').value;
    const ano = document.getElementById('filtro-ano').value;

    const loader = document.getElementById('noticias-loader');
    const tabela = document.getElementById('noticias-table');
    const corpo = document.getElementById('noticias-body');

    loader.textContent = '🔄 Carregando notícias...';
    tabela.classList.add('hidden');
    corpo.innerHTML = '';

    const params = new URLSearchParams({
        page: pagina,
        titulo: titulo,
        mes: mes,
        ano: ano
    });

    fetch(`/noticias/listar?${params.toString()}`)
        .then(res => res.json())
        .then(data => {
            if (data.data.length === 0) {
                loader.textContent = '⚠️ Nenhuma notícia encontrada.';
                return;
            }

            data.data.forEach(noticia => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td class="px-4 py-2">${noticia.id}</td>
                    <td class="px-4 py-2">${noticia.titulo}</td>
                    <td class="px-4 py-2">
                        <button class="text-blue-600 hover:underline" onclick="carregarSecao('noticia', ${noticia.id})">Ver</button>
                    </td>
                `;
                corpo.appendChild(tr);
            });

            loader.textContent = '';
            tabela.classList.remove('hidden');
            renderPaginacao(data);
        });
}

function renderPaginacao(data) {
    const container = document.getElementById('paginacao');
    if (!container) return;

    container.innerHTML = '';

    const total = data.last_page;
    const atual = data.current_page;

    const maxVisiveis = 5;
    const inicio = Math.max(1, atual - maxVisiveis);
    const fim = Math.min(total, atual + maxVisiveis);

    // Botão "Anterior"
    if (atual > 1) {
        const btnPrev = document.createElement('button');
        btnPrev.textContent = '←';
        btnPrev.className = 'px-3 py-1 mx-1 btn btn-outline-secondary hover:btn-secondary';
        btnPrev.onclick = () => carregarNoticias(atual - 1);
        container.appendChild(btnPrev);
    }

    // Botões de página
    for (let i = inicio; i <= fim; i++) {
        const btn = document.createElement('button');
        btn.textContent = i;
        btn.className = 'px-3 py-1 mx-1 btn btn-outline-secondary';
        if (i === atual) {
            btn.classList.add('btn-dark', 'text-white');
        } else {
            btn.classList.add('hover:btn-secondary');
            btn.onclick = () => carregarNoticias(i);
        }
        container.appendChild(btn);
    }

    // Botão "Próxima"
    if (atual < total) {
        const btnNext = document.createElement('button');
        btnNext.textContent = '→';
        btnNext.className = 'px-3 py-1 mx-1 btn btn-outline-secondary hover:btn-secondary';
        btnNext.onclick = () => carregarNoticias(atual + 1);
        container.appendChild(btnNext);
    }
}
