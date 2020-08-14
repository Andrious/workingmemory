///
/// Copyright (C) 2020 Andrious Solutions
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
///          Created  07 Mar 2020
///
///

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart' show NotificationSettings, SignIn;

import 'package:workingmemory/src/controller.dart' show Controller;

import 'settings_group.dart';

import 'settings_item.dart';

class SettingsScreen extends StatelessWidget {
  //
  SettingsScreen(Key key) : super(key: key);

  final Controller con = Controller();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Settings'),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  SettingsGroup(items: _settingsGroupItems(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SettingsItem> _settingsGroupItems(BuildContext context) {
    SettingsItem item;
    final List<SettingsItem> items = [
      SettingsItem(
        label: 'Sorted Order of Items',
        subtitle: 'Check for most recent listed first.',
        content: CupertinoSwitch(
          value: Settings.getOrder(),
          onChanged: Settings.setOrder,
        ),
      ),
      SettingsItem(
        label: 'Switch around dialog buttons',
        subtitle: 'Possibly preferred if left-handed.',
        content: CupertinoSwitch(
          value: Settings.getLeftHanded(),
          onChanged: Settings.setLeftHanded,
        ),
      ),
      SettingsItem(
        label: 'Notification Settings',
        subtitle: 'Behaviour and Colour settings',
        content: const SettingsNavigationIndicator(),
        onPress: () {
          Navigator.of(context).push<void>(
            CupertinoPageRoute(
              builder: (context) => const NotificationSettings(),
              title: 'Preferred Categories',
            ),
          );
        },
      ),
    ];

    if (!con.app.isAnonymous) {
      item = SettingsItem(label: 'Log Out', onPress: con.logOut);
    } else {
      item = SettingsItem(
          label: 'Sign In',
          onPress: () {
            Navigator.of(con.context).push(
              CupertinoPageRoute<void>(
                builder: (context) => SignIn(),
                title: 'Preferred Categories',
              ),
            );
          });
    }
    items.add(item);
    return items;
  }
}
