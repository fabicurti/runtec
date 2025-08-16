<?php

namespace App\Http\Controllers;
use App\Models\Noticia;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class NoticiaController extends Controller
{
    public function index()
    {
        $noticias = Noticia::orderBy('created_at', 'desc')->get();
        return response()->json($noticias);
    }

    //CRUD de noticias padrao
    public function listar() {
        return view('sections.listar');
    }
    public function listarPaginado(Request $request) {
        $query = Noticia::query();

        if ($request->filled('titulo')) {
            $query->where('titulo', 'like', '%' . $request->titulo . '%');
        }

        if ($request->filled('mes')) {
            $query->whereMonth('data_publicacao', $request->mes);
        }

        if ($request->filled('ano')) {
            $query->whereYear('data_publicacao', $request->ano);
        }

        $noticias = $query->orderBy('data_publicacao', 'desc')->paginate(25);

        return response()->json($noticias);
    }

    public function create()
    {
        return view('sections.criar');
    }
    public function store(Request $request)
    {
        $request->validate([
            'titulo' => 'required|string|max:255',
            'conteudo' => 'required|string',
        ]);

        $data = Carbon::now()->toDateString();
        $titulo = $request->titulo;
        $source = 'Interno';
        $autor = Auth::user()->name;
        $conteudo = $request->conteudo;

        $noticia = Noticia::updateOrCreate(
            ['titulo' => $titulo],
            [
                'data_publicacao' => $data,
                'conteudo' => $conteudo,
                'fonte' => $source,
                'autor' => $autor,
            ]
        );

        return response()->json($noticia, 201);
    }

    public static function show($id)
    {
        $noticia = Noticia::findOrFail($id);
        return view('sections.exibir', compact('noticia'));
    }

    public function selNoticias(Request $request)
    {
        $query = Noticia::query()->select('id', 'titulo');

        if ($request->has('q')) {
            $query->where('titulo', 'like', '%' . $request->q . '%');
        }

        return $query->limit(20)->get();
    }
    public function editar($id)
    {
        $noticia = Noticia::findOrFail($id);
        return view('sections.editar', compact('noticia'));
    }
    public function update(Request $request, $id)
    {
        $request->validate([
            'titulo' => 'required|string|max:255',
            'conteudo' => 'required|string',
        ]);

        $noticia = Noticia::findOrFail($id);
        $noticia->update([
            'titulo' => $request->titulo,
            'conteudo' => $request->conteudo,
        ]);

        return response()->json($noticia);
    }

    public function destroy($id)
    {
        $noticia = Noticia::findOrFail($id);
        $noticia->delete();
        return response()->json(['message' => 'Notícia deletada com sucesso']);
    }

    //Metodo de sincronizacao de noticias com API
    public function sincronizar()
    {
        return view('sections.sincronizar');
    }
    public function sync(Request $request)
    {
        $request->validate([
            'mes' => 'required|integer|min:1|max:12',
            'ano' => 'required|integer|min:1900|max:' . date('Y'),
        ]);

        $mes = $request->mes;
        $ano = $request->ano;

        $jaSincronizado = Noticia::whereMonth('data_publicacao', $mes)
            ->whereYear('data_publicacao', $ano)
            ->exists();

        if ($jaSincronizado) {
            return response()->json([
                'success' => false,
                'mensagem' => "Esse mês já foi sincronizado anteriormente."
            ]);
        }


        $apiKey = env('NYT_API_KEY'); // coloque sua chave no .env
        $url = "https://api.nytimes.com/svc/archive/v1/{$ano}/{$mes}.json?api-key={$apiKey}";

        $response = Http::get($url);

        if (!$response->successful()) {dd($response);
            return response()->json(['erro' => 'Falha ao consultar a API.'], 500);
        }

        $docs = $response->json()['response']['docs'];


        $sincronizadas = 0;
        foreach ($docs as $doc) {
            $this->syncNoticia($doc);
            $sincronizadas++;
        }

        return response()->json([
            'success' => true,
            'mensagem' => "Sincronização concluída com sucesso! {$sincronizadas} notícias importadas."
        ]);
    }

    public function syncNoticia(array $item)
    {
        $titulo = $item['headline']['main'];
        $data = Carbon::parse($item['pub_date'])->format('Y-m-d');
        $source = $item['source'];
        $autor = (!empty($item['byline']['person']['firstname'])) ? $item['byline']['person']['firstname'] : '';
        $autor .= (!empty($autor) && !empty($item['byline']['person']['lastname'])) ? ' ' : '';
        $autor .= (!empty($item['byline']['person']['lastname'])) ? $item['byline']['person']['lastname'] : '';

        $imagem = null;
        if(!empty($item['multimedia'])) {
            foreach ($item['multimedia'] as $media) {
                if ($media['subtype'] === 'xlarge' && empty($imagem)) {
                    $imagem = 'https://www.nytimes.com/' . $media['url'];
                    break;
                }
            }
        }

        $conteudo = "<p>{$item['lead_paragraph']}</p>";
        if ($imagem) {
            $conteudo = "<img src='{$imagem}' style='max-width:100%; margin-bottom:1em;' />" . $conteudo;
        }

        $conteudo .= ($source == 'The New York Times')? "<p><a href='{$item['web_url']}' target='_blank' class='link-info'>Leia no NYT</a></p>": '';

        Noticia::updateOrCreate(
            ['titulo' => $titulo],
            [
                'data_publicacao' => $data,
                'conteudo' => $conteudo,
                'fonte' => $source,
                'autor' => $autor,
            ]
        );
    }

}