import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:subiquity_client/subiquity_client.dart';
import 'package:ubuntu_desktop_installer/l10n.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:ubuntu_wizard/constants.dart';
import 'package:ubuntu_wizard/widgets.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'guided_reformat_model.dart';

/// Select a storage for guided reformatting.
class GuidedReformatPage extends ConsumerWidget {
  const GuidedReformatPage({super.key});

  static Future<bool> load(WidgetRef ref) {
    return ref
        .read(guidedReformatModelProvider.notifier)
        .loadGuidedStorage()
        .then((_) => true);
  }

  String prettyFormatPartition(Disk disk, Partition partition) {
    return '${disk.sysname}${partition.number}';
  }

  /// Formats a disk in a pretty way e.g. "sda ATA Maxtor (123 GB)"
  String prettyFormatDisk(Disk disk) {
    final fullName = <String?>[
      disk.model,
      disk.vendor,
    ].where((p) => p?.isNotEmpty == true).join(' ');

    final size = filesize(disk.size);
    return '${disk.sysname} - $size $fullName';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(guidedReformatModelProvider);
    final lang = AppLocalizations.of(context);
    final flavor = Flavor.of(context);
    return WizardPage(
      title: YaruWindowTitleBar(
        title: Text(lang.selectGuidedStoragePageTitle(flavor.name)),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(lang.selectGuidedStorageDropdownLabel),
              const SizedBox(width: kContentSpacing),
              Expanded(
                child: MenuButtonBuilder<int>(
                  values: List.generate(model.storages.length, (i) => i),
                  selected: model.selectedIndex,
                  onSelected: (i) => model.selectStorage(i),
                  itemBuilder: (context, index, child) {
                    final disk = model.getDisk(index);
                    return disk != null
                        ? Text(prettyFormatDisk(disk), key: ValueKey(index))
                        : const SizedBox.shrink();
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: kContentSpacing),
          if (model.selectedStorage != null)
            Text(lang.selectGuidedStorageInfoLabel),
          const SizedBox(height: kContentSpacing * 2),
          if (model.selectedDisk != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/select_guided_storage/ubuntu.svg',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(height: kContentSpacing / 2),
                  Text(
                    flavor.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: kContentSpacing / 2),
                  Text(model.selectedDisk?.sysname ?? ''),
                  const SizedBox(height: kContentSpacing / 2),
                  Text(
                    filesize(model.selectedDisk?.size ?? 0),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomBar: WizardBar(
        leading: WizardButton.previous(context),
        trailing: [
          WizardButton.next(
            context,
            root: model.isDone,
            onNext: model.saveGuidedStorage,
            // If the user returns back to select another disk, the previously
            // configured guided storage must be reset to avoid multiple disks
            // being configured for guided partitioning.
            onBack: model.resetGuidedStorage,
          ),
        ],
      ),
    );
  }
}
