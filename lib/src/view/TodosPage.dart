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
///          Created  23 Jun 2018

/// place: "/todos"
import 'dart:async';
import 'package:flutter/material.dart';

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

class Todo{
  Todo(bool whatsthis, String indexWhat);
}

class TodoItemWidget extends Widget{
  TodoItemWidget({Todo todo});

  Element createElement(){
    return NullChildElement(this);
  }
}

class NullChildElement extends Element {
  NullChildElement(Widget widget) : super(widget);

  bool includeChild = false;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (includeChild)
      visitor(null);
  }

  @override
  void forgetChild(Element child) { }

  @override
  void performRebuild() { }
}