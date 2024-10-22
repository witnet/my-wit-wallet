import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/login/view/password_validate.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

Future<String?> unlockKeychainModal(
    {required ThemeData theme,
    required String title,
    required String imageName,
    required BuildContext context,
    required VoidCallback onAction,
    required String routeToRedirect}) {
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return Future.delayed(
      Duration.zero,
      () => showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            String _password = '';
            String? _passwordInputErrorText;
            return StatefulBuilder(builder: (context, setState) {
              void _updatePassword({required String password}) {
                _password = password;
              }

              void _clearError() {
                setState(() => _passwordInputErrorText = null);
              }

              Future<void> _login(
                  {required bool validate, required String password}) async {
                ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
                _password = password;
                try {
                  if (validate) {
                    bool valid = await apiDatabase.verifyPassword(password);
                    if (!valid) {
                      setState(() => _passwordInputErrorText =
                          localization.invalidPassword);
                    } else {
                      onAction();
                      Navigator.popUntil(
                          context, ModalRoute.withName(routeToRedirect));
                      ScaffoldMessenger.of(context).clearSnackBars();
                    }
                  }
                } catch (err) {
                  rethrow;
                }
              }

              return AlertDialog(
                title: Text(
                  title,
                  style: theme.textTheme.titleLarge,
                ),
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(extendedTheme.borderRadius!)),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  svgThemeImage(theme, name: imageName, height: 100),
                  SizedBox(height: 16),
                  PasswordValidation(
                    validate: _login,
                    passwordUpdates: _updatePassword,
                    clearError: _clearError,
                    passwordInputErrorText: _passwordInputErrorText,
                  )
                ]),
                actionsPadding: EdgeInsets.only(bottom: 16, right: 16, top: 0),
                actions: [
                  PaddedButton(
                      padding: EdgeInsets.zero,
                      text: localization.close,
                      type: ButtonType.secondary,
                      sizeCover: false,
                      color: theme.textTheme.bodyLarge!.color,
                      enabled: true,
                      onPressed: () => {
                            Navigator.popUntil(
                                context, ModalRoute.withName(routeToRedirect)),
                            ScaffoldMessenger.of(context).clearSnackBars(),
                          }),
                  PaddedButton(
                      padding: EdgeInsets.zero,
                      text: localization.continueLabel,
                      sizeCover: false,
                      type: ButtonType.primary,
                      enabled: true,
                      onPressed: () =>
                          {_login(validate: true, password: _password)})
                ],
              );
            });
          }));
}
