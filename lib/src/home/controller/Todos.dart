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
///          Created  04 Nov 2018

import "dart:async" show Future;

import 'package:flutter/material.dart'
    show
        AppLifecycleState,
        FormState,
        GlobalKey,
        ScaffoldState,
        Text,
        TextEditingController,
        ThemeData,
        Widget;

import 'package:intl/intl.dart' show DateFormat;

import 'package:workingmemory/src/model.dart' as m;

import 'package:workingmemory/src/view.dart' show App;

import 'package:workingmemory/src/controller.dart';

final ThemeData theme = App.theme;

class Controller extends ControllerMVC {
  factory Controller() => _this ??= Controller._();
  static Controller _this;

  Controller._() : super() {
    model = m.Model();
    _editToDo = ToDoEdit();
    _listToDo = ToDoList();
  }
  m.Model model;
  WorkingMemoryApp _app;

  ToDoEdit get edit => _editToDo;
  ToDoEdit _editToDo;
  String get editKey => _editKey;
  String _editKey;

  ToDoList get list => _listToDo;
  ToDoList _listToDo;
  String get listKey => _listKey;
  String _listKey;

  /// Allow for easy access to 'the Controller' throughout the application.
  static Controller get con => _this ?? Controller();

  WorkingMemoryApp get app => _app ??= WorkingMemoryApp();

  void rebuild() => _this.refresh();

  Future<bool> init() async {
    bool init = await model.init();
//    list.retrieve().then((list) {
//      // Display the list.
//      refresh();
//      setAlarms(list);
//    });
    List<Map<String, dynamic>> recs = await list.retrieve();
    // Display the list.
//    refresh();
    setAlarms(recs);
    _editKey = edit.addState(this.stateMVC);
    _listKey = list.addState(this.stateMVC);
    return init;
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  void signIn() {
    app.signIn();
    refresh();
  }

  void logOut() => app.logOut();

  Future<void> signOut() => app.signOut();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
//      if(app.loggedIn)
//      model.sync();
    }

    /// Passing these possible values:
    /// AppLifecycleState.paused (may enter the suspending state at any time)
    /// AppLifecycleState.resumed
    /// AppLifecycleState.inactive (may be paused at any time)
    /// AppLifecycleState.suspending (Android only)
  }

  Future<bool> save(Map<String, dynamic> data) => model.save(data);

  Future<bool> saveRec(
      Map<String, dynamic> diffRec, Map<String, dynamic> oldRec) {
    Map newRec = Map<String, dynamic>();

    if (oldRec == null) {
      newRec.addAll(diffRec);
    } else {
      newRec.addAll(oldRec);

      newRec.addEntries(diffRec.entries);
    }
    return save(newRec);
  }

  get defaultIcon => model.defaultIcon;

  void reSync() => model.reSync();

  void setAlarms(List<Map<String, dynamic>> list) async {
    recs = list;
    Iterator it = list.iterator;
    String sDateTime;
    DateTime time;
    DateTime threshold = DateTime.now();
    bool oneShot;
    while (it.moveNext()) {
      int id = it.current["rowid"];
      if (id == null) continue;
      sDateTime = it.current["DateTime"];
      if (sDateTime == null) continue;
      time = DateTime.parse(sDateTime);
      if (time.isAfter(threshold)) {
        oneShot = await AlarmManager.oneShotAt(
          time,
          id,
          (int id) async {
            Iterator it = recs.iterator;
            int rowid;
            while (it.moveNext()) {
              rowid = it.current["rowid"];
              if (rowid == null) continue;
              if (rowid == id) {
                break;
              }
            }
          },
          exact: true,
        );
        if (!oneShot) {
          getError(Exception("AlarmManager.oneShotAt returned false."));
          break;
        }
//        AlarmManager.cancel(id).then((cancel) {
//          print(cancel);
//        });
      }
      break;
    }
  }

  static List<Map<String, dynamic>> recs;
}

class ToDoEdit extends ToDoList {
  bool hasName;
  TextEditingController changer;
  bool hasChanged = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();

  void init([Map todo]) {
    this.todo = todo;

    hasName = this.todo?.isNotEmpty ?? false;

    if (hasName) {
      item = todo['Item'];
      dateTime = DateTime.tryParse(todo['DateTime']);
      icon = todo['Icon'];
    } else {
      item = ' ';
      icon = Controller().defaultIcon;
    }

    changer = TextEditingController(text: item);
    changer.addListener(() {
      hasChanged = changer.value.text != item;
    });

    dateTime = dateTime ?? DateTime.now();
  }

  Widget get title => Text(hasName ? item : 'New');

  Future<bool> onPressed() async {
    bool save = formKey.currentState.validate();
    if (save) {
      formKey.currentState.save();
      save = await this.save(
          {'Item': changer.text.trim(), 'DateTime': dateTime, 'Icon': icon},
          this.todo);
// Let's see if this is necessary.
//      await con.list.retrieve();
//      refresh();
    }
    return save;
  }

  Future<bool> save(
      Map<String, dynamic> diffRec, Map<String, dynamic> oldRec) async {
    bool save = await Controller().saveRec(diffRec, oldRec);
    return save;
  }

  Future<bool> delete(Map<String, dynamic> data) =>
      model.delete(data).then((delete) async {
        await Controller().list.retrieve();
        refresh();
        return delete;
      });

  Future<bool> unDelete(Map<String, dynamic> data) =>
      model.unDelete(data).then((un) async {
        await Controller().list.retrieve();
        refresh();
        return un;
      });
}

typedef MapCallback = void Function(Map data);

class ToDoList extends ToDoFields {
  ToDoList() : super() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    model = m.Model();
  }
  final DateFormat dateFormat = DateFormat('EEEE, MMM dd  h:mm a');
  GlobalKey<ScaffoldState> scaffoldKey;
  m.Model model;

  List<Map<String, dynamic>> get items => _items;
  List<Map<String, dynamic>> _items = [];

  /// Retrieve the to-do items from the database
  Future<List<Map<String, dynamic>>> retrieve() async {
    _items = await model.list();
    return _items;
  }
}

class ToDoFields extends ControllerMVC {
  Map todo;
  String item;
  String icon;
  DateTime dateTime;
  bool saveNeeded;
  bool hasChanged;
}
