///
/// Copyright (C) 2018 Andrious Solutions
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
///          Created  11 Sep 2018
///

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workingmemory/src/controller.dart' show AppSettings, Prefs;

//TODO: Write an article on this. 'Store concept.'
class Settings{
  static bool getOrder() {
    return Prefs.getBool("order_of_items", false);
  }

  static Future<bool> setOrder(bool value) {
    return Prefs.setBool("order_of_items", value);
  }

  static bool getLeftHanded() {
    return Prefs.getBool("left_handed", false);
  }

  static Future<bool> setLeftHanded(bool value) {
    return Prefs.setBool("left_handed", value);
  }

  static StatelessWidget tapText(String text, VoidCallback onTap, {TextStyle style}){
    return AppSettings.tapText(text, onTap, style: style);
  }

  static showAboutDialog({@required BuildContext context}){

    final ThemeData themeData = Theme.of(context);
    final TextStyle aboutTextStyle = themeData.textTheme.bodyText1;
    final TextStyle linkStyle = themeData.textTheme.bodyText1.copyWith(color: themeData.accentColor);
    
    AppSettings.showAbout(
      context: context,
      applicationVersion: '1.0.1',
      applicationIcon: const FlutterLogo(),
      applicationLegalese: 'Andrious Solutions Ltd.\n© 2018',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child:  RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    style: aboutTextStyle,
                    text: 'Flutter is an early-stage, open-source project to help developers '
                        'build high-performance, high-fidelity, mobile apps for '
                        '${AppSettings.defaultTargetPlatform == TargetPlatform.iOS ? 'multiple platforms' : 'iOS and Android'} '
                        'from a single codebase. This gallery is a preview of '
                        "Flutter's many widgets, behaviors, animations, layouts, "
                        'and more. Learn more about Flutter at '
                ),
                AppSettings.linkTextSpan(
                  style: linkStyle,
                  url: 'https://flutter.io',
                ),
                TextSpan(
                  style: aboutTextStyle,
                  text: '.\n\nTo see the source code for this app, please visit the ',
                ),
                AppSettings.linkTextSpan(
                  style: linkStyle,
                  url: 'https://goo.gl/iv1p4G',
                  text: 'flutter github repo',
                ),
                TextSpan(
                  style: aboutTextStyle,
                  text: '.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
