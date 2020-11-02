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
///          Created  10 Mar 2020
///
///

import 'package:flutter/cupertino.dart';

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/home/view/ios/styles.dart';

import 'package:workingmemory/src/home/view/ios/settings_group.dart';

import 'package:workingmemory/src/home/view/ios/settings_item.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notification Settings'),
        previousPageTitle: 'Settings',
      ),
      backgroundColor: Styles.scaffoldBackground,
      child: ListView(
        children: [
          SettingsGroup(
            items: [
              SettingsItem(
                label: 'Use Popup Notification?',
                subtitle: 'and not just on status bar.',
                content: CupertinoSwitch(
                  value: Settings.get('popup_window'),
                  onChanged: (bool value) =>
                      Settings.set('popup_window', value),
                ),
              ),
              SettingsItem(
                label: 'Clear Notification with Popup',
                subtitle: 'clear once notified once',
                content: CupertinoSwitch(
                  value: Settings.get('clear_notification'),
                  onChanged: (bool value) =>
                      Settings.set('clear_notification', value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
