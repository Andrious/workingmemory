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
///          Created  01 Mar 2020

/// place: "/todos"

//import 'package:flutter/cupertino.dart';

//import 'package:flutter/material.dart';
//    show
//        BuildContext,
//        Colors,
//        Container,
//        FlutterErrorDetails,
//        Icon,
//        Icons,
//        ListTile,
//        Material,
//        MaterialType,
//        SafeArea,
//        Scaffold,
//        SnackBar,
//        SnackBarAction,
//        Text,
//        Widget;

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' show Controller;

class TodosiOS extends StateMVC<TodosPage> {
  //
  TodosiOS() : super(Controller()) {
    con = controller;
  }
  Controller con;
  int _segment = 0;

  WorkMenu _menu;

  @override
  Widget build(BuildContext context) {
//    if (!con.app.loggedIn) return SignIn();
    // Rebuilt the menu if state changes.
    _menu = WorkMenu();
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(10),
            onPressed: () {
              editToDo(con.context);
            },
            child: const Text('New'),
          ),
        ),
        child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoSegmentedControl<int>(
                  groupValue: _segment,
                  children: const <int, Widget>{
                    0: Text('New'),
                    1: Text('Settings'),
                  },
                  onValueChanged: (i) {
                    setState(() {
                      _segment = i;
                      switch (i) {
                        case 0:
                          break;
                        case 1:
                          break;
                        case 2:
                          break;
                      }
                    });
                  },
                ),
                Expanded(child: MemoryList(parent: this)),
              ],
            )));
  }

  Future<void> editToDo(BuildContext context, [Map todo]) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => TodoPage(todo: todo),
    );
    refresh();
  }

  @override
  void onError(FlutterErrorDetails details) {
    super.onError(details);
  }
}

class MemoryList extends StatelessWidget {
  //
  const MemoryList({this.parent, Key key}) : super(key: key);
  final TodosiOS parent;
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _items = parent.con.data.items;
    final bool leftHanded = Settings.getLeftHanded();
    return SafeArea(
      child: parent.con.data.items.isEmpty
          ? Container()
          : CustomScrollView(
              shrinkWrap: true,
              semanticChildCount: _items.length,
              slivers: <Widget>[
                const CupertinoSliverNavigationBar(
                  largeTitle: Text('Working Memory'),
                ),
                SliverSafeArea(
//                  top: false,
//                  minimum: const EdgeInsets.only(top: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _items.length) {
                          return null;
                        }
                        return Dismissible(
                          key: ObjectKey(_items[index]['rowid']),
                          direction: leftHanded
                              ? DismissDirection.startToEnd
                              : DismissDirection.endToStart,
                          onDismissed: (DismissDirection direction) {
                            Controller().data.delete(_items[index]);
                            final String action =
                                (direction == DismissDirection.endToStart)
                                    ? 'deleted'
                                    : 'archived';
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('You $action an item.'),
                                action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      Controller().data.undo(_items[index]);
                                    })));
                          },
                          background: Container(
                              color: Colors.red,
                              child: const Material(
                                  type: MaterialType.transparency,
                                  child: ListTile(
                                      leading: Icon(Icons.delete,
                                          color: Colors.white, size: 36),
                                      trailing: Icon(Icons.delete,
                                          color: Colors.white, size: 36)))),
                          child: Container(
                            decoration: BoxDecoration(
                                color: App.themeData.canvasColor,
                                border: Border(
                                    bottom: BorderSide(
                                        color: App.themeData.dividerColor))),
                            child: Material(
                                type: MaterialType.transparency,
                                child: ListTile(
                                  leading: Icon(IconData(
                                      int.tryParse(_items[index]['Icon']),
                                      fontFamily: 'MaterialIcons')),
                                  title: Text(_items[index]['Item']),
                                  subtitle: Text(parent.con.data.dateFormat
                                      .format(DateTime.tryParse(
                                          _items[index]['DateTime']))),
                                  onTap: () =>
                                      parent.editToDo(context, _items[index]),
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
    );
  }
}