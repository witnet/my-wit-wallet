part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeData themeData;
  ThemeState({required this.themeData}) : super();

  @override
  List<Object?> get props => [themeData];
}
