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
///          Created  04 Nov 2018

import "dart:async" show Future;

import 'package:auth/auth.dart';

import 'package:flutter/material.dart'
    show
        AppLifecycleState,
        FormState,
        GlobalKey,
        MaterialPageRoute,
        Navigator,
        ScaffoldState,
        Text,
        TextEditingController,
        ThemeData,
        Widget;

import 'package:intl/intl.dart' show DateFormat;

import 'package:workingmemory/src/model.dart' as m;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart';

final ThemeData theme = App.themeData;

class Controller extends ControllerMVC {
  factory Controller() => _this ??= Controller._();
  static Controller _this;

  Controller._() : super() {
    _model = m.Model();
    _dataFields = ToDoEdit(this);
    //   _editToDo = ToDoEdit();
    //   _listToDo = _editToDo;
  }

  // External access to the Model component.
  m.Model get model => _model;
  m.Model _model;

  /// Allow for easy access to 'the Controller' throughout the application.
  static Controller get con => _this ?? Controller();

  ToDoEdit get data => _dataFields;
  ToDoEdit _dataFields;

//  ToDoEdit get edit => _editToDo;
//  ToDoEdit _editToDo;

  String get editKey => _editKey;
  String _editKey;

//  _ToDoList get list => _listToDo;
//  _ToDoList _listToDo;

  String get listKey => _listKey;
  String _listKey;

  WorkingMemoryApp get app => _app ??= WorkingMemoryApp();
  WorkingMemoryApp _app;

  void rebuild() => _this.refresh();

  Future<List<Map<String, dynamic>>> requery() async{
    var recs = await data.query();
    refresh();
    return recs;
  }

  Future<bool> initAsync() async {
    bool init = await _model.initAsync();
//    list.retrieve().then((list) {
//      // Display the list.
//      refresh();
//      setAlarms(list);
//    });
//    List<Map<String, dynamic>> recs = await list.retrieve();
    List<Map<String, dynamic>> records = await data.query();
    // Display the list.
//    refresh();
    setAlarms(records);
//    _editKey = edit.addState(this.stateMVC);
//    _listKey = list.addState(this.stateMVC);

    // Return the list of favourite icons.
    _favIcons = await _model.listIcons();

    return init;
  }

  List<Map<String, dynamic>> get favIcons => _favIcons;
  List<Map<String, dynamic>> _favIcons;

  Map<String, String> get icons => _icons;
  Map<String, String> _icons = m.Icons.code;

  Future<bool> saveIcon(String icon) async {
    data.icon = icon;
    bool save = await _model.saveIcon(icon);
    _favIcons = await _model.listIcons();
    return save;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void signIn() async {
//    app.signIn();
    signOut();
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignIn()));
//   refresh();
  }

  void logOut() => app.logOut();

  Future<void> signOut() => app.signOut();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// Passing these possible values:
    /// AppLifecycleState.paused (may enter the suspending state at any time)
    /// AppLifecycleState.resumed
    /// AppLifecycleState.inactive (may be paused at any time)
    /// AppLifecycleState.suspending (Android only)
    if (state == AppLifecycleState.resumed) {
//      if(app.loggedIn)
//      _model.sync();
    }
  }

  Future<bool> save(Map<String, dynamic> data) => _model.save(data);

  Future<bool> saveRec(
          Map<String, dynamic> diffRec, Map<String, dynamic> oldRec) =>
      save(newRec(diffRec, oldRec));

  Map<String, dynamic> newRec(
      Map<String, dynamic> diffRec, Map<String, dynamic> oldRec) {
    Map<String, dynamic> newRec = Map();

    if (oldRec == null) {
      newRec.addAll(diffRec);
    } else {
      newRec.addAll(oldRec);

      newRec.addEntries(diffRec.entries);
    }
    return newRec;
  }

  recordDump(FirebaseUser user) async {
    if (user == null) return;
    bool dump = await _model.recordDump();
    if (dump) {
      requery();
    }
  }

  get defaultIcon => _model.defaultIcon;

  void reSync() => _model.reSync();

  bool itemsOrdered([bool ordered]) => _model.itemsOrdered(ordered);

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
//        oneShot = await AlarmManager.oneShotAt(
//          time,
//          id,
//          (int id) async {
//            Iterator it = recs.iterator;
//            int rowid;
//            while (it.moveNext()) {
//              rowid = it.current["rowid"];
//              if (rowid == null) continue;
//              if (rowid == id) {
//                break;
//              }
//            }
//          },
//          exact: true,
//        );
//        if (!oneShot) {
//          getError(Exception("AlarmManager.oneShotAt returned false."));
//          break;
//        }
//        AlarmManager.cancel(id).then((cancel) {
//          print(cancel);
//        });
      }
      break;
    }
  }

  static List<Map<String, dynamic>> recs;
}

