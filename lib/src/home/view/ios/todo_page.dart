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

import 'package:workingmemory/src/model.dart' hide Icon;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' show Controller, theme;

///
class TodoiOS extends StateX<TodoPage> {
  ///
  TodoiOS() : super(controller: Controller()) {
    _con = controller as Controller;
  }
  late Controller _con;
  Widget? _leading;
  Widget? _trailing;

  @override
  void initState() {
    super.initState();
//    con.edit.addState(this);
    _con.data.init(widget.todo);
  }

  // The iOS version
  @override
  Widget buildAndroid(BuildContext context) => buildiOS(context);

  @override
  Widget buildiOS(BuildContext context) {
    _scaffoldButtons();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          middle: _con.data.title, leading: _leading, trailing: _trailing),
      child: Form(
          onWillPop: _onWillPop,
          child: _con.data.linkForm(
            ListView(padding: const EdgeInsets.all(16), children: _listWidgets),
          )),
    );
  }

  Future<bool> _onWillPop() async {
    //
    if (!_con.data.hasChanged) {
      return true;
    }

    final TextStyle dialogTextStyle = theme!.textTheme.subtitle1!
        .copyWith(color: theme!.textTheme.caption!.color);

    bool willPop;

    if (App.useCupertino) {
      //
      willPop = await showGeneralDialog<bool>(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'label',
            pageBuilder: (BuildContext buildContext,
                Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return SafeArea(
                child: CupertinoAlertDialog(
                  content: Text(L10n.s('Discard new event?'),
                      style: dialogTextStyle),
                  actions: _listButtons(),
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
                content:
                    Text(L10n.s('Discard new event?'), style: dialogTextStyle),
                actions: _listButtons(),
              );
            },
          ) ??
          false;
    }
    return willPop;
  }

  List<Widget> get _listWidgets {
    final widgets = <Widget>[
      Container(
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.only(top: 25),
        alignment: Alignment.bottomLeft,
        child: FormField<String>(
            initialValue: _con.data.item,
            validator: (v) {
              if (v!.trim().isEmpty) {
                return L10n.s('Cannot be empty.');
              }
              return null;
            },
//            onSaved: (value) {
//              con.data.item = value;
//            },
            builder: (FormFieldState<String> field) {
              // Retain a copy of the FormFieldState object.
              _con.data.addField(field);
              return CupertinoTextField(
                textInputAction: TextInputAction.done,
                controller: _con.data.controller,
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
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
                child: Icon(IconData(int.tryParse(_con.data.icon!)!,
                    fontFamily: 'MaterialIcons'))),
//                    Text('From', style: theme.textTheme.caption),
            DTiOS(
              dateTime: _con.data.dateTime!,
              onChanged: (DateTime value) {
                setState(() {
                  _con.data.dateTime = value;
                });
                _con.data.saveNeeded = true;
              },
            )
          ]),
    ];

    if (_con.favIcons!.isNotEmpty) {
      widgets.add(
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 4),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: IconItems(
              icons: {
                for (var e in _con.favIcons!) e.values.first: e.values.first
              },
              icon: _con.data.icon!,
              onTap: (icon) {
                _con.setState(() {
                  _con.data.icon = icon;
                });
              }),
        ),
      );
    }

    widgets.add(
      Container(
        height: 600,
        child: IconItems(
            icons: _con.icons,
            icon: _con.data.icon!,
            onTap: (icon) async {
              await _con.saveIcon(icon);
              _con.setState(() {});
            }),
      ),
    );
    return widgets;
  }

  void _scaffoldButtons() {
    Widget? temp;
    _leading = null;
    _trailing = CupertinoButton(
      padding: const EdgeInsets.all(
          10), // https://github.com/flutter/flutter/issues/32701
      onPressed: () async {
        final bool saved = await _con.data.onPressed();
        if (saved) {
          if (widget.onPressed == null) {
            Navigator.pop(context);
          } else {
            widget.onPressed!();
          }
        }
      },
      child: L10n.t('Save'),
    );

    // Switch the buttons around when indicated.
    if (Settings.leftSidedPrefs()) {
      temp = _trailing;
      _trailing = null;
      _leading = temp;
    }
  }

  List<Widget> _listButtons() {
    Widget leading;
    Widget trailing;
    Widget temp;

    if (App.useCupertino) {
      leading = CupertinoButton(
        onPressed: () {
          Navigator.of(context)
              .pop(false); // Pops the confirmation dialog but not the page.
        },
        child: L10n.t('Cancel'),
      );

      trailing = CupertinoButton(
        onPressed: () {
          Navigator.of(context)
              .pop(true); // Returning true to _onWillPop will pop again.
        },
        child: L10n.t('Discard'),
      );
    } else {
      leading = TextButton(
        onPressed: () {
          Navigator.of(context)
              .pop(false); // Pops the confirmation dialog but not the page.
        },
        child: L10n.t('Cancel'),
      );

      trailing = TextButton(
        onPressed: () {
          Navigator.of(context)
              .pop(true); // Returning true to _onWillPop will pop again.
        },
        child: L10n.t('Discard'),
      );
    }

    // Switch the buttons around when indicated.
    if (Settings.leftSidedPrefs()) {
      temp = leading;
      leading = trailing;
      trailing = temp;
    }
    return [leading, trailing];
  }
}
