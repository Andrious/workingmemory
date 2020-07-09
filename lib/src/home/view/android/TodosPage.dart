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

import 'package:flutter/material.dart'
    show
        AppBar,
        Axis,
        Border,
        BorderSide,
        BoxDecoration,
        BuildContext,
        Colors,
        Container,
        DismissDirection,
        Dismissible,
        EdgeInsets,
        FloatingActionButton,
        FlutterErrorDetails,
        GlobalKey,
        Icon,
        IconData,
        Icons,
        ListTile,
        ListView,
        MaterialPageRoute,
        Navigator,
        ObjectKey,
        Route,
        RouteSettings,
        SafeArea,
        Scaffold,
        SnackBar,
        SnackBarAction,
        Text,
        Widget;

import 'package:workingmemory/src/view.dart'
    show SettingsDrawer, StateMVC, TodoPage, TodosPage, WorkMenu;

import 'package:workingmemory/src/controller.dart' show App, Controller;

class TodosAndroid extends StateMVC<TodosPage> {
  TodosAndroid() : super(Controller()) {
    _con = controller;
  }
  Controller _con;
  WorkMenu _menu;

  @override
  Widget build(BuildContext context) {
    // Rebuilt the menu if state changes.
    _menu = WorkMenu();
    return Scaffold(
      drawer: SettingsDrawer(),
      appBar: AppBar(
        title: const Text("My ToDos"),
        actions: <Widget>[
          _menu.show(this),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editToDo(),
        child: const Icon(
          Icons.add,
          semanticLabel: 'Add',
        ),
      ),
      body: SafeArea(
        child: _con.data.items.length == 0
            ? Container()
            : ListView.builder(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(6.0),
                itemCount: _con.data.items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: ObjectKey(_con.data.items[index]['rowid']),
                    onDismissed: (DismissDirection direction) {
                      _con.data.delete(_con.data.items[index]);
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('You deleted an item.'),
                          action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                _con.data.undo(_con.data.items[index]);
                              })));
                    },
                    background: Container(
                        color: Colors.red,
                        child: const ListTile(
                            leading: const Icon(Icons.delete,
                                color: Colors.white, size: 36.0),
                            trailing: const Icon(Icons.delete,
                                color: Colors.white, size: 36.0))),
                    child: Container(
                      decoration: BoxDecoration(
                          color: App.themeData.canvasColor,
                          border: Border(
                              bottom: BorderSide(
                                  color: App.themeData.dividerColor))),
                      child: ListTile(
                        leading: Icon(IconData(
                            int.tryParse(_con.data.items[index]['Icon']),
                            fontFamily: 'MaterialIcons')),
                        title: Text(_con.data.items[index]['Item']),
                        subtitle: Text(_con.data.dateFormat.format(
                            DateTime.tryParse(
                                _con.data.items[index]['DateTime']))),
                        onTap: () => editToDo(_con.data.items[index]),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void editToDo([Map todo]) async {
    Route route = MaterialPageRoute<Map<String, dynamic>>(
      settings: RouteSettings(name: "/todos/todo"),
      builder: (BuildContext context) => TodoPage(todo: todo),
      fullscreenDialog: true,
    );

    await Navigator.of(context).push(route);
    refresh();
  }
}
