import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

// Criamos nossa classe de pesquisa herdando de SearchDelegate.
class AssetSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Buscar Ativo (ex: AAPL, TSLA)';

  // Ações à direita da barra de pesquisa (ex: um botão de limpar)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Limpa o texto da pesquisa
        },
      ),
    ];
  }

  // Widget à esquerda da barra de pesquisa (ex: um botão de voltar)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Fecha a pesquisa sem retornar um resultado
      },
    );
  }

  // Constrói a tela de resultados após o usuário submeter a pesquisa
  @override
  Widget buildResults(BuildContext context) {
    // A lógica de resultados será a mesma das sugestões, então chamamos a mesma função.
    return _buildSuggestionsOrResults(context);
  }

  // Constrói as sugestões que aparecem enquanto o usuário digita
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsOrResults(context);
  }

  // Função auxiliar para construir a lista de resultados/sugestões
  Widget _buildSuggestionsOrResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Digite o nome ou símbolo de um ativo.'));
    }

    // Usamos um Consumer para acessar os providers do Riverpod.
    return Consumer(
      builder: (context, ref, child) {
        // Acessamos o serviço de API
        final service = ref.watch(financialServiceProvider);

        // Usamos um FutureBuilder para lidar com a chamada assíncrona da API de busca.
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: service.searchAssets(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum ativo encontrado.'));
            }

            final results = snapshot.data!;

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final asset = results[index];
                final symbol = asset['1. symbol'];
                final name = asset['2. name'];

                return ListTile(
                  title: Text(symbol),
                  subtitle: Text(name),
                  onTap: () {
                    // Quando um item é tocado, fechamos a pesquisa e retornamos
                    // o símbolo do ativo selecionado.
                    close(context, symbol);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
