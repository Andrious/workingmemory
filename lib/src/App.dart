import 'dart:async';

import 'appprefs.dart';

import 'Auth.dart';

class App{

  static Future<String> init() async{

    await AppPrefs.getInstance();

    return await Auth().signInAnonymously();
  }
}