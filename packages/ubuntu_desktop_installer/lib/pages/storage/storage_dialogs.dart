import 'package:flutter/material.dart';
import 'package:ubuntu_desktop_installer/l10n.dart';
import 'package:ubuntu_desktop_installer/widgets.dart';
import 'package:ubuntu_wizard/constants.dart';
import 'package:ubuntu_wizard/widgets.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'storage_model.dart';

/// Shows a dialog to select advanced installation features.
Future<void> showAdvancedFeaturesDialog(
    BuildContext context, StorageModel model) async {
  final advancedFeature = ValueNotifier(model.advancedFeature);
  final encryption = ValueNotifier(model.encryption);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final lang = AppLocalizations.of(context);
      final flavor = Flavor.of(context);

      return AlertDialog(
        title: YaruDialogTitleBar(
          title: Text(lang.installationTypeAdvancedTitle),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: kContentPadding.copyWith(
            top: kContentSpacing, bottom: kContentSpacing),
        actionsPadding: kFooterPadding,
        buttonPadding: EdgeInsets.zero,
        scrollable: true,
        content: AnimatedBuilder(
          animation: Listenable.merge([advancedFeature, encryption]),
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                YaruRadioButton<AdvancedFeature>(
                  title: Text(lang.installationTypeNone),
                  value: AdvancedFeature.none,
                  groupValue: advancedFeature.value,
                  onChanged: (v) => advancedFeature.value = v!,
                ),
                const SizedBox(height: kContentSpacing),
                YaruRadioButton<AdvancedFeature>(
                  title: Text(lang.installationTypeLVM(flavor.name)),
                  value: AdvancedFeature.lvm,
                  groupValue: advancedFeature.value,
                  onChanged: (v) => advancedFeature.value = v!,
                ),
                Padding(
                  padding: kContentIndentation,
                  child: YaruCheckButton(
                    title: Text(lang.installationTypeEncrypt(flavor.name)),
                    subtitle: Text(lang.installationTypeEncryptInfo),
                    value: encryption.value,
                    onChanged: advancedFeature.value == AdvancedFeature.lvm
                        ? (v) => encryption.value = v!
                        : null,
                  ),
                ),
                const SizedBox(height: kContentSpacing),
                // https://github.com/canonical/ubuntu-desktop-installer/issues/373
                // YaruRadioButton<AdvancedFeature>(
                //   title: Text(lang.installationTypeZFS),
                //   value: AdvancedFeature.zfs,
                //   groupValue: advancedFeature.value,
                //   onChanged: (v) => advancedFeature.value = v!,
                // ),
              ],
            );
          },
        ),
        actions: [
          PushButton.outlined(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UbuntuLocalizations.of(context).cancelLabel),
          ),
          const SizedBox(width: kButtonBarSpacing),
          PushButton.filled(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(UbuntuLocalizations.of(context).okLabel),
          ),
        ],
      );
    },
  );

  if (result == true) {
    model.advancedFeature = advancedFeature.value;
    model.encryption = encryption.value;
  }
}
