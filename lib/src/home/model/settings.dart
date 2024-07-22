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

import '/src/view.dart';

import 'package:auto_orientation/auto_orientation.dart';

//TODO: Write an article on this. 'Store concept.'
///
class Settings {
  /// Initialize setting values
  Future<bool> initAsync() async {
    // Determine the order of the items listed.
    itemsOrder = itemsOrderPrefs();
    leftSided = leftSidedPrefs();
    leadingDrawer = getDrawerPrefs();
    portraitOnly = portraitPrefs();

    if (portraitOnly) {
      await Settings.setPortraitOnly(portraitOnly);
    }
    return true;
  }

  ///
  void dispose() {}

  ///
  static bool get(String? setting) {
    if (setting == null || setting.trim().isEmpty) {
      return false;
    }
    return Prefs.getBool(setting, false);
  }

  ///
  // ignore: avoid_positional_boolean_parameters
  static Future<bool> set(String? setting, bool value) {
    if (setting == null || setting.trim().isEmpty) {
      return Future.value(false);
    }
    return Prefs.setBool(setting, value);
  }

  /// Available order settings.
  static List<String> get itemOrders => _itemOrders;
  static final List<String> _itemOrders = ['ascending', 'descending'];

  /// Current order of items
  static String get itemsOrder => _itemsOrder;
  static set itemsOrder(String? value) {
    if (value != null) {
      value = value.trim();
      if (_itemOrders.contains(value)) {
        _itemsOrder = value;
      }
    }
  }

  static String _itemsOrder = _itemOrders[0];

  ///
  static String itemsOrderPrefs() =>
      Prefs.getString('order_of_items', _itemOrders[0]);

  ///
  static Future<bool> setItemsOrderPrefs(String? value) async {
    final order = value == null ? ' ' : value.trim();
    bool set = _itemOrders.contains(order);
    if (set) {
      set = await Prefs.setString('order_of_items', value);
    }
    return set;
  }

  /// Show the Bottom Bar under the AppBar
  static bool get showBottomBar => _showBottomBar;
  static set showBottomBar(bool? value) {
    if (value != null) {
      _showBottomBar = value;
    }
  }

  static bool _showBottomBar = true;

  ///
  static bool bottomBarPrefs() => Prefs.getBool('showBottomBar', true);

  ///
  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setBottomBarPrefs(bool? value) async {
    bool set = value != null;
    if (set) {
      set = await Prefs.setBool('showBottomBar', value);
    }
    return set;
  }

  /// Left handed user or not.
  static bool get leftSided => _leftSided;
  static set leftSided(bool? value) {
    if (value != null) {
      _leftSided = value;
    }
  }

  // left handed user or not
  static bool _leftSided = false;

  ///
  static bool leftSidedPrefs() => Prefs.getBool('left_handed', _leftSided);

  ///
  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setLeftSidedPrefs(bool? value) =>
      Prefs.setBool('left_handed', value);

  /// Use the endDrawer or not in the Scaffold widget.
  static bool get leadingDrawer => _leadingDrawer;
  static set leadingDrawer(bool? value) {
    if (value != null) {
      _leadingDrawer = value;
    }
  }

  //  Use the endDrawer or not in the Scaffold widget.
  static bool _leadingDrawer = true;

  ///
  static bool getDrawerPrefs() =>
      Prefs.getBool('leadingDrawer', _leadingDrawer);

  ///
  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setDrawerPrefs(bool? value) async {
    bool set = value != null;
    if (set) {
      set = await Prefs.setBool('leadingDrawer', value);
    }
    return set;
  }

  /// Whether the item's icon leads or proceeds it.
  static bool get leadingIcon => _leadingIcon;
  static set leadingIcon(bool? value) {
    if (value != null) {
      _leadingIcon = value;
    }
  }

  // Whether the item's icon leads or proceeds it.
  static bool _leadingIcon = true;

  ///
  static bool leadingIconPrefs() => Prefs.getBool('leadingIcon', _leadingIcon);

  ///
  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setLeadingIconPrefs(bool? value) async {
    bool set = value != null;
    if (set) {
      set = await Prefs.setBool('leadingIcon', value);
    }
    return set;
  }

  /// Whether in portrait only.
  static bool get portraitOnly => _portraitOnly;
  static set portraitOnly(bool? value) {
    if (value != null) {
      _portraitOnly = value;
    }
  }

  // Whether in portrait only.
  static bool _portraitOnly = false;

  ///
  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setPortraitOnly(bool? value) async {
    //
    if (value == null) {
      return false;
    }

    if (value) {
      _portraitOnly = true;
      await AutoOrientation.portraitUpMode();
    } else {
      if (_portraitOnly) {
        _portraitOnly = false;
//        await AutoOrientation.fullAutoMode();
        await AutoOrientation.setScreenOrientationUser();
      }
    }
    // Save the setting
    await setPortraitPrefs(value);
    return value;
  }

  ///
  static bool portraitPrefs() => Prefs.getBool('portraitOnly', _portraitOnly);

  ///
  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setPortraitPrefs(bool? value) async {
    bool set = value != null;
    if (set) {
      set = await Prefs.setBool('portraitOnly', value);
    }
    return set;
  }

  ///
  static StatelessWidget tapText(String text, VoidCallback onTap,
      {TextStyle? style}) {
    return AppSettings.tapText(text, onTap, style: style);
  }

  ///
  static Widget aboutTile(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: AboutListTile(
          icon: const Icon(Icons.info),
          applicationIcon: const FlutterLogo(),
          applicationName: 'Show About Example',
          applicationVersion: 'Ver. ${App.version}',
          applicationLegalese: 'Andrious Solutions Ltd.\n© 2023',
          aboutBoxChildren: aboutBoxChildren(context),
        ),
      ),
    );
  }

  ///
  static void showAboutDialog(BuildContext context) {
    //
    final ThemeData themeData = Theme.of(context);
    final TextStyle? aboutTextStyle = themeData.textTheme.bodyMedium;
    final TextStyle linkStyle = themeData.textTheme.bodyMedium!
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

  ///
  static List<Widget> aboutBoxChildren(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle? aboutTextStyle = themeData.textTheme.bodyMedium;
    final TextStyle linkStyle = themeData.textTheme.bodyMedium!
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
