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
///          Created  07 Jun 2020
///

import 'package:workingmemory/src/view.dart'
    show App, CupertinoThemeData, MaterialBasedCupertinoThemeData, ThemeData;

import 'package:workingmemory/src/controller.dart' show ControllerMVC, Prefs;

class ThemeController extends ControllerMVC {
  factory ThemeController() => _this ??= ThemeController._();
  static ThemeController _this;
  ThemeController._();

  ThemeData get themeData => App.themeData;

  CupertinoThemeData get iOSTheme => App.iOSTheme;

  bool get darkMode => _darkmode;
  bool _darkmode;

  @override
  void initState() {
    _darkmode = Prefs.getBool("darkmode");
    setDarkMode(_darkmode);
  }

  bool setDarkMode(bool darkMode) {
    if (darkMode == null) return false;
    _darkmode = darkMode;
    Prefs.setBool("darkmode", _darkmode);
    setTheme();
    return true;
  }

  setTheme([ThemeData theme]) {
    //
    if (theme != null) {
      App.themeData = theme;
    } else {
      if (_darkmode) {
        App.themeData = ThemeData.dark();
      } else {
        App.themeData = ThemeData.light();
      }
    }
    // Cupertino Theme
    App.iOSTheme = MaterialBasedCupertinoThemeData(
      materialTheme: App.themeData,
    );
    // Rebuild the State.
    App.refresh();
  }
}
