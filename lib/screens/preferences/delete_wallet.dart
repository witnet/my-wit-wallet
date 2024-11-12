import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/preferences/logout.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/buttons/text_btn.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'package:my_wit_wallet/widgets/ordered_list_item.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

typedef void VoidCallback();

class DeleteSingleWallet extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback closeSetting;

  DeleteSingleWallet({
    Key? key,
    required this.scrollController,
    required this.closeSetting,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => DeleteSingleWalletState();
}

class DeleteSingleWalletState extends State<DeleteSingleWallet> {
  bool isNextAllow = false;
  bool isCheckBoxFocus = false;
  bool isLoading = false;
  FocusNode _checkBoxFocusNode = FocusNode();

  @override
  void initState() {
    _checkBoxFocusNode.addListener(_handleFocus);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _handleFocus() {
    setState(() {
      this.isCheckBoxFocus = _checkBoxFocusNode.hasFocus;
    });
  }

  void closeModal() {
    Navigator.pop(context);
    toggleCheckBox(false);
  }

  void deleteStorageAndContinue() async {
    final theme = Theme.of(context);
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    Wallet currentWallet = db.walletStorage.currentWallet;
    bool storageDeleted = await db.deleteWallet(currentWallet);
    if (storageDeleted) {
      final isdbOpen = await db.openDatabase();
      if (isdbOpen) {
        // Close current modal
        Navigator.pop(context);
        // Show next modal
        showStorageDeletedMessage();
      } else {
        closeModal();
        showErrorSnackBar(
            context: context,
            theme: theme,
            text: localization.errorDeletingWallet);
      }
    } else {
      closeModal();
      showErrorSnackBar(
          context: context,
          theme: theme,
          text: localization.errorDeletingWallet);
    }
  }

  void showDeleteStorageAlert() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return buildAlertDialog(
        color: extendedTheme.errorColor,
        context: context,
        actions: [
          CustomButton(
              color: theme.textTheme.bodyLarge!.color,
              padding: EdgeInsets.zero,
              text: localization.cancel,
              type: CustomBtnType.secondary,
              sizeCover: false,
              enabled: true,
              onPressed: () => {setState(() => closeModal())}),
          CustomButton(
              color: extendedTheme.errorColor,
              padding: EdgeInsets.zero,
              text: localization.delete,
              type: CustomBtnType.primary,
              sizeCover: false,
              enabled: true,
              onPressed: deleteStorageAndContinue)
        ],
        icon: FontAwesomeIcons.circleExclamation,
        title: localization.deleteWalletWarning,
        content: Container());
  }

  void showStorageDeletedMessage() {
    return buildAlertDialog(
        context: context,
        actions: [
          TextBtn(
              padding: EdgeInsets.all(8),
              text: localization.continueLabel,
              onPressed: () => logout(context))
        ],
        icon: FontAwesomeIcons.check,
        title: localization.deleteWalletSuccess,
        content: Container());
  }

  void toggleCheckBox(bool? value) {
    setState(() {
      isNextAllow = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    TextStyle bodyLarge = theme.textTheme.bodyLarge!;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (previous, current) {
        return ClosableView(
            title: localization.deleteWalletSettings,
            closeSetting: widget.closeSetting,
            children: [
              Text(localization.readCarefully, style: bodyLarge),
              SizedBox(height: 10),
              Text(localization.reestablishInstructions, style: bodyLarge),
              SizedBox(height: 10),
              Text(localization.whatToDo, style: theme.textTheme.titleMedium),
              SizedBox(height: 10),
              buildOrderedListItem(
                  '1. ', localization.reestablishSteps01, context),
              SizedBox(height: 10),
              buildOrderedListItem(
                  '2. ', localization.reestablishSteps02, context),
              LabeledCheckbox(
                focusNode: _checkBoxFocusNode,
                isFocus: isCheckBoxFocus,
                checked: isNextAllow,
                label: localization.walletSecurityConfirmLabel,
                onChanged: toggleCheckBox,
              ),
              SizedBox(height: 16),
              CustomButton(
                  padding: EdgeInsets.only(bottom: 0),
                  text: localization.delete,
                  type: CustomBtnType.primary,
                  isLoading: isLoading,
                  enabled: isNextAllow,
                  onPressed: () async {
                    setState(() => isLoading = true);
                    if (isNextAllow) showDeleteStorageAlert();
                    setState(() => isLoading = false);
                  }),
            ]);
      },
    );
  }
}
