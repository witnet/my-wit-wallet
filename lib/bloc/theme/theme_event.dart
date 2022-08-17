part of 'theme_bloc.dart';

class ThemeEvent extends Equatable {
  const ThemeEvent() : super();

  @override
  List<Object?> get props => [];
}

class ThemeChanged extends ThemeEvent {
  ThemeChanged(this.theme);
  final WalletTheme theme;

  @override
  List<Object?> get props => [theme];
}
