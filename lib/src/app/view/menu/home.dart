///
/// Copyright (C) 2019 Andrious Solutions
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  16 Aug 2019
///
///

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' show Controller;

///
class WorkMenu extends Menu {
  ///
  WorkMenu() : super() {
    //
    _con = Controller();

    if (_con.app.loggedIn) {
      if (_con.app.isAnonymous) {
        tailItems = [
          PopupMenuItem(value: 'SignIn', child: L10n.t('Sign in...')),
        ];
      } else {
        tailItems = [
          PopupMenuItem(value: 'Logout', child: L10n.t('Logout')),
        ];
      }
    } else {
      tailItems = [
        PopupMenuItem(value: 'SignIn', child: L10n.t('Sign in...')),
      ];
    }
  }
  late Controller _con;

  @override
  List<PopupMenuItem<dynamic>> menuItems() => [
        PopupMenuItem(
            key: const Key('resyncMenuItem'),
            value: 'Resync',
            child: L10n.t('Resync')),
        PopupMenuItem(
            key: const Key('localeMenuItem'),
            value: 'interface',
            child: Text('${L10n.s('Interface:')} $interface')),
        PopupMenuItem(
            key: const Key('localeMenuItem'),
            value: 'Locale',
            child: Text('${'Locale:'.tr} ${App.locale?.toLanguageTag()}')),
        if (App.useMaterial)
          PopupMenuItem(
            key: const Key('colorMenuItem'),
            value: 'color',
            child: L10n.t('Colour Theme'),
          ),
      ];

  /// Supply what the interface
  String get interface => App.useMaterial ? 'Material' : 'Cupertino';

  @override
  Future<void> onSelected(dynamic menuItem) async {
    switch (menuItem) {
      case 'Resync':
        _con.reSync();
        break;
      case 'interface':
        App.changeUI(App.useMaterial ? 'Cupertino' : 'Material');
        bool switchUI;
        if (App.useMaterial) {
          if (UniversalPlatform.isAndroid) {
            switchUI = false;
          } else {
            switchUI = true;
          }
        } else {
          if (UniversalPlatform.isAndroid) {
            switchUI = true;
          } else {
            switchUI = false;
          }
        }
        await Prefs.setBool('switchUI', switchUI);
        break;
      case 'Locale':
        //
        final locales = App.supportedLocales!;

        final initialItem = locales.indexOf(App.locale!);

        final spinner = ISOSpinner(
          initialItem: initialItem,
          supportedLocales: locales,
          onSelectedItemChanged: (int index) async {
            // Retrieve the available locales.
            final locale = L10n.getLocale(index);
            if (locale != null) {
              App.locale = locale;
              App.setState(() {});
            }
          },
        );

        await DialogBox(
          title: 'Current Language'.tr,
          body: [spinner],
          press01: () {
            spinner.onSelectedItemChanged(initialItem);
          },
          press02: () {},
          switchButtons: Settings.getLeftHanded(),
        ).show();

        break;
      case 'color':
        await showColorPicker();
        break;
      case 'Logout':
        _con.logOut();
        break;
      case 'SignIn':
        unawaited(_con.signIn());
        break;
      default:
    }
  }

  ///
  static Future<void> showColorPicker() async {
    // Set the current colour
    ColorPicker.color = Color(App.themeData!.primaryColor.value);

    await ColorPicker.showColorPicker(
      context: App.context!,
      onColorChange: (Color value) {
        /// Implement to take in a color change.
      },
      onChange: ([ColorSwatch<int?>? value]) {
        //
        App.setThemeData(swatch: value);
        App.setState(() {});
      },
      shrinkWrap: true,
    );
  }
}
