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

import 'dart:async' show Future;

import 'package:flutter/material.dart'
    show
        AlertDialog,
        AppBar,
        BuildContext,
        Colors,
        FlatButton,
        Form,
        Key,
        Navigator,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        Widget,
        showDialog;

import 'package:mvc_application/view.dart' show StateMVC;

import 'package:workingmemory/src/controller/Todos.dart' show Controller, theme;

class TodoPage extends StatefulWidget {
  TodoPage({Key key, this.todo}) : super(key: key);

  final Map todo;

  @override
  State createState() => _TodoState();
}

class _TodoState extends StateMVC<TodoPage> {
  @override
  void initState() {
    super.initState();
    Controller.edit.addState(this);
    Controller.edit.init(widget.todo);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: Controller.edit.scaffoldKey,
      appBar: AppBar(title: Controller.edit.title, actions: [
        FlatButton(
            child: Text('SAVE',
                style: theme.textTheme.body1.copyWith(color: Colors.white)),
            onPressed: () {
              Controller.edit.onPressed();
              Navigator.pop(context);
            })
      ]),
      body: Form(
        key: Controller.edit.formKey,
        onWillPop: _onWillPop,
        child: Controller.edit.child,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!Controller.edit.hasChanged) return true;

    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard new event?', style: dialogTextStyle),
              actions: <Widget>[
                FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                FlatButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          true); // Returning true to _onWillPop will pop again.
                    })
              ],
            );
          },
        ) ??
        false;
  }
}

enum DismissDialogAction {
  cancel,
  discard,
  save,
}
