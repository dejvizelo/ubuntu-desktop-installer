import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wizard_router/wizard_router.dart';
import 'package:yaru/yaru.dart' as yaru;

import 'l10n/app_localizations.dart';
import 'pages/allocate_disk_space_page.dart';
import 'pages/choose_your_look_page.dart';
import 'pages/installation_slides/installation_slides_page.dart';
import 'pages/keyboard_layout/keyboard_layout_page.dart';
import 'pages/try_or_install/try_or_install_page.dart';
import 'pages/turn_off_rst_page.dart';
import 'pages/updates_other_software/updates_other_software_page.dart';
import 'pages/welcome/welcome_page.dart';
import 'pages/who_are_you/who_are_you_page.dart';
import 'pages/write_changes_to_disk_page.dart';
import 'routes.dart';
import 'settings.dart';

class UbuntuDesktopInstallerApp extends StatelessWidget {
  const UbuntuDesktopInstallerApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Settings.of(context).locale,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: yaru.lightTheme,
      darkTheme: yaru.darkTheme,
      themeMode: Settings.of(context).theme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        const LocalizationsDelegateOc(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Wizard(
        initialRoute: Routes.welcome,
        routes: <String, WidgetBuilder>{
          Routes.welcome: WelcomePage.create,
          Routes.tryOrInstall: TryOrInstallPage.create,
          Routes.turnOffRST: TurnOffRSTPage.create,
          Routes.keyboardLayout: KeyboardLayoutPage.create,
          Routes.updatesOtherSoftware: UpdatesOtherSoftwarePage.create,
          Routes.allocateDiskSpace: AllocateDiskSpacePage.create,
          Routes.writeChangesToDisk: WriteChangesToDiskPage.create,
          Routes.whoAreYou: WhoAreYouPage.create,
          Routes.chooseYourLook: ChooseYourLookPage.create,
          Routes.installationSlides: InstallationSlidesPage.create,
        },
        onNext: (settings) {
          switch (settings.name) {
            case Routes.tryOrInstall:
              switch (settings.arguments as Option?) {
                case Option.repairUbuntu:
                  return Routes.repairUbuntu;
                case Option.tryUbuntu:
                  return Routes.tryUbuntu;
                default:
                  // TODO: detect if we need to show the "Turn off RST" page,
                  // or if we can proceed directly to installation
                  //return Routes.turnOffRST;
                  return Routes.keyboardLayout;
              }
            default:
              return null;
          }
        },
      ),
    );
  }
}
