import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:updat/updat.dart';
import 'package:updat/updat_window_manager.dart';

class AutoUpdate extends StatefulWidget {
  final Widget child;

  AutoUpdate({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AutoUpdate> createState() => AutoUpdateState();
}

class AutoUpdateState extends State<AutoUpdate> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UpdatWindowManager(
      getLatestVersion: () async {
        final data = await http.get(Uri.parse(
          LATEST_RELEASE_URL,
        ));

        // Return the tag name, which is always a semantically versioned string.
        return jsonDecode(data.body)["tag_name"];
      },
      getBinaryUrl: (version) async {
        return "$DOWNLOAD_BASE_URL/$version/$fileName";
      },
      appName: "myWitWallet", // This is used to name the downloaded files.
      getChangelog: (_, __) async {
        final data = await http.get(Uri.parse(
          LATEST_RELEASE_URL,
        ));
        return jsonDecode(data.body)["body"];
      },
      updateDialogBuilder: customDialog,
      updateChipBuilder: customChip,
      currentVersion: VERSION_NUMBER,
      callback: (status) {},
      child: widget.child,
    );
  }
}

Widget customChip({
  required BuildContext context,
  required String? latestVersion,
  required String appVersion,
  required UpdatStatus status,
  required void Function() checkForUpdate,
  required void Function() openDialog,
  required void Function() startUpdate,
  required Future<void> Function() launchInstaller,
  required void Function() dismissUpdate,
}) {
  final theme = Theme.of(context);
  if (UpdatStatus.available == status ||
      UpdatStatus.availableWithChangelog == status) {
    return Tooltip(
      message: localization.updateToVersion(latestVersion!.toString()),
      child: ElevatedButton.icon(
        onPressed: openDialog,
        icon: const Icon(Icons.system_update_alt_rounded),
        label: Text(localization.updateAvailable),
      ),
    );
  }

  if (UpdatStatus.downloading == status) {
    return Tooltip(
      message: localization.pleaseWait,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: SizedBox(
          width: 15,
          height: 15,
          child: buildCircularProgress(context, theme),
        ),
        label: Text(localization.downloading),
      ),
    );
  }

  if (UpdatStatus.readyToInstall == status) {
    return Tooltip(
      message: localization.clickToInstall,
      child: ElevatedButton.icon(
        onPressed: launchInstaller,
        icon: const Icon(Icons.check_circle),
        label: Text(localization.readyToInstall),
      ),
    );
  }

  if (UpdatStatus.error == status) {
    return Tooltip(
      message: localization.updateError,
      child: ElevatedButton.icon(
        onPressed: startUpdate,
        icon: const Icon(Icons.warning),
        label: Text(localization.errorTryAgain),
      ),
    );
  }

  return Container();
}

void customDialog({
  required BuildContext context,
  required String? latestVersion,
  required String appVersion,
  required UpdatStatus status,
  required String? changelog,
  required void Function() checkForUpdate,
  required void Function() openDialog,
  required void Function() startUpdate,
  required Future<void> Function() launchInstaller,
  required void Function() dismissUpdate,
}) {
  final theme = Theme.of(context);
  final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      surfaceTintColor: Colors.transparent,
      scrollable: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(extendedTheme.borderRadius!)),
      title: Flex(
        direction: Axis.vertical,
        children: [
          Icon(Icons.update, size: 24),
          const SizedBox(height: 8),
          Text(localization.updateAvailable),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.newVersionAvailable),
          const SizedBox(height: 8),
          Text(localization.newVersion(latestVersion!.toString())),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(localization.later),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            startUpdate();
          },
          child: Text(localization.updateNow),
        ),
      ],
    ),
  );
}

String get fileName {
  switch (Platform.operatingSystem) {
    case 'windows':
      {
        return WINDOWS_FILE_NAME;
      }

    case 'macos':
      {
        return MACOS_FILE_NAME;
      }

    case 'linux':
      {
        return LINUX_FILE_NAME;
      }
    default:
      {
        return DEFAULT_FILE_NAME;
      }
  }
}
