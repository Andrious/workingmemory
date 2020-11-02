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
    show
        App,
        CupertinoThemeData,
        MaterialBasedCupertinoThemeData,
        ThemeData,
        ThemeMode;

import 'package:workingmemory/src/controller.dart' show ControllerMVC, Prefs;

/// The App's theme controller
class ThemeController extends ControllerMVC {
  factory ThemeController() => _this ??= ThemeController._();
  ThemeController._() {
    _isDarkmode = Prefs.getBool('darkmode', false);
  }
  static ThemeController _this;
  bool _isDarkmode;

  /// Get App's Material theme data
  ThemeData get themeData => App.themeData;

  /// Get the App's IOS theme data
  CupertinoThemeData get iOSTheme => App.iOSTheme;

  /// Supply the appropriate theme.
  ThemeMode get themeMode => _isDarkmode ? ThemeMode.dark : ThemeMode.system;

  /// Indicate if in 'dark mode' or not
  bool get isDarkMode => _isDarkmode;

  /// Record if the App's in dark mode or not.
  set isDarkMode(bool set) {
    if (set == null) {
      return;
    }
    _isDarkmode = set;
    Prefs.setBool('darkmode', _isDarkmode);
  }

  /// Indicate if in 'dark mode' or not.
  bool get darkMode => _isDarkmode;

  /// Set the App's dark mode or not.
  set darkMode(bool set) {
    isDarkMode = set;
    if (_isDarkmode) {
      App.themeData = ThemeData.dark();
      App.iOSTheme = ThemeData.dark();
    }
  }

  /// Explicitly set to 'light mode.'
  bool setLightMode() {
    final _light = setUIBrightness(darkMode: false);
    setTheme();
    return _light;
  }

  /// Explicitly set to 'dark mode.'
  bool setDarkMode() {
    final _dark = setUIBrightness(darkMode: true);
    setTheme();
    return _dark;
  }

  /// Assign the App's theme to dark mode only if specified.
  bool setIfDarkMode() {
    darkMode = _isDarkmode;
    return _isDarkmode;
  }

  /// Set the App's user interface brightness.
  bool setUIBrightness({bool darkMode}) {
    isDarkMode = darkMode;
    if (!_isDarkmode) {
      App.themeData = ThemeData.light();
    }
    // Rebuild the State.
    refresh();
    return _isDarkmode;
  }

  /// Return the App's theme
  /// but not before changing it to 'dark mode' if to be set.
  ThemeData getTheme() {
    setIfDarkMode();
    return App.themeData;
  }

  /// Set the App's theme
  bool setTheme([ThemeData theme]) {
    //
    if (theme == null) {
      return false;
    }
    // Material theme.
    App.themeData = theme;
    // Cupertino theme.
    App.iOSTheme = MaterialBasedCupertinoThemeData(
      materialTheme: App.themeData,
    );
    // Rebuild the State.
    refresh();
    return true;
  }
}