//class ToDoEdit extends _ToDoList {
//  bool hasName;
//  TextEditingController changer;
//  bool hasChanged = false;
//
////  final scaffoldKey = GlobalKey<ScaffoldState>();
//
//  final formKey = GlobalKey<FormState>();
//
//  void init([Map todo]) {
//    this.todo = todo;
//
//    hasName = this.todo?.isNotEmpty ?? false;
//
//    if (hasName) {
//      item = todo['Item'];
//      dateTime = DateTime.tryParse(todo['DateTime']);
//      icon = todo['Icon'];
//    } else {
//      item = ' ';
//      icon = Controller().defaultIcon;
//    }
//
//    changer = TextEditingController(text: item);
//    changer.addListener(() {
//      hasChanged = changer.value.text != item;
//    });
//
//    dateTime = dateTime ?? DateTime.now();
//  }
//
//  Widget get title => Text(hasName ? item : 'New');
//
//  Future<bool> onPressed() async {
//    bool save = formKey.currentState.validate();
//    if (save) {
//      formKey.currentState.save();
//      save = await this.save(
//          {'Item': changer.text.trim(), 'DateTime': dateTime, 'Icon': icon},
//          this.todo);
//      await retrieve();
//    }
//    return save;
//  }
//
//  Future<bool> save(
//      Map<String, dynamic> diffRec, Map<String, dynamic> oldRec) async {
//    bool save = await Controller().saveRec(diffRec, oldRec);
//    return save;
//  }
//
//  Future<bool> delete(Map<String, dynamic> data) =>
//      _model.delete(data).then((delete) async {
//        await Controller().data.query();
//        return delete;
//      });
//
//  Future<bool> unDelete(Map<String, dynamic> data) =>
//      _model.unDelete(data).then((un) async {
//        await Controller().data.query();
//        return un;
//      });
//}
//
//typedef MapCallback = void Function(Map data);
//
//class _ToDoList extends _ToDoFields {
//  _ToDoList() : super() {
//    scaffoldKey = GlobalKey<ScaffoldState>();
//    _model = m.Model();
//  }
//  final DateFormat dateFormat = DateFormat('EEEE, MMM dd  h:mm a');
//  GlobalKey<ScaffoldState> scaffoldKey;
//  m.Model _model;
//
//  List<Map<String, dynamic>> get items => _items;
//  List<Map<String, dynamic>> _items = [];
//
//  /// Retrieve the to-do items from the database
//  Future<List<Map<String, dynamic>>> retrieve() async {
//    _items = await _model.list();
//    return _items;
//  }
//}

class _ToDoFields {
  Map todo;
  String item;
  String icon;
  DateTime dateTime;
  bool saveNeeded;
  bool hasChanged;
}

class ToDoEdit extends DataFields {
  ToDoEdit(this.con) {
    _model = m.Model();
  }
  final Controller con;

  m.Model get model => _model;
  m.Model _model;

  bool hasName;
  TextEditingController changer;
  bool hasChanged = false;

  Map todo;
  String item;
  String icon;
  DateTime dateTime;
  bool saveNeeded;

  final DateFormat dateFormat = DateFormat('EEEE, MMM dd  h:mm a');

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();

  Widget get title => Text(hasName ? item : 'New');

  void init([Map todo]) {
    this.todo = todo;

    hasName = this.todo?.isNotEmpty ?? false;

    if (hasName) {
      item = todo['Item'];
      dateTime = DateTime.tryParse(todo['DateTime']);
      icon = todo['Icon'];
    } else {
      item = ' ';
      icon = con.defaultIcon;
    }

    changer = TextEditingController(text: item);
    changer.addListener(() {
      hasChanged = changer.value.text != item;
    });

    dateTime = dateTime ?? DateTime.now();
  }

  /// Retrieve the to-do items from the database
  @override
  Future<List<Map<String, dynamic>>> retrieve() => _model.list();

  Future<bool> onPressed() async {
    bool save = formKey.currentState.validate();
    if (save) {
      formKey.currentState.save();
      save = await this.saveRec(
          {'Item': changer.text.trim(), 'DateTime': dateTime, 'Icon': icon},
          this.todo);
      await query();
    }
    return save;
  }

  Future<bool> saveRec(
          Map<String, dynamic> diffRec, Map<String, dynamic> oldRec) =>
      save(con?.newRec(diffRec, oldRec));

  @override
  Future<bool> save(Map<String, dynamic> rec) => _model.save(rec);

  @override
  Future<bool> delete(Map<String, dynamic> rec) async {
    bool delete = await _model.delete(rec);
    await con?.data?.query();
    return delete;
  }

  @override
  Future<bool> undo(Map<String, dynamic> rec) async {
    bool undo = await _model.unDelete(rec);
    await con?.data?.query();
    return undo;
  }

  Future<bool> favIcon() {
    return Future.value(true);
  }
}
