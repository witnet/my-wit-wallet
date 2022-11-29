import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/info_element.dart';

typedef void VoidCallback(bool value);

class ReviewStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  ReviewStep({
    required this.nextAction,
    required this.currentWallet,
  });

  @override
  State<StatefulWidget> createState() => ReviewStepState();
}

class ReviewStepState extends State<ReviewStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void nextAction() async {
    // Sign transaction
    final vtt =
        BlocProvider.of<VTTCreateBloc>(context).state.vtTransaction.body;
    BlocProvider.of<VTTCreateBloc>(context).add(SignTransactionEvent(
        currentWallet: widget.currentWallet, vtTransactionBody: vtt));
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
      action: nextAction,
    );
  }

  ///
  void send(VTTransaction vtTransaction) {
    BlocProvider.of<VTTCreateBloc>(context)
        .add(SendTransactionEvent(vtTransaction));
  }

  _launchExplorerSearch(String searchItem) async {
    Uri url = Uri(path: 'https://witnet.network/search/$searchItem');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildTransactionJsonViewer(
      BuildContext context, VTTransaction vtTransaction) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Transaction ID:',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: vtTransaction.transactionID));
              },
              icon: Icon(FontAwesomeIcons.copy),
            ),
            Row(
              children: [
                Text(
                  'JSON Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: vtTransaction.rawJson(asHex: true)));
                  },
                  icon: Icon(FontAwesomeIcons.copy),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget vtBlocContainer() {
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
      builder: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.building) {
        } else if (state.vttCreateStatus == VTTCreateStatus.exception) {
        } else if (state.vttCreateStatus == VTTCreateStatus.signing) {
          return Text('Signing Transaction');
        } else if (state.vttCreateStatus == VTTCreateStatus.finished) {
          // call send after sign
          return _buildTransactionJsonViewer(context, state.vtTransaction);
        } else if (state.vttCreateStatus == VTTCreateStatus.sending) {
          // Sending vtt
        } else if (state.vttCreateStatus == VTTCreateStatus.accepted) {
          ElevatedButton(
              onPressed: () {
                /// Launch the Explorer in the machines default browser
                _launchExplorerSearch(state.vtTransaction.transactionID);
              },
              child: Text('View on Explorer'));
        }
        return SizedBox(
          height: 16,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int fee = BlocProvider.of<VTTCreateBloc>(context).feeNanoWit;
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
      builder: (context, state) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Transaction details',
            style: theme.textTheme.headline3,
          ),
          SizedBox(height: 24),
          InfoElement(
              label: 'To',
              text: state.vtTransaction.body.outputs.first.pkh.address),
          SizedBox(height: 16),
          InfoElement(
            label: 'Amount',
            text: state.vtTransaction.body.outputs.first.value.toString(),
          ),
          SizedBox(height: 16),
          InfoElement(label: 'Fee', text: '${fee.toString()} nanoWit'),
          SizedBox(height: 24),
          vtBlocContainer(),
        ]);
      },
    );
  }
}
