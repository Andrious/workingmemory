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

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' show Controller, theme;

class TodoiOS extends StateMVC<TodoPage> {
  //
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

  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          middle: con.data.title,
          trailing: CupertinoButton(
              child: Text(
                'Save',
              ),
              padding: EdgeInsets.all(
                  10), // https://github.com/flutter/flutter/issues/32701
              onPressed: () async {
                bool saved = await con.data.onPressed();
                if (!saved) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(con.data.errorText),
                  ));
                } else {
                  if (widget.onPressed == null) {
                    Navigator.pop(context);
                  } else {
                    widget.onPressed();
                  }
                }
              })),
      child: Form(
          onWillPop: _onWillPop,
          child: con.data.linkForm(
            ListView(
//          shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                children: _listWidgets),
          )),
    );
  }

  Future<bool> _onWillPop() async {
    if (!con.data.hasChanged) return true;

    final TextStyle dialogTextStyle = theme.textTheme.subtitle1
        .copyWith(color: theme.textTheme.caption.color);

    bool willPop;

    if (App.useCupertino) {
      //
      willPop = await showGeneralDialog<bool>(
            context: context,
            barrierDismissible: true,
            barrierLabel: "label",
            barrierColor: const Color(0x80000000),
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (BuildContext buildContext,
                Animation<double> animation,
                Animation<double> secondaryAnimation) {
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
          ) ??
          false;
    } else {
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

  List<Widget> get _listWidgets {
    var widgets = <Widget>[
      Container(
        margin: const EdgeInsets.all(25.0),
        padding: const EdgeInsets.only(top: 25.0),
        alignment: Alignment.bottomLeft,
        child: FormField<String>(
            initialValue: con.data.item,
            validator: (v) {
              if (v.trim().isEmpty) return 'Cannot be empty.';
              return null;
            },
            builder: (FormFieldState<String> field) {
              // Retain a copy of the FormFieldState object.
              con.data.addField(field);
              return CupertinoTextField(
                textInputAction: TextInputAction.done,
                controller: con.data.controller,
                onChanged: (value) {
                  field.didChange(value);
                },
                onSubmitted: (value) {
                  field.didChange(value);
                },
                autofocus: true,
              );
            }),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start,
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    ];

    if (con.favIcons.length > 0) {
      widgets.add(Container(
          height: 100.0,
          decoration: BoxDecoration(
            border: Border.all(width: 4, color: Colors.black),
            borderRadius: const BorderRadius.all(const Radius.circular(8)),
          ),
          child: IconItems(
              icons: Map.fromIterable(con.favIcons,
                  key: (e) => e.values.first, value: (e) => e.values.first),
              icon: con.data.icon,
              onTap: (icon) {
                con.setState(() {
                  con.data.icon = icon;
                });
              })));
    }

    widgets.add(Container(
        height: 600.0,
        child: IconItems(
            icons: con.icons,
            icon: con.data.icon,
            onTap: (icon) async {
              await con.saveIcon(icon);
              con.setState(() {});
            })));

    return widgets;
  }
}
