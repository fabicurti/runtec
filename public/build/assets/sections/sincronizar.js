export default function inicializarSincronizacao() {
    const form = document.getElementById('form-sincronizar');
    if (!form) return;

    form.addEventListener('submit', function (e) {
        e.preventDefault();

        const mes = document.getElementById('mes').value;
        const ano = document.getElementById('ano').value;
        const status = document.getElementById('sincronizar-status');
        status.textContent = '🔄 Sincronizando...';

        fetch('/noticias/sincronizar', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({ mes, ano })
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    status.textContent = `✅ ${data.mensagem}`;
                } else {
                    status.textContent = `⚠️ Erro: ${data.mensagem || 'Não foi possível sincronizar.'}`;
                }
            })
            .catch(() => {
                status.textContent = '❌ Erro na requisição.';
            });
    });
}
