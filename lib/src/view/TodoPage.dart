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
///          Created  25 Aug 2018
/// place: "/todos/todo"
///

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mvc/App.dart';

import 'package:workingmemory/src/view/DateTimeItem.dart';

import 'package:workingmemory/src/controller/Controller.dart';

import 'package:workingmemory/src/view/IconItems.dart';

class TodoPage extends StatefulWidget {
  TodoPage({Key key, this.todo}) : super(key: key);

  final Map todo;

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  Map todo;
  DateTime fromDateTime;
  bool saveNeeded;
  bool hasName;
  String eventName;
  String icon;
  bool hasChanged;
  TextEditingController changer;

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  final formKey = new GlobalKey<FormState>();

  final ThemeData theme = App.theme;



  @override
  void initState() {
    super.initState();

    todo = widget?.todo;

    hasName = todo?.isNotEmpty ?? false;

    if(hasName) {

      eventName = todo['Item'];

      fromDateTime = DateTime.tryParse(todo['DateTime']);

      icon = todo['Icon'];
    }else{

      icon = Controller.defaultIcon;
    }

    changer = TextEditingController(text: eventName);

    fromDateTime = fromDateTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {

    hasChanged = false;

//    changer.addListener((){hasChanged = true;});

    return new Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          title: Text(hasName ? eventName : 'Event Name TBD'),
          actions: <Widget> [
            FlatButton(
                child: Text('SAVE', style: theme.textTheme.body1.copyWith(color: Colors.white)),
                onPressed: () {

//                  if (!this.formKey.currentState.validate()) return null;

                  formKey.currentState.save();

                  final todo = {'Item': eventName, 'DateTime': fromDateTime, 'Icon': icon};

                  Controller.saveRec(todo, this.todo);

//                  Map rec = Map();
//
//                  if(this.todo == null) {
//
//                    rec.addAll(todo);
//                  }else {
//
//                    rec.addAll(this.todo);
//
//                    rec.addEntries(todo.entries);
//                  }
//
//                  Controller.save(rec);

////                  Navigator.pop(context, {'action':DismissDialogAction.save,'todo':todo});
                  Navigator.pop(context);
                }
            )
          ]
      ),
      body: Form(
          key: formKey,
          onWillPop: _onWillPop,
          child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: TextFormField(
                        controller: changer,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: 'Event name',
                        ),
                        style: theme.textTheme.headline,
                        onSaved: (value) {
//                          setState(() {
//                            hasName = value.isNotEmpty;
//                            if (hasName) {
                              eventName = value;
//                            }
//                          });
                        }
                    )
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(child: Icon(IconData(int.tryParse(icon), fontFamily: 'MaterialIcons'))),
                      Text('From', style: theme.textTheme.caption),
                      DateTimeItem(
                          dateTime: fromDateTime,
                          onChanged: (DateTime value) {
                            setState(() {
                              fromDateTime = value;
                            });
                            saveNeeded = true;
                          }
                      )
                    ]
                ),
                Container(
                  height: 300.0,
                  child: IconItems(icon: icon, onTap:(icon){
                      setState((){this.icon = icon;});
                      })
                ),
              ]
//                  .map((Widget child) {
//                return Container(
////                    padding: const EdgeInsets.symmetric(vertical: 8.0),
//                    height: 100.0,
//                    child: child
//                );
//              }).toList()
          )
      ),
    );
  }

  @override
  void dispose(){
    /// Edit item widget
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    saveNeeded = hasChanged; // hasName || saveNeeded;
    if (!saveNeeded)
      return true;

//    final ThemeData theme = App.theme;
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              'Discard new event?',
              style: dialogTextStyle
          ),
          actions: <Widget>[
            FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(false); // Pops the confirmation dialog but not the page.
                }
            ),
            FlatButton(
                child: const Text('DISCARD'),
                onPressed: () {
                  Navigator.of(context).pop(true); // Returning true to _onWillPop will pop again.
                }
            )
          ],
        );
      },
    ) ?? false;
  }
}


enum DismissDialogAction {
  cancel,
  discard,
  save,
}



