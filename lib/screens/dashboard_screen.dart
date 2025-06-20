import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset_model.dart';
import '../providers/asset_provider.dart';
import '../providers/providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/asset_search_delegate.dart';
import '../widgets/charts/time_series_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Financeiro'),
        actions: [
          // Botão de Pesquisa
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // `showSearch` é uma função do Flutter que abre o SearchDelegate.
              final selectedSymbol = await showSearch<String>(
                context: context,
                delegate: AssetSearchDelegate(),
              );

              // Se o usuário selecionou um símbolo, atualizamos o nosso provider.
              if (selectedSymbol != null && selectedSymbol.isNotEmpty) {
                ref.read(dashboardProvider.notifier).setSymbol(selectedSymbol);
              }
            },
          ),
          // Botão para trocar o tema
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () {
              // Lemos o provider e chamamos o método para trocar o tema.
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Cabeçalho com as informações do ativo
            _AssetHeader(),
            SizedBox(height: 20),
            // Seletor de intervalo de tempo
            _TimeframeSelector(),
            SizedBox(height: 10),
            // Gráfico de série temporal
            Expanded(
              flex: 3, // O gráfico ocupará mais espaço
              child: TimeSeriesChart(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetHeader extends ConsumerWidget {
  const _AssetHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetAsyncValue = ref.watch(assetOverviewProvider);

    return assetAsyncValue.when(
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SizedBox(
        height: 60,
        child: Center(child: Text('Erro: ${err.toString()}')),
      ),
      data: (Asset asset) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    asset.symbol,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    asset.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              // TODO: Implementar botão de favoritar
              IconButton(
                icon: const Icon(Icons.star_border, size: 30),
                onPressed: () {
                  // Lógica para adicionar/remover dos favoritos
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget privado para o seletor de intervalo de tempo
class _TimeframeSelector extends ConsumerWidget {
  const _TimeframeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lista de intervalos de tempo disponíveis
    const timeframes = ['1min', '5min', '15min', '30min', '60min', '1D'];

    // Ouve o intervalo de tempo atualmente selecionado
    final selectedTimeframe = ref.watch(
      dashboardProvider.select((state) => state.interval),
    );

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        itemBuilder: (context, index) {
          final timeframe = timeframes[index];
          final isSelected = timeframe == selectedTimeframe;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(timeframe),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  // Atualiza o estado no provider quando um novo chip é selecionado.
                  ref.read(dashboardProvider.notifier).setInterval(timeframe);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
