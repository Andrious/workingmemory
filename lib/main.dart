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
///                   https://github.com/Andrious/workingmemory

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' hide runApp;

void main() => runApp(WorkingMemory());



class WorkingMemory extends AppStatefulWidget {
  //
  WorkingMemory({Key key}) : super(key: key);

  static final Key pageKey = UniqueKey();

  @override
  // Set up 'the View' of the MVC design pattern.
  AppState createView() => AppState(
        con: WorkingController(),
        switchUI: Prefs.getBool('switchUI'),
        title: 'Working Memory',
        home: TodosPage(key: pageKey),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          I10nDelegate(),
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        localeListResolutionCallback:
            (List<Locale> locales, Iterable<Locale> supportedLocales) {
          Locale locale;
          // Retrieve the last locale used.
          final localePref = Prefs.getString('locale');
          if (localePref.isNotEmpty) {
            final localeCode = localePref.split('-');
            String languageCode;
            String countryCode;
            if (localeCode.length == 2) {
              languageCode = localeCode.first;
              countryCode = localeCode.last;
            } else {
              languageCode = localeCode.first;
            }
            locale = Locale(languageCode, countryCode);
          } else {
            // Use the device's locale.
            if (locales.isNotEmpty) {
              locale = locales.first;
            } else if (supportedLocales.isNotEmpty) {
              // Use the first supported locale.
              locale = supportedLocales.first;
            }
          }
          return locale;
        },
        supportedLocales: I10n.supportedLocales,
        inTheme: () => ThemeController().setIfDarkMode(),
        inError: (details) {
          super.onError(details);
        },
        inAsyncError: (details) => false,
      );
}
