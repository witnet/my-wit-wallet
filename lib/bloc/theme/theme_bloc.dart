import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(initialState) {
    on<ThemeChanged>(_themeChange);
  }

  static ThemeState get initialState =>
      ThemeState(themeData: walletThemeData[WalletTheme.Light]!);

  void _themeChange(ThemeChanged event, Emitter<ThemeState> emit) {
    emit(ThemeState(themeData: walletThemeData[event.theme]!));
  }
}
