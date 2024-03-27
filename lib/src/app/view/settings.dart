///
/// Copyright (C) 2018 Andrious Solutions
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
///          Created  10 Sep 2018
///

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart' hide ColorPicker;

import 'package:workingmemory/src/controller.dart';

/// The Settings widget
class SettingsWidget extends StatefulWidget {
  ///
  const SettingsWidget({Key? key}) : super(key: key);
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateX<SettingsWidget> {
  _SettingsWidgetState() : super(controller: ThemeController()) {
    _theme = controller as ThemeController;
  }
  late ThemeController _theme;

  @override
  void initState() {
    super.initState();
    _itemsOrder = Settings.itemsOrder;
    _leftSided = Settings.leftSided ? 'Left' : 'Right';
    _showSortArrow = Settings.showBottomBar;
    _leadingIcon = Settings.leadingIcon;
    _leadingDrawer = Settings.leadingDrawer;
    _portraitOnly = Settings.portraitOnly;
    _wasPortrait = _portraitOnly;

    _con = Controller();
  }

  late String _itemsOrder;
  late String _leftSided;
  late bool _showSortArrow;
  late bool _leadingIcon;
  late bool _leadingDrawer;
  late bool _portraitOnly;
  late bool _wasPortrait;

  late Controller _con;
  bool? _refresh;

  @override
  void dispose() {
    //
    if (_refresh ?? false) {
      //
      _con.requery();

      // Set in portrait or not
      if (_wasPortrait) {
        if (!_portraitOnly) {
          Settings.setPortraitOnly(_portraitOnly);
        }
      } else if (_portraitOnly) {
        Settings.setPortraitOnly(_portraitOnly);
      }
    }
    super.dispose();
  }

  @override
  Widget buildIn(BuildContext context) => ListView(
        physics: App.useCupertino ? null : const NeverScrollableScrollPhysics(),
        children: _settingsList(),
      );

  List<Widget> _settingsList() {
    //
    final List<Widget> settings = [
      Card(
        child: Column(children: _interfacePreference()),
      ),
    ];

    if (App.useCupertino) {
      final supportedLocales = L10n.supportedLocales;
      settings.add(Card(
        child: LocaleSpinner(),
      ));
    }

    settings.addAll([
      Card(
        child: Column(children: [
          Row(children: [
            Expanded(
                child: ListTile(
              title: L10n.t(
                'NOTIFICATIONS PREFERENCES'.tr,
              ),
            ))
          ]),
          Row(children: [
            InkWell(
                onTap: () => _theme.showNotifications(),
                child: L10n.t(
                  'Notification Settings'.tr,
                )),
          ]),
          const Row(children: [Text('')]),
          if (!kIsWeb)
            InkWell(
                onTap: () => _theme.showSounds(),
                child: Row(children: [
                  L10n.t(
                    'Notification Sounds'.tr,
                    softWrap: true,
                  ),
                ])),
          if (!kIsWeb) const Row(children: [Text('')]),
          if (!kIsWeb)
            Row(children: [
              Expanded(
                child: InkWell(
                  onTap: () => _theme.showLEDColour(),
                  child: L10n.t(
                    'LED Colour'.tr,
                    softWrap: true,
                  ),
                ),
              ),
            ]),
          if (!kIsWeb)
            const Row(
              children: [Text('')],
            ),
        ]),
      ),
      Card(
        child: Column(children: [
          Row(children: [
            Expanded(
                child: ListTile(
              title: L10n.t(
                'RECORD PREFERENCES'.tr,
              ),
            ))
          ]),
          Row(children: [
            InkWell(
                onTap: () {},
                child: L10n.t(
                  'Item Record Preferences'.tr,
                )),
          ]),
          const Row(
            children: [Text('')],
          ),
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () {},
                child: Text('${L10n.s(
                  'How certain records are further handled'.tr,
                )}\n'),
              ),
            ),
          ]),
        ]),
      ),
      Card(
        child: Settings.tapText(
          L10n.s('About Working Memory'),
          () {
            Settings.showAboutDialog(context);
          },
        ),
      ),
    ]);
    return settings;
  }

  List<Widget> _interfacePreference() {
    final List<Widget> interface = [
      Row(children: [
        Expanded(
            child: ListTile(
          title: L10n.t('INTERFACE PREFERENCES'),
        ))
      ]),
      itemsOrder(),
      alignLeftOrRight(),
      itemIconListTile(),
      drawerListTile(),
      portraitListTile(),
      darkModeListTile(),
    ];

    if (App.useCupertino) {
      interface.addAll([
        Row(
          children: [
            InkWell(
              onTap: () {
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
                Prefs.setBool('switchUI', switchUI);
//                App.refresh();
              },
              child: Text(
                  '${L10n.s('Interface:')} ${App.useMaterial ? 'Material' : 'Cupertino'}\n'),
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: WorkMenu.showColorPicker,
              child: Text('${L10n.s('Colour Theme')}\n'),
            ),
          ],
        )
      ]);
    }
    return interface;
  }

  void orderItems(String? value) {
    Settings.itemsOrder = value;
    setState(() => _itemsOrder = Settings.itemsOrder);
    _refresh = true;
  }

  // ignore: avoid_positional_boolean_parameters
  void leftSided(String value) {
//    if (value != null) {
    _leftSided = value;
    Settings.leftSided = value == 'Left';
    setState(() {});
    _con.setState(() {});
//    }
  }

  ///
  Widget itemsOrder() => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Row(children: [
            //   L10n.t('Order:'),
            // ]),
            Flexible(child: L10n.t('Order')),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: CupertinoSegmentedControl<String>(
                  groupValue: _itemsOrder,
                  onValueChanged: orderItems,
                  children: const {
                    'ascending': Text(' Ascending '),
                    'descending': Text('Descending'),
                  },
                ),
              ),
              Flexible(
                child: Checkbox(
                  value: _showSortArrow,
                  onChanged: (bool? value) {
                    if (value != null) {
                      Settings.showBottomBar = value;
                      _showSortArrow = value;
                      setState(() {});
                      _con.setState(() {});
                    }
                  },
                ),
              ),
            ]),
          ]);

  ///
  Widget alignLeftOrRight() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        L10n.t(
          'Interface sided:',
        ),
        CupertinoSegmentedControl<String>(
//          padding: const EdgeInsets.symmetric(horizontal: 12),
          // This represents a currently selected segmented control.
          groupValue: _leftSided,
          onValueChanged: leftSided,
          children: {
            'Left': L10n.t('  Left  '),
            'Right': L10n.t('  Right '),
          },
        ),
        const SizedBox(width: 30),
      ]);
  // Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
  //   L10n.t(
  //     '$_leftSided side:',
  //   ),
  //   Row(children: [
  //     Radio<String>(
  //       value: 'Left',
  //       groupValue: _leftSided,
  //       onChanged: leftSided,
  //     ),
  //     Radio<String>(
  //       value: 'Right',
  //       groupValue: _leftSided,
  //       onChanged: leftSided,
  //     ),
  //   ]),
  //   const SizedBox(width: 30),
  // ]);

  Widget itemIconListTile() => ListTile(
        leading: _leadingIcon
            ? const Icon(
                Icons.view_list_sharp,
              )
            : Transform.scale(
                scaleX: -1,
                child: const Icon(
                  Icons.view_list_sharp,
                ),
              ),
        title: L10n.t(
          'Leading Icon',
        ),
        trailing: Switch(
          value: _leadingIcon,
          onChanged: (value) {
            _leadingIcon = value;
            Settings.leadingIcon = value;
            _refresh = true;
            setState(() {});
          },
        ),
      );

  Widget drawerListTile() => ListTile(
        leading: _leadingDrawer
            ? const Icon(
                Icons.view_sidebar,
              )
            : Transform.scale(
                scaleX: -1,
                child: const Icon(
                  Icons.view_sidebar,
                ),
              ),
        title: L10n.t(
          'Leading Drawer',
        ),
        trailing: Switch(
          value: _leadingDrawer,
          onChanged: (value) {
            _leadingDrawer = value;
            Settings.leadingDrawer = value;
            _refresh = true;
            setState(() {});
          },
        ),
      );

  Widget portraitListTile() => ListTile(
        leading: _portraitOnly
            ? const Icon(
                Icons.crop_portrait,
              )
            : const Icon(
                Icons.crop_landscape,
              ),
        title: L10n.t(
          'Portrait Only',
        ),
        trailing: Switch(
          value: _portraitOnly,
          onChanged: (value) {
            _portraitOnly = value;
            _refresh = true;
            setState(() {});
          },
        ),
      );

  Widget darkModeListTile() {
    final darkMode = _theme.isDarkMode;
    return ListTile(
      leading: darkMode
          ? Image.asset(
              'assets/images/moon.png',
              height: 30,
              width: 26,
            )
          : Image.asset(
              'assets/images/sunny.png',
              height: 30,
              width: 26,
            ),
      title: L10n.t('Dark Mode'),
      trailing: Switch(
        value: darkMode,
        onChanged: (val) {
          if (val) {
            final theme = _theme.setDarkMode();
            App.themeData = theme;
            App.iOSThemeData = theme;
          } else {
            _theme.isDarkMode = false;
            App.setThemeData();
          }
          setState(() {});
          App.setState(() {});
        },
      ),
    );
  }

  // A custom error routine if you want.
  @override
  void onError(FlutterErrorDetails details) {
    super.onError(details);
  }
}

