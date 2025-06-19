import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

// Usamos uma classe com Equatable para representar o estado do dashboard.
// Equatable nos ajuda a evitar reconstruções desnecessárias da UI.
class DashboardState extends Equatable {
  final String symbol;
  final String interval;

  const DashboardState({this.symbol = 'IBM', this.interval = '5min'});

  // Cria uma cópia do estado, mas com valores atualizados.
  DashboardState copyWith({String? symbol, String? interval}) {
    return DashboardState(
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
    );
  }

  @override
  List<Object> get props => [symbol, interval];
}

// O Notificador de Estado
class DashboardNotifier extends StateNotifier<DashboardState> {
  // O estado inicial é um DashboardState com valores padrão.
  DashboardNotifier() : super(const DashboardState());

  // Método para atualizar o símbolo do ativo selecionado.
  void setSymbol(String newSymbol) {
    state = state.copyWith(symbol: newSymbol);
  }

  // Método para atualizar o intervalo de tempo.
  void setInterval(String newInterval) {
    state = state.copyWith(interval: newInterval);
  }
}

// O Provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier();
    });
