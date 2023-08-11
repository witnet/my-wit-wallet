import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';

typedef void VoidCallback(NavAction? value);

class ResetDisclaimer extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;

  ResetDisclaimer({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => ResetDisclaimerState();
}

class ResetDisclaimerState extends State<ResetDisclaimer>
    with TickerProviderStateMixin {
  List<AnimationController> _providerControllerList = <AnimationController>[];
  bool isNextAllow = false;
  bool isCheckBoxFocus = false;
  FocusNode _checkBoxFocusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    _checkBoxFocusNode.addListener(_handleFocus);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _providerControllerList.forEach((controller) {
      controller.dispose();
    });
  }

  _handleFocus() {
    setState(() {
      this.isCheckBoxFocus = _checkBoxFocusNode.hasFocus;
    });
  }

  void prevAction() {
    Navigator.pushNamed(context, '/');
  }

  void nextAction() {
    // TODO: delete storage and show modal when deleted
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.unset));
  }

  NavAction prev() {
    return NavAction(
      label: 'Back',
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
      action: nextAction,
    );
  }

  Widget buildOrderedListItem(String number, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(number,
            style: theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            )),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text('Re-establish your wallet', style: theme.textTheme.titleLarge!),
        SizedBox(
          height: 16,
        ),
        Text(
          'Please, read carefully before continuing. Your attention is crucial! ',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
            'Clicking \"Continue\" will result in the permanent deletion of your current wallet data. If you proceed, you\'ll need to import an existing wallet or create a new one to access your funds.',
            style: theme.textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
        Text('What to do?',
            style: theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            )),
        SizedBox(
          height: 10,
        ),
        buildOrderedListItem('1. ',
            'Make sure you have stored your recovery seed phrase or Xprv.'),
        SizedBox(
          height: 10,
        ),
        buildOrderedListItem('2. ',
            'Click continue to delete your storage and import your wallet again.'),
        // TODO: add color red to checkbox
        LabeledCheckbox(
            focusNode: _checkBoxFocusNode,
            isFocus: isCheckBoxFocus,
            checked: isNextAllow,
            label: 'I will be careful, I promise!',
            onChanged: (value) => {
                  setState(() {
                    isNextAllow = !isNextAllow;
                  }),
                  if (isNextAllow)
                    {widget.nextAction(next)}
                  else
                    {widget.nextAction(null)}
                })
      ],
    );
  }
}