// /// Locale iOS Spinner
// class LocaleSpinner extends ISOSpinner {
//   ///
//   LocaleSpinner({super.key})
//       : super(
//           initialItem: L10n.supportedLocales.indexOf(App.locale!),
//           supportedLocales: L10n.supportedLocales,
//           onSelectedItemChanged: (int index) async {
//             // Retrieve the available locales.
//             final locale = L10n.getLocale(index);
//             if (locale != null) {
//               App.locale = locale;
//               App.setState(() {});
//             }
//           },
//         );
// }

/// Locale iOS Spinner
class LocaleSpinner extends SpinnerCupertino<Locale> {
  ///
  LocaleSpinner({super.key})
      : super(
          initValue: App.locale!,
          values: L10n.supportedLocales,
          itemBuilder: (BuildContext context, int index) => Text(
            L10n.supportedLocales[index].countryCode == null
                ? L10n.supportedLocales[index].languageCode
                : '${L10n.supportedLocales[index].languageCode}-${L10n.supportedLocales[index].countryCode}',
            style: const TextStyle(fontSize: 20),
          ),
          onSelectedItemChanged: (int index) async {
            // Retrieve the available locales.
            final locale = L10n.getLocale(index);
            if (locale != null) {
              App.locale = locale;
              App.setState(() {});
            }
          },
        );
}
