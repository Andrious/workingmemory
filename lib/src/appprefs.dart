import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppPrefs {

  static Future<SharedPreferences> _prefs;

  static Future<SharedPreferences> getInstance() {
    if (_prefs == null) _prefs = SharedPreferences.getInstance();
    return _prefs;
  }

//  static get(String key) {
//    getInstance().then((SharedPreferences prefs) {
//      return prefs.get(key) ?? null;
//    });
//  }

  static getBool(String key) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.getBool(key) ?? false;
    });
  }

  static getInt(String key) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.getInt(key) ?? 0;
    });
  }

  static getDouble(String key) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.getDouble(key) ?? 0.0;
    });
  }

  static getString(String key) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.getString(key) ?? '';
    });
  }


  static setBool(String key, bool value) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.setBool(key, value);
    });
  }

  static setInt(String key, int value) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.setInt(key, value);
    });
  }

  static setDouble(String key, double value) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.setDouble(key, value);
    });
  }

  static setString(String key, String value) {
    getInstance().then((SharedPreferences prefs) {
      return prefs.setString(key, value);
    });
  }

  static getThemeData() {
    getInstance().then((SharedPreferences prefs) {
      var theme = prefs.getString('theme') ?? 'light';

      ThemeData themeData;

      switch (theme) {
        case 'light':
          themeData = ThemeData.light();
          break;
        case 'dark':
          themeData = ThemeData.dark();
          break;
        default:
          themeData = ThemeData.fallback();
      }
      return themeData;
    });
  }

  static setThemeData(String theme) {
    getInstance().then((SharedPreferences prefs) {
      switch (theme) {
        case 'light':
          break;
        case 'dark':
          break;
        default:
          theme = 'fallback';
      }
      prefs.setString('theme', theme);
    });
  }
}