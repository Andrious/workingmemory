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
    show SettingsDrawer, SignIn, StateMVC, TodoPage, TodosPage, WorkMenu;

import 'package:workingmemory/src/controller.dart' show App, Controller;

class TodosAndroid extends StateMVC<TodosPage> {
  TodosAndroid() : super(Controller()) {
    con = controller;
  }
  Controller con;
  WorkMenu _menu;

  @override
  Widget build(BuildContext context) {
    // Rebuilt the menu if state changes.
    _menu = WorkMenu();
    if (!con.app.loggedIn) return SignIn();
    return Scaffold(
      key: con.data.scaffoldKey,
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
        child: con.data.items.length == 0
            ? Container()
            : ListView.builder(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(6.0),
                itemCount: con.data.items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: ObjectKey(con.data.items[index]['rowid']),
                    onDismissed: (DismissDirection direction) {
                      con.data.delete(con.data.items[index]);
                      con.data.scaffoldKey.currentState?.showSnackBar(SnackBar(
                          content: Text('You deleted an item.'),
                          action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                con.data.undo(con.data.items[index]);
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
                          color: App.theme.canvasColor,
                          border: Border(
                              bottom:
                                  BorderSide(color: App.theme.dividerColor))),
                      child: ListTile(
                        leading: Icon(IconData(
                            int.tryParse(con.data.items[index]['Icon']),
                            fontFamily: 'MaterialIcons')),
                        title: Text(con.data.items[index]['Item']),
                        subtitle: Text(con.data.dateFormat.format(
                            DateTime.tryParse(
                                con.data.items[index]['DateTime']))),
                        onTap: () => editToDo(con.data.items[index]),
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

  @override
  void onError(FlutterErrorDetails details) {
    print(details.exception.toString());
  }
}
