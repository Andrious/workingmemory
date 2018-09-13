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

import 'package:intl/intl.dart';

import 'package:mvc/App.dart';

import 'package:workingmemory/src/controller/Controller.dart';

import 'package:workingmemory/src/view/TodoPage.dart';

import 'package:workingmemory/src/view/SettingsDrawer.dart';

class TodosPage extends StatedWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Map>> _data;
  List _content;

  final _dateFormat = new DateFormat('EEEE, MMM dd  h:mm a');

  final ThemeData _theme = App.theme;

  final Set _deletedRecs = Set();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = Controller.list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SettingsDrawer(),
      appBar: AppBar(
        title: Text("My ToDos"),
//          actions: <Widget>[
//            RaisedButton(
//              child: Text(
//                "NEW",
//                style: TextStyle(color: Colors.white),
//              ),
//              onPressed:(){editToDo();},
//            )
//          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){editToDo();},
        backgroundColor: Colors.redAccent,
        child: const Icon(
          Icons.add,
          semanticLabel: 'Add',
        ),
      ),
      body: FutureBuilder(
          future: _data,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData || snapshot.data.length == 0)
              return Center(
                child: RaisedButton(
                  child: const Text('New Item'),
                  onPressed: () => editToDo(),
                ),
              );
            _content = snapshot.data;
            return ListView.builder(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(6.0),
              itemCount: _content.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: ObjectKey(_content[index]['rowid']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (DismissDirection direction) {
                    _deletedRecs.add(_content[index]['rowid']);
                    final String action =
                        (direction == DismissDirection.endToStart)
                            ? 'deleted'
                            : 'archived';
                    _scaffoldKey.currentState?.showSnackBar(SnackBar(
                        content: Text('You $action an item.'),
                        action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              if (_deletedRecs
                                  .remove(_content[index]['rowid'])) {
                                refresh();
                              }
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
                        border: Border(
                            bottom: BorderSide(color: _theme.dividerColor))),
                    child: ListTile(
//                          leading: Icon(Icons.remove),
                      leading: Icon(IconData(
                          int.tryParse(_content[index]['Icon']),
                          fontFamily: 'MaterialIcons')),
                      title: Text(_content[index]['Item']),
                      subtitle: Text(_dateFormat.format(
                          DateTime.tryParse(_content[index]['DateTime']))),
                      onTap: () {
                        editToDo(_content[index]);
                      },
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  @override
  void dispose() {
    /// List items widget
    _deleteToDo();
  }

  void editToDo([Map todo]) async {
    Route route = MaterialPageRoute<Map<String, dynamic>>(
      settings: RouteSettings(name: "/todos/todo"),
      builder: (BuildContext context) => TodoPage(todo: todo),
      fullscreenDialog: true,
    );

    await Navigator.of(this.state.context).push(route);

    refresh();
  }

  void _deleteToDo() {
    if (!mounted) return;

    for (int id in _deletedRecs) {
      _deletedRecs.remove(id);
      for (var item in _content) {
        if (item['rowid'] == id) {
          _content.remove(item);
          Controller.delete(item);
          break;
        }
      }
    }
  }
}

//Container(
//alignment: FractionalOffset.center,
//margin: EdgeInsets.only(bottom: 6.0),
//padding: EdgeInsets.all(6.0),
//color: Colors.blueGrey,
//child: Text('${content[index]['Item']}'),
//);
