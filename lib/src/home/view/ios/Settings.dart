///
/// Copyright (C) 2020 Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
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

import 'package:workingmemory/src/view.dart' show NotificationSettings, SignIn;

import 'package:workingmemory/src/controller.dart';

import 'settings_group.dart';

import 'settings_item.dart';

class SettingsScreen extends StatelessWidget {
  //
  final Controller con = Controller();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        //       color: Styles.scaffoldBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
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
      ),
    );
  }

  List<SettingsItem> _settingsGroupItems(BuildContext context) {
    SettingsItem item;
    List<SettingsItem> items = [
      SettingsItem(
        label: 'Sorted Order of Items',
        subtitle: 'Check for most recent listed first.',
        content: CupertinoSwitch(
          value: Settings.getOrder(),
          onChanged: (bool value) => Settings.setOrder(value),
        ),
      ),
      SettingsItem(
        label: 'Switch around dialog buttons',
        subtitle: 'Possibly preferred if left-handed.',
        content: CupertinoSwitch(
          value: Settings.getLeftHanded(),
          onChanged: (bool value) => Settings.setLeftHanded(value),
        ),
      ),
      SettingsItem(
        label: 'Notification Settings',
        subtitle: 'Behaviour and Colour settings',
        content: SettingsNavigationIndicator(),
        onPress: () {
          Navigator.of(context).push<void>(
            CupertinoPageRoute(
              builder: (context) => NotificationSettings(),
              title: 'Preferred Categories',
            ),
          );
        },
      ),
    ];

    if (!con.app.isAnonymous) {
      item = SettingsItem(label: 'Log Out', onPress: () => con.logOut());
    } else {
      item = SettingsItem(
          label: 'Sign In',
          onPress: () {
            Navigator.of(con.context).push(
              CupertinoPageRoute(
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
