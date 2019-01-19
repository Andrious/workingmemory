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
///          Created  16 Jun 2018

/// place: "/todos"

import 'package:flutter/material.dart'
    show
        AppBar,
        AsyncSnapshot,
        BuildContext,
        Center,
        CircularProgressIndicator,
        Colors,
        ConnectionState,
        FloatingActionButton,
        FutureBuilder,
        Icon,
        Icons,
        Key,
        MaterialPageRoute,
        Navigator,
        RaisedButton,
        Route,
        RouteSettings,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        Widget;

import 'package:mvc_application/view.dart' show StateMVC;

import 'package:workingmemory/src/controller/Todos.dart' show Controller;

import 'package:workingmemory/src/view/TodoPage.dart' show TodoPage;

import 'package:workingmemory/src/view/SettingsDrawer.dart' show SettingsDrawer;

class TodosPage extends StatefulWidget {
  TodosPage({Key key}) : super(key: key);

  @override
  State createState() => _TodosState();
}

class _TodosState extends StateMVC<TodosPage> {
  _TodosState() : super(Controller());

  @override
  void initState() {
    super.initState();
    addListener(Controller.edit);
    addListener(Controller.list);
    Controller.list.query();
  }

  @override
  void dispose() {
    removeListener(Controller.edit);
    removeListener(Controller.list);
//    Controller.list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Controller.list.scaffoldKey,
      endDrawer: SettingsDrawer(),
      appBar: AppBar(
        title: const Text("My ToDos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editToDo(),
        backgroundColor: Colors.redAccent,
        child: const Icon(
          Icons.add,
          semanticLabel: 'Add',
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: Controller.list.future,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData || snapshot.data.length == 0) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Center(
                  child: RaisedButton(
                    child: const Text('New Item'),
                    onPressed: () => editToDo(),
                  ),
                );
              }
            }
            return Controller.list.items(snapshot.data, editToDo);
          }),
    );
  }

  void editToDo([Map todo]) async {
    Route route = MaterialPageRoute<Map<String, dynamic>>(
      settings: RouteSettings(name: "/todos/todo"),
      builder: (BuildContext context) => TodoPage(todo: todo),
      fullscreenDialog: true,
    );

    await Navigator.of(context).push(route);
//    Controller.list.refresh();
  }
}
