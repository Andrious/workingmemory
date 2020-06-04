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
///          Created  25 Aug 2018
/// place: "/todos/todo"
///

import 'dart:async' show Future;

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:workingmemory/src/view.dart'
    show App, DTiOS, IconItems, StateMVC, TodoPage;

import 'package:workingmemory/src/controller.dart' show Controller, theme;

class TodoiOS extends StateMVC<TodoPage> {
  TodoiOS() : super(Controller()) {
    con = controller;
  }
  Controller con;

  @override
  void initState() {
    super.initState();
//    con.edit.addState(this);
    con.data.init(widget.todo);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: con.data.scaffoldKey,
      navigationBar: CupertinoNavigationBar(
          middle: con.data.title,
          trailing: CupertinoButton(
              child: Text(
                'Save',
              ),
              padding: EdgeInsets.all(
                  10), // https://github.com/flutter/flutter/issues/32701
              onPressed: () async {
                await con.data.onPressed();
                Navigator.pop(context);
              })),
      child: Form(
        key: con.data.formKey,
        onWillPop: _onWillPop,
        child: ListView(shrinkWrap: true,
//            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(25.0),
                padding: const EdgeInsets.only(bottom: 25.0),
                alignment: Alignment.bottomLeft,
                child: FormField<String>(
                  initialValue: con.data.changer.text,
                    validator: (v) {
                      if (v.trim().isEmpty) return 'Cannot be empty.';
                      return null;
                    },
                    onSaved: (value) {
                      con.data.item = value;
                    },
                  builder: (FormFieldState<String> field) {
                    return CupertinoTextField(
                      controller: con.data.changer,
                      autofocus: true,
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 2.0,
                        color: CupertinoColors.inactiveGray,
                      )),
                    );
                  },
                ),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                        child: Icon(IconData(int.tryParse(con.data.icon),
                            fontFamily: 'MaterialIcons'))),
//                    Text('From', style: theme.textTheme.caption),
                    DTiOS(
                      dateTime: con.data.dateTime,
                      onChanged: (DateTime value) {
                        setState(() {
                          con.data.dateTime = value;
                        });
                        con.data.saveNeeded = true;
                      },
                    )
                  ]),
              Container(
                  height: 600.0,
                  child: IconItems(
                      icon: con.data.icon,
                      onTap: (icon) {
                        setState(() {
                          con.data.icon = icon;
                        });
                      })),
            ]),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!con.data.hasChanged) return true;

    final TextStyle dialogTextStyle = theme.textTheme.subtitle1
        .copyWith(color: theme.textTheme.caption.color);

    bool willPop;

    if(App.useCupertino) {
      //
      willPop = await showGeneralDialog<bool>(
        context: context,
          barrierDismissible: true,
          barrierLabel: "label",
          barrierColor: const Color(0x80000000),
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
          return SafeArea(
            child: CupertinoAlertDialog(
              content: Text('Discard new event?', style: dialogTextStyle),
              actions: <Widget>[
                CupertinoButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                CupertinoButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          true); // Returning true to _onWillPop will pop again.
                    })
              ],
            ),
          );
        },
      ) ?? false;
    }else {
      //
      willPop = await showDialog<bool>(
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
    return willPop;
  }
}
