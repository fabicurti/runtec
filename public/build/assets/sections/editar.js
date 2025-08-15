let quill; // ← define fora

export default async function () {
    const quillCss = document.createElement('link');
    quillCss.rel = 'stylesheet';
    quillCss.href = 'https://cdn.quilljs.com/1.3.6/quill.snow.css';
    document.head.appendChild(quillCss);

    await new Promise((resolve, reject) => {
        const quillScript = document.createElement('script');
        quillScript.src = 'https://cdn.quilljs.com/1.3.6/quill.min.js';
        quillScript.onload = resolve;
        quillScript.onerror = reject;
        document.head.appendChild(quillScript);
    });

    const container = document.getElementById('editor-container');
    const conteudo = container.dataset.conteudo;

    quill = new Quill('#editor-container', {
        theme: 'snow',
        modules: {
            toolbar: [
                ['bold', 'italic', 'underline'],
                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                ['link', 'image']
            ]
        }
    });

    quill.root.innerHTML = conteudo;
}

// Agora o quill está acessível aqui:
document.getElementById('form-editar').addEventListener('submit', async function (e) {
    e.preventDefault();

    const id = document.getElementById('noticia-id').value;
    const titulo = document.getElementById('titulo').value;
    const conteudo = quill.root.innerHTML;

    try {
        const res = await fetch(`/noticias/${id}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({ titulo, conteudo })
        });

        if (res.ok) {
            alert('Notícia atualizada com sucesso!');
            carregarSecao('noticia', id);
        } else {
            const erro = await res.text();
            console.error('Erro ao atualizar:', erro);
            alert('Erro ao atualizar notícia.');
        }
    } catch (err) {
        console.error('Falha na requisição:', err);
        alert('Erro de conexão.');
    }
});
