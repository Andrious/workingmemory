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

import 'package:flutter/material.dart'
    show
        Alignment,
        AppLifecycleState,
        Axis,
        Border,
        BorderSide,
        BoxDecoration,
        BuildContext,
        Center,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        DismissDirection,
        Dismissible,
        EdgeInsets,
        FormState,
        GlobalKey,
        Icon,
        IconData,
        Icons,
        InputDecoration,
        ListTile,
        ListView,
        ObjectKey,
        ScaffoldState,
        SnackBar,
        SnackBarAction,
        Text,
        TextEditingController,
        TextFormField,
        ThemeData,
        Widget;

import 'package:intl/intl.dart' show DateFormat;

import 'package:workingmemory/src/model.dart' as m;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart';

final ThemeData theme = App.theme;

class Controller extends ControllerMVC {
  factory Controller() => _this ??= Controller._();
  static Controller _this;

  Controller._() : super() {
    model = m.Model();
    _editToDo = ToDoEdit();
    _listToDo = ToDoList();
    app = WorkingMemoryApp();
  }
  m.Model model;
  WorkingMemoryApp app;

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

  void rebuild() => _this.refresh();

  Future<bool> init() async {
    bool init = await model.init();
    list.retrieve().then((_) {
      // Display the list.
      refresh();
    });
    _editKey = edit.addState(this.stateMVC);
    _listKey = list.addState(this.stateMVC);
    return init;
  }

  m.CloudDB _cloud;

  @override
  void dispose() {
    _cloud.dispose();
    model.dispose();
    super.dispose();
  }

  bool get loggedIn => app.loggedIn;

  void logOut() {
    app.logOut();
    refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      model.sync();
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
      hasChanged = true;
    });
    dateTime = dateTime ?? DateTime.now();
  }

  Widget get title => Text(hasName ? item : 'Event Name TBD');

  Widget get child => ListView(
      padding: const EdgeInsets.all(16.0),
      children: Controller().edit.children);

  get children => <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.bottomLeft,
          child: TextFormField(
              controller: changer,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Event name',
              ),
              validator: (v) {
                if (v.trim().isEmpty) return 'Cannot be empty.';
                return null;
              },
              onSaved: (value) {
                item = value;
              }),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Center(
              child: Icon(
                  IconData(int.tryParse(icon), fontFamily: 'MaterialIcons'))),
          Text('From', style: theme.textTheme.caption),
          DateTimeItem(
            dateTime: dateTime,
            onChanged: (DateTime value) {
              setState(() {
                dateTime = value;
              });
              saveNeeded = true;
            },
          )
        ]),
        Container(
            height: 300.0,
            child: IconItems(
                icon: icon,
                onTap: (icon) {
                  setState(() {
                    this.icon = icon;
                  });
                })),
      ];

  Future<void> onPressed() async {
    var con = Controller();
    bool save = con.edit.formKey.currentState.validate();
    if (save) {
      con.edit.formKey.currentState.save();
      save = await con.edit
          .save({'Item': item, 'DateTime': dateTime, 'Icon': icon}, this.todo);
      await con.list.retrieve();
      refresh();
    }
    return Future.value(save);
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

  Future<bool> undelete(Map<String, dynamic> data) =>
      model.undelete(data).then((un) async {
        await Controller().list.retrieve();
        refresh();
        return un;
      });
}

typedef MapCallback = void Function(Map data);

class ToDoList extends ToDoFields {
  final ThemeData _theme = App.theme;

  final _dateFormat = DateFormat('EEEE, MMM dd  h:mm a');

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final m.Model model = m.Model();

  List<Map<String, dynamic>> get items => _items;
  List<Map<String, dynamic>> _items = [];

//  /// Call the setState() function to 'refresh' the widget tree.
//  Future<void> refresh() async {
//    await retrieve();
////    Controller.rebuild();
//  }

  /// Retrieve the to-do items from the database
  Future<void> retrieve() async => _items = await model.list();

  Widget view(MapCallback onTap) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(6.0),
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: ObjectKey(_items[index]['rowid']),
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) {
            Controller().edit.delete(_items[index]);
            final String action = (direction == DismissDirection.endToStart)
                ? 'deleted'
                : 'archived';
            Controller().list.scaffoldKey.currentState?.showSnackBar(SnackBar(
                content: Text('You $action an item.'),
                action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      Controller().edit.undelete(_items[index]);
                    })));
          },
          background: Container(
              color: Colors.red,
              child: const ListTile(
                  trailing: const Icon(Icons.delete,
                      color: Colors.white, size: 36.0))),
          child: Container(
            decoration: BoxDecoration(
                color: _theme.canvasColor,
                border: Border(bottom: BorderSide(color: _theme.dividerColor))),
            child: ListTile(
              leading: Icon(IconData(int.tryParse(_items[index]['Icon']),
                  fontFamily: 'MaterialIcons')),
              title: Text(_items[index]['Item']),
              subtitle: Text(_dateFormat
                  .format(DateTime.tryParse(_items[index]['DateTime']))),
              onTap: () => onTap(_items[index]),
            ),
          ),
        );
      },
    );
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
