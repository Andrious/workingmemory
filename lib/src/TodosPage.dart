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
import 'dart:async';
import 'package:flutter/material.dart';

import 'Model.dart';

class TodosPage extends StatefulWidget {
  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Todos")),
      body: RefreshIndicator(
        child: ListView.builder(itemBuilder: _itemBuilder),
        onRefresh: _onRefresh,
      ),
    );
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = Completer<Null>();
    Timer timer = Timer(Duration(seconds: 3), () {
      completer.complete();
    });
    return completer.future;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Todo todo = getTodo(index);
    return TodoItemWidget(todo: todo);
  }

  Todo getTodo(int index) {
    return Todo(false, "Todo $index");
  }
}

class TodoItemWidget extends StatefulWidget {
  TodoItemWidget({Key key, this.todo}) : super(key: key);

  final Todo todo;

  @override
  _TodoItemWidgetState createState() => new _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("-"),
      title: Text(widget.todo.name),
      onTap: _onTap,
    );
  }

  void _onTap() {
    Route route = MaterialPageRoute(
      settings: RouteSettings(name: "/todos/todo"),
      builder: (BuildContext context) => TodoPage(todo: widget.todo),
    );
    Navigator.of(context).push(route);
  }
}

/// place: "/todos/todo"
class TodoPage extends StatefulWidget {
  TodoPage({Key key, this.todo}) : super(key: key);

  final Todo todo;

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  Widget build(BuildContext context) {
    var _children = <Widget>[
      Text("finished: " + widget.todo.finished.toString()),
      Text("name: " + widget.todo.name),
    ];
    return Scaffold(
      appBar: AppBar(title: new Text("My Todo")),
      body: Column(
        children: _children,
      ),
    );
  }
}
