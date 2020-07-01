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

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart'
    show
        BuildContext,
        Colors,
        Container,
        FlutterErrorDetails,
        Icon,
        Icons,
        ListTile,
        Material,
        MaterialPageRoute,
        MaterialType,
        Navigator,
        Route,
        RouteSettings,
        SafeArea,
        SnackBar,
        SnackBarAction,
        Text,
        Widget;

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart'
    show App, SettingsScreen, SignIn, StateMVC, TodoPage, TodosPage, WorkMenu;

import 'package:workingmemory/src/controller.dart' show Controller;

class TodosiOS extends StateMVC<TodosPage> {
  TodosiOS() : super(Controller()) {
    con = controller;
    _menu = WorkMenu();
  }
  Controller con;
  WorkMenu _menu;

  @override
  Widget build(BuildContext context) {
    if (!con.app.loggedIn) return SignIn();
    return CupertinoTabScaffold(
      key: con.data.scaffoldKey,
      tabBar: CupertinoTabBar(items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          title: const Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.create_solid),
          title: const Text('Create'),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          title: const Text('Settings'),
        ),
      ]),
      tabBuilder: (context, index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: MemoryList(parent: this),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: TodoPage(),
              );
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return SettingsScreen();
            });
            break;
        }
        return returnValue;
      },
    );
  }

  void editToDo([Map todo]) async {
    Route route = MaterialPageRoute<Map<String, dynamic>>(
      settings: RouteSettings(name: "/todos/todo"),
      builder: (BuildContext context) => TodoPage(todo: todo),
      fullscreenDialog: true,
    );

    await Navigator.of(context).push(route);
    await con.data.retrieve();
    refresh();
  }

  @override
  void onError(FlutterErrorDetails details) {
    print(details.exception.toString());
  }
}

class MemoryList extends StatelessWidget {
  MemoryList({this.parent, Key key}) : super(key: key);
  final TodosiOS parent;
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _items = parent.con.data.items;
    bool leftHanded = Settings.getLeftHanded();
    return SafeArea(
      child: parent.con.data.items.length == 0
          ? Container()
          : CustomScrollView(
              scrollDirection: Axis.vertical,
//        padding: EdgeInsets.all(6.0),
              semanticChildCount: _items.length,
              slivers: <Widget>[
                const CupertinoSliverNavigationBar(
                  largeTitle: const Text('Working Memory'),
                ),
                SliverSafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(top: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _items.length) return null;
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
                            Controller()
                                .data
                                .scaffoldKey
                                .currentState
                                ?.showSnackBar(SnackBar(
                                    content: Text('You $action an item.'),
                                    action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () {
                                          Controller().data.undo(_items[index]);
                                        })));
                          },
                          background: Container(
                              color: Colors.red,
                              child: Material(
                                  type: MaterialType.transparency,
                                  child: const ListTile(
                                      leading: const Icon(Icons.delete,
                                          color: Colors.white, size: 36.0),
                                      trailing: const Icon(Icons.delete,
                                          color: Colors.white, size: 36.0)))),
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
                                  onTap: () => parent.editToDo(_items[index]),
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

//class MemoryList extends StatelessWidget {
//  MemoryList({this.parent, Key key}) : super(key: key);
//  final TodosiOS parent;
//  @override
//  Widget build(BuildContext context) {
//    List<Map<String, dynamic>> _items = parent.con.list.items;
//    return SafeArea(
//      child: parent.con.list.items.length == 0
//          ? Container()
//          : ListView.builder(
//              scrollDirection: Axis.vertical,
//              padding: EdgeInsets.all(6.0),
//              itemCount: _items.length,
//              itemBuilder: (BuildContext context, int index) {
//                return Dismissible(
//                  key: ObjectKey(_items[index]['rowid']),
//                  direction: DismissDirection.endToStart,
//                  onDismissed: (DismissDirection direction) {
//                    Controller().edit.delete(_items[index]);
////                    final String action = (direction == DismissDirection.endToStart)
////                        ? 'deleted'
////                        : 'archived';
////                    Controller().list.scaffoldKey.currentState?.showSnackBar(SnackBar(
////                        content: Text('You $action an item.'),
////                        action: SnackBarAction(
////                            label: 'UNDO',
////                            onPressed: () {
////                              Controller().edit.unDelete(_items[index]);
////                            })));
//                  },
//                  background: Container(
//                      color: Colors.red,
//                      child: Material(
//                          type: MaterialType.transparency,
//                          child: const ListTile(
//                              trailing: const Icon(Icons.delete,
//                                  color: Colors.white, size: 36.0)))),
//                  child: Container(
//                    decoration: BoxDecoration(
//                        color: App.theme.canvasColor,
//                        border: Border(
//                            bottom: BorderSide(color: App.theme.dividerColor))),
//                    child: Material(
//                        type: MaterialType.transparency,
//                        child: ListTile(
//                          leading: Icon(IconData(
//                              int.tryParse(_items[index]['Icon']),
//                              fontFamily: 'MaterialIcons')),
//                          title: Text(_items[index]['Item']),
//                          subtitle: Text(parent.con.list.dateFormat.format(
//                              DateTime.tryParse(_items[index]['DateTime']))),
//                          onTap: () => parent.editToDo(_items[index]),
//                        )),
//                  ),
//                );
//              },
//            ),
//    );
//  }
//}
