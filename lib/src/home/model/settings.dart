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
///          Created  11 Sep 2018
///

import 'dart:async';

import 'package:workingmemory/src/view.dart';

//TODO: Write an article on this. 'Store concept.'
// ignore: avoid_classes_with_only_static_members
class Settings {
  //
  static bool get(String? setting) {
    if (setting == null || setting.trim().isEmpty) {
      return false;
    }
    return Prefs.getBool(setting, false);
  }

  // ignore: avoid_positional_boolean_parameters
  static Future<bool> set(String? setting, bool value) {
    if (setting == null || setting.trim().isEmpty) {
      return Future.value(false);
    }
    return Prefs.setBool(setting, value);
  }

  static bool getOrder() {
    return Prefs.getBool('order_of_items', false);
  }

  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setOrder(bool value) {
    return Prefs.setBool('order_of_items', value);
  }

  static bool getLeftHanded() {
    return Prefs.getBool('left_handed', false);
  }

  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setLeftHanded(bool value) {
    return Prefs.setBool('left_handed', value);
  }

  static StatelessWidget tapText(String text, VoidCallback onTap,
      {TextStyle? style}) {
    return AppSettings.tapText(text, onTap, style: style);
  }

  static Widget aboutTile(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: AboutListTile(
          icon: const Icon(Icons.info),
          applicationIcon: const FlutterLogo(),
          applicationName: 'Show About Example',
          applicationVersion: 'Ver. ${App.version}',
          applicationLegalese: 'Andrious Solutions Ltd.\n© 2020',
          aboutBoxChildren: aboutBoxChildren(context),
        ),
      ),
    );
  }

  ///
  static void showAboutDialog(BuildContext context) {
    //
    final ThemeData themeData = Theme.of(context);
    final TextStyle? aboutTextStyle = themeData.textTheme.bodyText1;
    final TextStyle linkStyle = themeData.textTheme.bodyText1!
        .copyWith(color: themeData.colorScheme.secondary);

    AppSettings.showAbout(
      context: context,
      applicationVersion: 'Ver. ${App.version}',
      applicationIcon: const FlutterLogo(),
      applicationLegalese: 'Andrious Solutions Ltd.\n© 2022',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    style: aboutTextStyle,
                    text:
                        "This is a 'ToDo List' app demonstrating how Flutter provides a solution to multiple platforms from a single codebase."
                            .tr),
                TextSpan(
                  style: aboutTextStyle,
                  text: '\n\n${'The source code is available on Github:'.tr}\n',
                ),
                AppSettings.linkTextSpan(
                  style: linkStyle,
                  url: 'https://github.com/Andrious/workingmemory',
                  text: 'Working Memory'.tr,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<Widget> aboutBoxChildren(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle? aboutTextStyle = themeData.textTheme.bodyText1;
    final TextStyle linkStyle = themeData.textTheme.bodyText1!
        .copyWith(color: themeData.colorScheme.secondary);
    return [
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  style: aboutTextStyle,
                  text:
                      'This is an early-stage, open-source project demonstrating '
                      'the use of the MVC design pattern with Flutter and produce '
                      "a 'ToDo List' application that works in "
                      '${AppSettings.defaultTargetPlatform == TargetPlatform.iOS ? 'multiple platforms' : 'iOS and Android'} '
                      'from a single codebase.'),
              TextSpan(
                style: aboutTextStyle,
                text: '.\n\nThe source code is available on Github:',
              ),
              AppSettings.linkTextSpan(
                style: linkStyle,
                url: 'https://github.com/Andrious/workingmemory',
                text: '\nWorking Memory',
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
