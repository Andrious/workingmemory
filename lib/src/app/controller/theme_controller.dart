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

import 'package:workingmemory/src/view.dart' show ThemeData;

import 'package:workingmemory/src/controller.dart' show ControllerMVC, Prefs;

/// The App's theme controller
class ThemeController extends ControllerMVC {
  factory ThemeController() => _this ??= ThemeController._();
  ThemeController._() {
    _isDarkmode = Prefs.getBool('darkmode', false);
  }
  static ThemeController _this;
  bool _isDarkmode;

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

  /// Explicitly return the 'dark theme.'
  ThemeData setDarkMode() {
    isDarkMode = true;
    return ThemeData.dark();
  }

  /// Returns 'dark theme' only if specified.
  /// Otherwise, it returns null.
  ThemeData setIfDarkMode() => _isDarkmode ? setDarkMode() : null;
}
