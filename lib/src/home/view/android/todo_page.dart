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
///

import 'dart:async' show Future;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' show Controller, theme;

class TodoAndroid extends StateMVC<TodoPage> {
  TodoAndroid() : super(Controller()) {
    _con = controller;
  }
  Controller _con;

  @override
  void initState() {
    super.initState();
//    con.edit.addState(this);
    _con.data.init(widget.todo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _con.data.title, actions: [
        FlatButton(
          onPressed: () async {
            final bool save = await _con.data.onPressed();
            if (save) {
              Navigator.of(context, rootNavigator: true).pop();
            } else {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text('There is an error.'),
              ));
            }
          },
          child: Text(
            'SAVE',
            style: theme.textTheme.bodyText2.copyWith(color: Colors.white),
          ),
        ),
      ]),
      body: Form(
        onWillPop: _onWillPop,
        child: _con.data.linkForm(ListView(
          padding: const EdgeInsets.all(16),
          children: _listWidgets(),
        )),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_con.data.hasChanged) {
      return true;
    }

    final TextStyle dialogTextStyle = theme.textTheme.subtitle1
        .copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard new event?', style: dialogTextStyle),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                        false); // Pops the confirmation dialog but not the page.
                  },
                  child: const Text('CANCEL'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                        true); // Returning true to _onWillPop will pop again.
                  },
                  child: const Text('DISCARD'),
                )
              ],
            );
          },
        ) ??
        false;
  }

  List<Widget> _listWidgets() {
    final widgets = <Widget>[
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.bottomLeft,
        child: TextFormField(
          controller: _con.data.controller,
          decoration: const InputDecoration(
            filled: true,
          ),
          validator: (v) {
            if (v.isEmpty) {
              return 'Cannot be empty.';
            }
            return null;
          },
          onSaved: (value) {
            _con.data.item = value;
          },
        ),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Center(
            child: Icon(IconData(int.tryParse(_con.data.icon),
                fontFamily: 'MaterialIcons'))),
        DateTimeItem(
          dateTime: _con.data.dateTime,
          onChanged: (DateTime value) {
            setState(() {
              _con.data.dateTime = value;
            });
            _con.data.saveNeeded = true;
          },
        )
      ]),
    ];

    if (_con.favIcons.isNotEmpty) {
      widgets.add(Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 4),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: IconItems(
              icons: {
                for (var e in _con.favIcons) e.values.first: e.values.first
              },
              icon: _con.data.icon,
              onTap: (icon) {
                setState(() {
                  _con.data.icon = icon;
                });
              })));
    }

    widgets.add(Container(
        height: 600,
        child: IconItems(
            icons: _con.icons,
            icon: _con.data.icon,
            onTap: (icon) async {
              await _con.saveIcon(icon);
              setState(() {});
            })));

    return widgets;
  }
}

enum DismissDialogAction {
  cancel,
  discard,
  save,
}
