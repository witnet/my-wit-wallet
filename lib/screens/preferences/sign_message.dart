import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/screens/preferences/export_signed_msg.dart';
import 'package:my_wit_wallet/screens/preferences/sign_message_form.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef void VoidCallback();

class SignMessage extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback closeSetting;

  SignMessage({
    Key? key,
    required this.scrollController,
    required this.closeSetting,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => SignMessageState();
}

class SignMessageState extends State<SignMessage> {
  Map<String, dynamic>? signedMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setSignedMessage(Map<String, dynamic> message) {
    widget.scrollController.jumpTo(0.0);
    setState(() {
      signedMessage = message;
    });
  }

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (previous, current) {
        return ClosableView(closeSetting: widget.closeSetting, children: [
          Text(
            _localization.messageSigning,
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Text(_localization.messageSigning01,
              style: theme.textTheme.bodyLarge),
          SizedBox(height: 16),
          signedMessage == null
              ? SignMessageForm(
                  scrollController: widget.scrollController,
                  signedMessage: _setSignedMessage)
              : ExportSignMessage(
                  scrollController: widget.scrollController,
                  signedMessage: signedMessage!),
        ]);
      },
    );
  }
}
