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
    _menu = WorkMenu();
  }
  Controller con;
  WorkMenu _menu;

  @override
  Widget build(BuildContext context) {
    if (!con.app.loggedIn) return SignIn();
    return Scaffold(
      key: con.list.scaffoldKey,
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
        child: con.list.items.length == 0
            ? Container()
            : ListView.builder(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(6.0),
                itemCount: con.list.items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: ObjectKey(con.list.items[index]['rowid']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (DismissDirection direction) {
                      con.edit.delete(con.list.items[index]);
                      final String action =
                          (direction == DismissDirection.endToStart)
                              ? 'deleted'
                              : 'archived';
                      con.list.scaffoldKey.currentState?.showSnackBar(SnackBar(
                          content: Text('You $action an item.'),
                          action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                con.edit.unDelete(con.list.items[index]);
                              })));
                    },
                    background: Container(
                        color: Colors.red,
                        child: const ListTile(
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
                            int.tryParse(con.list.items[index]['Icon']),
                            fontFamily: 'MaterialIcons')),
                        title: Text(con.list.items[index]['Item']),
                        subtitle: Text(con.list.dateFormat.format(
                            DateTime.tryParse(
                                con.list.items[index]['DateTime']))),
                        onTap: () => editToDo(con.list.items[index]),
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
    await con.list.retrieve();
    refresh();
  }

  @override
  void onError(FlutterErrorDetails details) {
    print(details.exception.toString());
  }
}
