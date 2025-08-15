<h2 class="text-xl font-bold mb-4">🔄 Sincronizar Notícias do NYTimes</h2>

<form id="form-sincronizar" class="flex items-center gap-x-2">

    <div class="w-full sm:w-1/3 me-1">
        <label for="mes" class="block text-sm font-medium">Mês</label>
        <select id="mes" name="mes" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
            @for ($i = 1; $i <= 12; $i++)
                <option value="{{ $i }}">{{ $i }}</option>
            @endfor
        </select>
    </div>

    <div class="w-full sm:w-1/3 me-1">
        <label for="ano" class="block text-sm font-medium">Ano</label>
        <input type="number" id="ano" name="ano" value="{{ date('Y') }}" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
    </div>

    <div class="w-auto self-end pt-4">
        <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">Sincronizar</button>
    </div>



</form>

<div id="sincronizar-status" class="mt-4 text-sm text-gray-600"></div>

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const form = document.getElementById('form-sincronizar');
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
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
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
    });
</script>
@endpush