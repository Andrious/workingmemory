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
///          Created  23 Jun 2018
///

import 'package:flutter/material.dart';

import 'package:workingmemory/src/controller.dart' show WorkingController;

import 'package:workingmemory/src/view.dart'
    show AppView, Prefs, I10n, I10nDelegate, TodosPage;

//import 'package:workingmemory/src/view/LoginInfo.dart' show LoginInfo;

import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;

/// The 'View' of the application.
class WorkingView extends AppView {
  factory WorkingView() => _this ??= WorkingView._();
  WorkingView._()
      : super(
          con: WorkingController(), //_app,
          title: 'Working Memory',
          home: TodosPage(key: pageKey),
          debugShowCheckedModeBanner: false,
          switchUI: Prefs.getBool('switchUI'),
          localizationsDelegates: [
            I10nDelegate(),
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          localeListResolutionCallback:
              (List<Locale> locales, Iterable<Locale> supportedLocales) {
            final pref = Prefs.getString('locale');
            final locale = pref.split('-');
            return pref.isEmpty
                ? locales?.first
                : locale.length == 1
                    ? Locale(locale[0])
                    : Locale(locale[0], locale[1]);
          },
        ) {
//    idKey = _app.keyId;
  }
  static WorkingView _this;
  static Key pageKey = UniqueKey();

  /// Conceivably, you could define your own WidgetsApp.
  @override
  Widget buildApp(BuildContext context) => super.buildApp(context);

  @override
  Locale onLocale() {
    final List<String> locale = Prefs.getString('locale', 'en').split('-');
    String languageCode;
    String countryCode;
    if (locale.length == 2) {
      languageCode = locale.first;
      countryCode = locale.last;
    } else {
      languageCode = locale.first;
    }
    return Locale(languageCode, countryCode);
  }

  @override
  Iterable<Locale> onSupportedLocales() => I10n.supportedLocales;

  /// Allow for easy access to 'the View' throughout the application.
  static WorkingView get view => _this;

//  /// Instantiate here so to get the 'keyId.'
//  static final WorkingController _app = WorkingController();
//  String idKey;

//  @override
//  ThemeData onTheme() => ThemeData(
//        primaryColor: App.color,
//      );
}
