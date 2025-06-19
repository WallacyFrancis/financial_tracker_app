import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier é uma classe otimizada para gerenciar um único "estado" (neste caso, o ThemeMode).
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    // Acessamos o estado atual com a propriedade 'state'.
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

// Este é o provider global que vamos usar na UI para acessar o ThemeNotifier.
// StateNotifierProvider é o tipo de provider para usar com um StateNotifier.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
