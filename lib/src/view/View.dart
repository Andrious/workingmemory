///
/// Copyright (C) 2018 Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  23 Jun 2018
///

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mvc/App.dart';

import 'package:workingmemory/src/controller/Controller.dart';

import 'package:workingmemory/src/view/TodosPage.dart';

import 'package:workingmemory/src/view/LoginInfo.dart';

import 'package:workingmemory/src/view/SettingsDrawer.dart';


class View extends AppView{

  View(): super(con: _con,
    title:'Working Memory',
    routes: <String, WidgetBuilder>{
      "/todos": (BuildContext context) => TodosPage().widget,
      // add another page,
    },
  );
  static final Controller _con = Controller();

  @override
  Widget build(BuildContext context) {
//    return LoginInfo.scaffold(_con);
    return TodosPage().widget;

//    return Scaffold(
//      appBar: AppBar(title: Text("My Home Page")),
//      endDrawer: AppDrawer(),
//      body: LoginInfo.body(_con),
//    );
  }

  void _onPressed() {
    Navigator.of(context).pushNamed("/todos");
  }
}