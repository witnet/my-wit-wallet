import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/widgets/labeled_checkbox.dart';

typedef void FunctionCallback(Function? value);

class DisclaimerCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;

  DisclaimerCard({
    Key? key,
    required FunctionCallback this.nextAction,
    required FunctionCallback this.prevAction,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => DisclaimerCardState();
}

class DisclaimerCardState extends State<DisclaimerCard>
    with TickerProviderStateMixin {
  List<AnimationController> _providerControllerList = <AnimationController>[];
  bool isNextAllow = false;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _providerControllerList.forEach((controller) {
      controller.dispose();
    });
  }

  void prev() {
    Navigator.pop(context);
  }

  void next() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Hey, listen!',
          style: theme.textTheme.headline3,
        ),
        Text(
          'Please, read carefully before continuing.',
          style: theme.textTheme.headline3,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
            'A wallet is an app that keeps your credentials safe and lets you interface with the Witnet blockchain in many ways: from transferring Wit to someone else to creating smart contracts.',
            style: theme.textTheme.bodyText1),
        SizedBox(
          height: 10,
        ),
        Text(
            'You should never share your seed phrase with anyone. We at Witnet do not store your seed phrase and will never ask you to share it with us. If you lose your seed phrase, you will permanently lose access to your wallet and your funds.',
            style: theme.textTheme.bodyText1),
        SizedBox(
          height: 10,
        ),
        Text(
            'If someone finds or sees your seed phrase, they will have access to your wallet and all of your funds.',
            style: theme.textTheme.bodyText1),
        SizedBox(
          height: 10,
        ),
        Text(
            'We recommend storing your seed phrase on paper somewhere safe. Do not store it in a file on your computer or anywhere electronically.',
            style: theme.textTheme.bodyText1),
        SizedBox(
          height: 10,
        ),
        Text(
            'By accepting these disclaimers, you commit to comply with the explained restrictions and digitally sign your conformance using your Witnet wallet.',
            style: theme.textTheme.bodyText1),
        SizedBox(
          height: 10,
        ),
        LabeledCheckbox(
            checked: isNextAllow,
            label: 'I will be carefull, I promise!',
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
