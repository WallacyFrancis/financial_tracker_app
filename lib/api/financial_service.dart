import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/asset_model.dart';
import '../models/time_series_model.dart';

class FinancialService {
  static const String _baseUrl = 'https://www.alphavantage.co/query';
  final String? _apiKey = dotenv.env['ALPHA_VANTAGE_API_KEY'];

  // Função para buscar a série temporal de um ativo (dados para o gráfico)
  Future<List<TimeSeriesPoint>> getTimeSeries(
    String symbol,
    String interval,
  ) async {
    // A API da Alpha Vantage usa funções diferentes para intervalos diferentes
    // Ex: TIME_SERIES_INTRADAY para minutos/horas, TIME_SERIES_DAILY para dias
    final function = _getFunctionForInterval(interval);

    final response = await _get(
      function: function,
      symbol: symbol,
      interval: function.contains('INTRADAY') ? interval : null,
    );

    // A estrutura do JSON de resposta muda dependendo da função
    final timeSeriesKey = response.keys.firstWhere(
      (k) => k.contains('Time Series'),
    );

    final Map<String, dynamic> timeSeriesData = response[timeSeriesKey];

    return timeSeriesData.entries.map((entry) {
      return TimeSeriesPoint(
        time: DateTime.parse(entry.key),
        close: double.parse(entry.value['4. close']),
      );
    }).toList();
  }

  // Função para buscar informações gerais sobre um ativo
  Future<Asset> getAssetOverview(String symbol) async {
    final response = await _get(function: 'OVERVIEW', symbol: symbol);

    return Asset.fromJson(response);
  }

  // Função para buscar resultados de pesquisa por um símbolo/nome
  Future<List<Map<String, dynamic>>> searchAssets(String keywords) async {
    final response = await _get(function: 'SYMBOL_SEARCH', keywords: keywords);
    final List<dynamic> bestMatches = response['bestMatches'] ?? [];
    return bestMatches.cast<Map<String, dynamic>>();
  }

  // --- Funções Auxiliares Privadas ---
  Future<Map<String, dynamic>> _get({
    required String function,
    String? symbol,
    String? interval,
    String? keywords,
  }) async {
    if (_apiKey == null) {
      throw Exception('Chave da API não encontrada no arquivo .env');
    }

    final Map<String, String> queryParams = {
      'function': function,
      'symbol': symbol ?? '',
      'apikey': _apiKey!,
      if (interval != null) 'interval': interval,
      if (keywords != null) 'keywords': keywords,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // A API pode retornar uma nota sobre o limite de chamadas, que não queremos tratar como erro.
      if (data['Note'] != null) {
        print('API Note: ${data['Note']}');
        if (data.keys.length == 1) throw Exception('API Limit Reached');
      }

      if (data['Error Message'] != null) {
        throw Exception('API Error: ${data['Error Message']}');
      }

      return data;
    } else {
      throw Exception('Failed to load data from Alpha Vantage');
    }
  }

  String _getFunctionForInterval(String interval) {
    if (interval.contains('min') || interval.contains('h')) {
      return 'TIME_SERIES_INTRADAY';
    } else if (interval.contains('D')) {
      return 'TIME_SERIES_DAILY';
    } else if (interval.contains('W')) {
      return 'TIME_SERIES_WEEKLY';
    } else {
      return 'TIME_SERIES_MONTHLY';
    }
  }
}
