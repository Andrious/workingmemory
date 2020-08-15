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

import 'package:mvc_application/view.dart' show AppView;

import 'package:workingmemory/src/controller.dart' show App, WorkingController;

import 'package:workingmemory/src/view.dart' show App, AppView, TodosPage;

//import 'package:workingmemory/src/view/LoginInfo.dart' show LoginInfo;

class WorkingView extends AppView {
  factory WorkingView() => _this ??= WorkingView._();
  WorkingView._()
      : super(
          con: _app,
          title: 'Working Memory',
          home: const TodosPage(),
          debugShowCheckedModeBanner: false,
        ) {
    idKey = _app.keyId;
  }
  static WorkingView _this;

  /// Conceivably, you could define your own WidgetsApp.
  @override
  Widget buildApp(BuildContext context) => super.buildApp(context);

  /// Allow for easy access to 'the View' throughout the application.
  static WorkingView get view => _this;

  /// Instantiate here so to get the 'keyId.'
  static final WorkingController _app = WorkingController();
  String idKey;

//  @override
//  ThemeData onTheme() => ThemeData(
//        primaryColor: App.color,
//      );
}
