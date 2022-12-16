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
  _SettingsWidgetState() : super(ThemeController()) {
    _theme = controller as ThemeController;
  }
  late ThemeController _theme;

  @override
  void initState() {
    super.initState();
    _descending = Settings.getOrder();
    _leftHanded = Settings.isLeftHanded();
    _con = Controller();
  }

  late bool _descending;
  late bool _leftHanded;
  late Controller _con;
  bool? _refresh;

  @override
  void dispose() {
    super.dispose();
    if (_refresh == true) {
      _con.requery();
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: _cardSettings(),
      );

  List<Widget> _cardSettings() {
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
                'NOTIFICATIONS PREFERENCES',
              ),
            ))
          ]),
          Row(children: [
            InkWell(
                onTap: () => _theme.showNotifications(),
                child: L10n.t(
                  'Notification Settings',
                )),
          ]),
          Row(children: const [Text('')]),
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () => _theme.showSounds(),
                child: L10n.t(
                  'Notification Sounds',
                  softWrap: true,
                ),
              ),
            ),
          ]),
          Row(children: const [Text('')]),
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () => _theme.showLEDColour(),
                child: L10n.t(
                  'LED Colour',
                  softWrap: true,
                ),
              ),
            ),
          ]),
          Row(
            children: const [Text('')],
          ),
        ]),
      ),
      Card(
        child: Column(children: [
          Row(children: [
            Expanded(
                child: ListTile(
              title: L10n.t(
                'RECORD PREFERENCES',
              ),
            ))
          ]),
          Row(children: [
            InkWell(
                onTap: () {},
                child: L10n.t(
                  'Item Record Preferences',
                )),
          ]),
          Row(
            children: const [Text('')],
          ),
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () {},
                child: Text('${L10n.s(
                  'How certain records are further handled',
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
    final darkMode = _theme.isDarkMode;
    final List<Widget> interface = [
      Row(children: [
        Expanded(
            child: ListTile(
          title: L10n.t('INTERFACE PREFERENCES'),
        ))
      ]),
      Row(children: [
        InkWell(
            onTap: () {},
            child: L10n.t(
              'Sorted Order of Items',
            )),
      ]),
      Row(
        children: const [Text('')],
      ),
      Row(children: [
        Expanded(
          child: L10n.t(
            'Check so the items are in descending order with the most recent items listed first',
          ),
        ),
        Checkbox(
          value: _descending,
          onChanged: orderItems,
        ),
      ]),
      Row(children: [
        Expanded(
          child: L10n.t(
            'Left-handed user',
          ),
        ),
        Checkbox(
          value: _leftHanded,
          onChanged: switchButton,
        ),
      ]),
      ListTile(
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
              App.themeData = _theme.setDarkMode();
            } else {
              _theme.isDarkMode = false;
              App.setThemeData();
            }
            setState(() {});
            App.setState(() {});
          },
        ),
      ),
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

  // ignore: avoid_positional_boolean_parameters
  void orderItems(bool? value) {
    Settings.setOrder(value!);
    setState(() {
      _descending = value;
    });
    _refresh = true;
  }

  // ignore: avoid_positional_boolean_parameters
  void switchButton(bool? value) {
    if (value != null) {
      Settings.setLeftHanded(value);
      setState(() => _leftHanded = value);
      _con.setState(() {});
    }
  }

  // A custom error routine if you want.
  @override
  void onError(FlutterErrorDetails details) {
    super.onError(details);
  }
}

/// Locale iOS Spinner
class LocaleSpinner extends ISOSpinner {
  ///
  LocaleSpinner({super.key})
      : super(
          initialItem: L10n.supportedLocales.indexOf(App.locale!),
          supportedLocales: L10n.supportedLocales,
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
