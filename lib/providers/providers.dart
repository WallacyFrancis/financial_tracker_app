import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/financial_service.dart';
import '../models/asset_model.dart';
import '../models/time_series_model.dart';
import 'asset_provider.dart';

// --- PROVIDERS DE SERVIÇO ---
final financialServiceProvider = Provider<FinancialService>((ref) {
  return FinancialService();
});

// --- PROVIDERS DE DADOS (Reativos) ---

// FutureProvider para buscar os dados da série temporal (gráfico).
final timeSeriesProvider = FutureProvider<List<TimeSeriesPoint>>((ref) async {
  final dashboardState = ref.watch(dashboardProvider);
  final service = ref.watch(financialServiceProvider);

  return service.getTimeSeries(dashboardState.symbol, dashboardState.interval);
});

// FutureProvider para buscar as informações gerais do ativo.
// Também é reativo ao símbolo selecionado no dashboardProvider.
final assetOverviewProvider = FutureProvider<Asset>((ref) async {
  final symbol = ref.watch(dashboardProvider.select((state) => state.symbol));
  final service = ref.watch(financialServiceProvider);

  return service.getAssetOverview(symbol);
});
