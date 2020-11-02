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

import 'dart:async' show Future;

import 'package:auth/auth.dart';

import 'package:intl/intl.dart' show DateFormat;

import 'package:workingmemory/src/model.dart' as m;

import 'package:workingmemory/src/view.dart'
    show
        App,
        AppLifecycleState,
        DataFields,
        FormState,
        MaterialPageRoute,
        Navigator,
        Prefs,
        SignIn,
        Text,
        TextEditingController,
        ThemeData,
        Widget;

import 'package:workingmemory/src/controller.dart';

import 'package:workingmemory/src/app/controller/notifications.dart';

final ThemeData theme = App.themeData;

class Controller extends ControllerMVC {
  factory Controller() => _this ??= Controller._();
  Controller._() : super() {
    // The data for the app.
    _model = m.Model();
    _dataFields = ToDoEdit(this);
    _icons = m.Icons.code;
  }
  static Controller _this;

  // External access to the Model component.
  m.Model get model => _model;
  m.Model _model;

  /// Allow for easy access to 'the Controller' throughout the application.
  // ignore: prefer_constructors_over_static_methods
  static Controller get con => _this ?? Controller();

  WorkingController get app => _app ??= WorkingController();
  WorkingController _app;

  @override
  void rebuild() => _this.refresh();

  Future<List<Map<String, dynamic>>> requery() async {
    final recs = await data.query();
    refresh();
    return recs;
  }

  @override
  Future<bool> initAsync() async {
    // Initiate the 'Model' aspect of this app.
    final bool init = await _model.initAsync();
//    final List<Map<String, dynamic>> records = await data.query();
//    unawaited(setAlarms(records));
    await data.query();
    _favIcons = await _model.listIcons();
    return init;
  }

  @override
  void initState() {
    super.initState();
    _notifications = FlutterNotifications(state?.context);
  }

  FormState formState;

  ToDoEdit get data => _dataFields;
  ToDoEdit _dataFields;

  String get editKey => _editKey;
  String _editKey;

  String get listKey => _listKey;
  String _listKey;

  List<Map<String, dynamic>> get favIcons => _favIcons;
  List<Map<String, dynamic>> _favIcons;

  Map<String, String> get icons => _icons;
  Map<String, String> _icons;

  Future<bool> saveIcon(String icon) async {
    data.icon = icon;
    final bool save = await _model.saveIcon(icon);
    _favIcons = await _model.listIcons();
    return save;
  }

  @override
  void dispose() {
    _model.dispose();
    _notifications.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    await Navigator.push(state.context,
        MaterialPageRoute<void>(builder: (context) => const SignIn()));
    refresh();
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
    Map<String, dynamic> _newRec = {};
    if (oldRec == null) {
      _newRec = _model.newRec(diffRec);
    } else {
      oldRec.addAll(diffRec);
      _newRec = oldRec;
    }
    return _newRec;
  }

  // Dump the user's records to Firebase.
  // Add Firebase records to the local database.
  void recordDump(User user) {
    if (user == null) {
      return;
    }
    _model.recordDump().then((dump) {
      requery();
    });
  }

  String get defaultIcon => _model.defaultIcon;

  void reSync() {
    _model.reSync();
    refresh();
  }

  bool itemsOrdered([bool ordered]) => _model.itemsOrdered(ordered);

  Future<void> setAlarms(List<Map<String, dynamic>> list) async {
    recs = list;
    final Iterator<Map<String, dynamic>> it = list.iterator;
    String sDateTime;
    DateTime time;
    final DateTime threshold = DateTime.now();
    bool oneShot;
    while (it.moveNext()) {
      final int id = it.current['rowid'];
      if (id == null) {
        continue;
      }
      sDateTime = it.current['DateTime'];
      if (sDateTime == null) {
        continue;
      }
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

//  ScheduleNotifications notifications;
  FlutterNotifications _notifications;

  /// Establish any notifications indicated in the record.
  Future<int> setNotification(Map<String, dynamic> rec) async {
    //
    final dateTime = rec['DateTime'];
    DateTime time;
    if (dateTime is String) {
      time = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      time = dateTime;
    } else {
      return -1;
    }

    int id;

    if (time != null) {
      id = rec['AlarmId'] ?? -1;

      // Cancel the previous notification if any.
      if (id > -1) {
        await _notifications.cancel(id);
      }

      id = await _notifications.set(
          state.context, time, rec['TimeZone'], rec['Item'], 'WorkingMemory');

      id ??= -1;

      if (id > -1) {
        rec['AlarmId'] = id;
      }
    }
    return id;
  }

  bool cancelNotification(int id) {
    final bool cancel = id != null && id > -1;
    if (cancel) {
      _notifications.cancel(id);
    }
    return cancel;
  }
}

class _ToDoFields {
  Map<String, dynamic> todo;
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
  TextEditingController controller;
  bool hasChanged = false;

  String get item => _item;
  set item(String text) {
    _item = text;
    controller?.text = text;
  }

  String _item;

  Map<String, dynamic> todo;
  String icon;
  DateTime dateTime;
  bool saveNeeded;

  DateFormat get dateFormat =>
      DateFormat('EEEE, MMM dd  h:mm a', App.locale.languageCode);

  Widget get title => Text(hasName ? _item : 'New');

  void init([Map<String, dynamic> todo]) {
    this.todo = todo;

    hasName = this.todo?.isNotEmpty ?? false;

    if (hasName) {
      _item = todo['Item'];
      dateTime = DateTime.tryParse(todo['DateTime']);
      icon = todo['Icon'];
    } else {
      _item = ' ';
      icon = con.defaultIcon;
    }

    if (controller == null) {
      controller = TextEditingController(text: _item);

      controller.addListener(() {
        hasChanged = controller.value.text != _item;
      });
    } else {
      // Re-instantiating every time is not efficient.
      controller.text = _item;
    }

    dateTime = dateTime ?? DateTime.now();
  }

  /// Retrieve the to-do items from the database
  @override
  Future<List<Map<String, dynamic>>> retrieve() => _model.list();

  Future<bool> onPressed() async {
    bool save = con.data.saveForm();
    if (save) {
      save = await saveRec(
          {'Item': controller.text.trim(), 'DateTime': dateTime, 'Icon': icon},
          todo);
      await query();
    }
    return save;
  }

  Future<bool> saveRec(
          Map<String, dynamic> diffRec, Map<String, dynamic> oldRec) =>
      save(con?.newRec(diffRec, oldRec));

  @override
  Future<bool> save(Map<String, dynamic> rec) async {
    //
    rec['TimeZone'] = Prefs.getString('timezone');

    final int id = await con?.setNotification(rec);

    bool save = id > -1;

    if (save) {
      save = await _model.save(rec);
      if (!save) {
        con?.cancelNotification(id);
      }
    }
    return save;
  }

  @override
  Future<bool> delete(Map<String, dynamic> rec) async {
    final bool delete = await _model.delete(rec);
    await con?.data?.query();
    return delete;
  }

  @override
  Future<bool> undo(Map<String, dynamic> rec) async {
    final bool undo = await _model.unDelete(rec);
    await con?.data?.query();
    return undo;
  }

  Future<bool> favIcon() {
    return Future.value(true);
  }
}
