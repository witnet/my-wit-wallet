import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:flutter/material.dart';

@immutable
class ThemeState extends Equatable {
  final ThemeData themeData;
  ThemeState({required this.themeData}) : super();

  @override
  List<Object?> get props => [themeData];
}

@immutable
abstract class ThemeEvent extends Equatable {
  const ThemeEvent() : super();
}

class ThemeChanged extends ThemeEvent {
  ThemeChanged(this.theme);
  final WalletTheme theme;

  @override
  List<Object?> get props => [theme];
}

class BlocTheme extends Bloc<ThemeEvent, ThemeState> {
  BlocTheme() : super(initialState);

  static ThemeState get initialState =>
      ThemeState(themeData: walletThemeData[WalletTheme.Light]!);

  @override
  Stream<ThemeState> mapEventToState(ThemeEvent event) async* {
    if (event is ThemeChanged) {
      yield ThemeState(themeData: walletThemeData[event.theme]!);
    }
  }
}
