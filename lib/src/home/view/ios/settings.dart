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

import '/src/model.dart' show Settings;

import '/src/view.dart' show L10nTranslate, NotificationSettings, SignIn;

import '/src/controller.dart' show Controller;

import 'settings_group.dart';

import 'settings_item.dart';

///
class SettingsScreen extends StatelessWidget {
  ///
  SettingsScreen(Key key) : super(key: key);

  final Controller _con = Controller();

  final List<String> _itemOrders = Settings.itemOrders;

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
        label: 'Order of Items'.tr,
        subtitle: 'Most recent listed first.'.tr,
        // content: CupertinoSwitch(
        //   value: Settings.getOrder(),
        //   onChanged: Settings.setOrder,
        // ),
        content: CupertinoPicker(
          magnification: 1.22,
          squeeze: 1.2,
          useMagnifier: true,
          itemExtent: 32,
          // This is called when selected item is changed.
          onSelectedItemChanged: (int value) {
            Settings.itemsOrder = _itemOrders[value];
          },
          children: List<Widget>.generate(_itemOrders.length, (int index) {
            return Center(
              child: Text(
                _itemOrders[index],
              ),
            );
          }),
        ),
      ),
      SettingsItem(
        label: 'Switch around dialog buttons',
        subtitle: 'Possibly preferred if left-handed.',
        content: CupertinoSwitch(
          value: Settings.leftSided,
          onChanged: Settings.setLeftSidedPrefs,
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

    if (!_con.app.isAnonymous) {
      item = SettingsItem(label: 'Log Out', onPress: _con.logOut);
    } else {
      item = SettingsItem(
          label: 'Sign In',
          onPress: () {
            Navigator.of(_con.state!.context).push(
              CupertinoPageRoute<void>(
                builder: (context) => const SignIn(),
                title: 'Preferred Categories',
              ),
            );
          });
    }
    items.add(item);
    return items;
  }
}
