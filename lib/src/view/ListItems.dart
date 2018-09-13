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
///          Created  22 Aug 2018
///
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:mvc/App.dart';

import 'package:workingmemory/src/view/TodosPage.dart';

class ListItems{

  static Widget body(TodosPage state){

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    Future<List<Map>> _data;

    final dateFormat = new DateFormat('EEEE, MMM dd  h:mm a');

    final ThemeData theme = App.theme;

    return FutureBuilder(
        future: _data,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData || snapshot.data.length == 0)
            return Center(
              child: RaisedButton(
                onPressed: () => state.editToDo(),
                child: const Text('New Item'),
              ),
            );
          List content = snapshot.data;
          return ListView.builder(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(6.0),
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: ObjectKey(content[index]['Item']),
                direction: DismissDirection.endToStart,
                onDismissed: (DismissDirection direction) {
                  state.setState(() {
//                          leaveBehindItems.remove(item);
                  });
                  final String action = (direction == DismissDirection.endToStart) ? 'archived' : 'deleted';
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('You $action item ${content[index]['Item']}'),
                      action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            // handleUndo(item);
                          }
                      )
                  ));
                },
                background: Container(
                    color: Colors.red,
                    child: const ListTile(
                        trailing: const Icon(Icons.delete, color: Colors.white, size: 36.0)
                    )
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: theme.canvasColor,
                      border: Border(bottom: BorderSide(color: theme.dividerColor))
                  ),
                  child: ListTile(
                    leading: Icon(IconData(0xeb3b, fontFamily: 'MaterialIcons')),
                    title: Text('${content[index]['Item']}'),
                    subtitle: Text(dateFormat.format(DateTime.tryParse(content[index]['DateTime']))),
                    onTap:() {
                      state.editToDo(content[index]);
                    },
                  ),
                ),
              );
            },
          );
        }
    );
  }
}