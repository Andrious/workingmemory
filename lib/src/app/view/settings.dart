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

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart';

/// The Settings widget
class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key key}) : super(key: key);
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateMVC<SettingsWidget> {
  _SettingsWidgetState() : super(ThemeController()) {
    _theme = controller;
  }
  ThemeController _theme;

  @override
  void initState() {
    super.initState();
    _descending = Settings.getOrder();
    _leftHanded = Settings.getLeftHanded();
    _con = Controller();
  }

  bool _descending;
  bool _leftHanded;
  Controller _con;
  bool _refresh;

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
      settings.add(Card(
        child:
            ISOSpinner(initialItem: I10n.supportedLocales.indexOf(App.locale)),
      ));
    }

    settings.addAll([
      Card(
        child: Column(children: [
          Row(children: [
            Expanded(
                child: ListTile(
              title: I10n.t(
                'NOTIFICATIONS PREFERENCES',
              ),
            ))
          ]),
          Row(children: [
            InkWell(
                onTap: () {},
                child: I10n.t(
                  'Notification Settings',
                )),
          ]),
          Row(
            children: const [Text('')],
          ),
          Row(children: [
            Expanded(
              child: InkWell(
                  onTap: () {},
                  child: I10n.t(
                    'Notification behaviour popup settings and LED Colour',
                    softWrap: true,
                  )),
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
              title: I10n.t(
                'RECORD PREFERENCES',
              ),
            ))
          ]),
          Row(children: [
            InkWell(
                onTap: () {},
                child: I10n.t(
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
                child: Text('${I10n.s(
                  'How certain records are further handled',
                )}\n'),
              ),
            ),
          ]),
        ]),
      ),
      Card(
        child: Settings.tapText(
          I10n.s('About ToDo List'),
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
          title: I10n.t('INTERFACE PREFERENCES'),
        ))
      ]),
      Row(children: [
        InkWell(
            onTap: () {},
            child: I10n.t(
              'Sorted Order of Items',
            )),
      ]),
      Row(
        children: const [Text('')],
      ),
      Row(children: [
        Expanded(
          child: I10n.t(
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
          child: I10n.t(
            'Switch around dialogue buttons',
          ),
        ),
        Checkbox(
          value: _leftHanded,
          onChanged: switchButton,
        ),
      ]),
      ListTile(
        leading: _theme.isDarkMode
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
        title: I10n.t('Dark Mode'),
        trailing: Switch(
          value: _theme.isDarkMode,
          onChanged: (val) {
            _theme.darkMode = val;
            if (!val) {
              App.setThemeData();
            }
            refresh();
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
                App.refresh();
              },
              child: Text(
                  '${I10n.s('Interface:')} ${App.useMaterial ? 'Material' : 'Cupertino'}\n'),
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                ColorPicker.showColorPicker(
                    context: context,
                    onColorChange: AppMenu.onColorChange,
                    onChange: AppMenu.onChange,
                    shrinkWrap: true);
              },
              child: Text('${I10n.s('Colour Theme')}\n'),
            ),
          ],
        )
      ]);
    }
    return interface;
  }

  // ignore: avoid_positional_boolean_parameters
  void orderItems(bool value) {
    Settings.setOrder(value);
    setState(() {
      _descending = value;
    });
    _refresh = true;
  }

  // ignore: avoid_positional_boolean_parameters
  void switchButton(bool value) {
    Settings.setLeftHanded(value);
    setState(() {
      _leftHanded = value;
    });
  }
}

/// Supply the settings widget to a Drawer widget
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Drawer(child: SettingsWidget());
}
