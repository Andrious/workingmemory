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

import '/src/view.dart' hide ColorPicker;

import '/src/controller.dart' show App, StateXController, Prefs;

import '/src/model.dart';

import 'package:flutter_system_ringtones/flutter_system_ringtones.dart'
    show Ringtone;

/// The App's theme controller
class ThemeController extends StateXController {
  ///
  factory ThemeController() => _this ??= ThemeController._();
  ThemeController._() {
    _darkMode = DarkMode();
    _sounds = PhoneSounds();
    _notifications = Notifications();
  }
  static ThemeController? _this;

  @override
  Future<bool> initAsync() async {
    App.themeData = setIfDarkMode();
    if (!kIsWeb) {
      await _sounds.initAsync();
    }
    return true;
  }

  // Determine the app's dark mode.
  late DarkMode _darkMode;
  late Notifications _notifications;

  late PhoneSounds _sounds;

  /// Indicate if in 'dark mode' or not
  bool get isDarkMode => _darkMode.isDarkMode;

  /// Record if the App's in dark mode or not.
  set isDarkMode(bool? set) => _darkMode.isDarkMode = set;

  /// Explicitly return the 'dark theme.'
  ThemeData setDarkMode() => _darkMode.setDarkMode();

  /// Returns 'dark theme' only if specified.
  /// Otherwise, it returns null.
  ThemeData? setIfDarkMode() => _darkMode.setIfDarkMode();

  /// Supply the color wheel
  void showLEDColour() => LEDColor.show(
        context: state!.context,
        title: L10n.t('LED Colour'),
        // titlePadding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        // contentPadding: const EdgeInsets.all(8),
        // displayThumbColor: false,
      );

  /// Display Notifications Settings
  void showNotifications() => _notifications.show(state!.context);

  /// Access Notification Settings
  Notifications get notifySettings => _notifications;

  /// Notification Ringtones
  List<Ringtone> get notifications => _sounds.notifications ?? [];

  /// Display Notifications Sounds
  void showSounds() => _sounds.show(state!.context);
}

/// Determine the app's dark mode.
class DarkMode {
  /// Only one instance
  factory DarkMode() => _this ??= DarkMode._();
  DarkMode._() {
    _isDarkmode = Prefs.getBool('darkmode', false);
  }
  static DarkMode? _this;

  /// Indicate if in 'dark mode' or not
  bool get isDarkMode => _isDarkmode;
  late bool _isDarkmode;

  /// Record if the App's in dark mode or not.
  set isDarkMode(bool? set) {
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
  ThemeData? setIfDarkMode() {
    ThemeData? data;

    if (!_isDarkmode) {
      data = null;
    } else {
      data = setDarkMode();
    }
    return data;
  }
}

///
class Notifications {
  ///
  bool get usePopup => _usePopup ??= Prefs.getBool('usePopup', false);
  set usePopup(bool? value) {
    if (value != null) {
      _usePopup = value;
      Prefs.setBool('usePopup', value);
    }
  }

  bool? _usePopup;
  bool? _popup;

  ///
  bool get useClear => _useClear ??= Prefs.getBool('useClear', false);
  set useClear(bool? value) {
    if (value != null) {
      _useClear = value;
      Prefs.setBool('useClear', value);
    }
  }

  bool? _useClear;
  bool? _clear;

  ///
  bool get useVibrate => _useVibrate ??= Prefs.getBool('useVibrate', false);
  set useVibrate(bool? value) {
    if (value != null) {
      _useVibrate = value;
      Prefs.setBool('useVibrate', value);
    }
  }

  bool? _useVibrate;
  bool? _vibrate;

  ///
  bool get useLED => _useLED ??= Prefs.getBool('useLED', false);
  set useLED(bool? value) {
    if (value != null) {
      _useLED = value;
      Prefs.setBool('useLED', value);
    }
  }

  bool? _useLED;
  bool? _led;

  late BuildContext _context;

  /// Display the LED Colour for the Notification
  void show(BuildContext _context) {
    this._context = _context;
    final leftHanded = Settings.leftSided;
    final controlAffinity = leftHanded
        ? ListTileControlAffinity.leading
        : ListTileControlAffinity.trailing;
    _popup = usePopup;
    _clear = useClear;
    _vibrate = useVibrate;
    _led = useLED;
    showDialog<void>(
        context: _context,
        builder: (BuildContext context) {
          App.dependOnInheritedWidget(context);
          return AlertDialog(
            title: Text('NOTIFICATIONS PREFERENCES'.tr),
            titlePadding: const EdgeInsets.only(left: 10, top: 20),
            contentPadding: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  CheckboxListTile(
                    controlAffinity: controlAffinity,
                    title: Text('Use Popup Notification?'.tr),
                    subtitle: Text(
                        'Show a popup window in addition to notification on the status bar'
                            .tr),
                    value: _popup,
                    onChanged: (value) {
                      _popup = value;
                      App.notifyClients();
                    },
                  ),
                  CheckboxListTile(
                    controlAffinity: controlAffinity,
                    title: Text('Clear Notification with Popup'.tr),
                    subtitle: Text(
                        "Check to clear the accompanying notification when an item's popup message is only closed and not edited"
                            .tr),
                    value: _clear,
                    onChanged: (value) {
                      _clear = value;
                      App.notifyClients();
                    },
                  ),
                  CheckboxListTile(
                    controlAffinity: controlAffinity,
                    title: Text('Vibrate on Notification'.tr),
                    subtitle:
                        Text('Accompany the notification with vibration.'.tr),
                    value: _vibrate,
                    onChanged: (value) {
                      _vibrate = value;
                      App.notifyClients();
                    },
                  ),
                  CheckboxListTile(
                    controlAffinity: controlAffinity,
                    title: Text('Use LED with Notification'.tr),
                    subtitle: Text('Use the phones LED with notification'.tr),
                    value: _led,
                    onChanged: (value) {
                      _led = value;
                      App.notifyClients();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      if (leftHanded) doneButton else cancelButton,
                      if (leftHanded) cancelButton else doneButton,
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  ///
  Widget get doneButton => ElevatedButton(
        onPressed: () {
          if (usePopup != _popup) {
            usePopup = _popup;
          }
          if (useClear != _clear) {
            useClear = _clear;
          }
          if (useVibrate != _vibrate) {
            useVibrate = _vibrate;
          }
          if (useLED != _led) {
            useLED = _led;
          }
          Navigator.of(_context).pop();
        },
        child: Text('Done'.tr),
      );

  ///
  Widget get cancelButton => ElevatedButton(
        onPressed: () => Navigator.of(_context).pop(),
        child: Text('Cancel'.tr),
      );
}
