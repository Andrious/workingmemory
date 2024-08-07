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

import '/src/model.dart' hide Icon, Icons;

import '/src/view.dart';

import '/src/controller.dart';

///
class TodoAndroid extends StateX<TodoPage> {
  ///
  TodoAndroid() : super(controller: Controller()) {
    _con = controller as Controller;
  }
  late Controller _con;

  @override
  void initState() {
    super.initState();
//    con.edit.addState(this);
    _con.data.init(widget.todo);
    _offset = OffsetPrefs('SaveOffset');
  }

  late OffsetPrefs _offset;
  late BuildContext _scaffoldContext;

  // The iOS version
  @override
  Widget buildiOS(BuildContext context) => buildAndroid(context);

  // The Android version
  @override
  Widget buildAndroid(BuildContext context) {
    final _leftHanded = Settings.leftSidedPrefs();
    return Scaffold(
      appBar: _appBar(title: _con.data.title, leftHanded: _leftHanded),
      body: Form(
        child: _con.data.linkForm(
          ListView(
            padding: const EdgeInsets.all(16),
            children: _listWidgets(),
          ),
        ),
      ),
      floatingActionButton: saveButton,
      floatingActionButtonLocation: _leftHanded
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }

  ///
  Widget get saveButton => DraggableFab(
        onDragEnd: _offset.set,
        initPosition: _offset.get(),
        button: FloatingActionButton(
          onPressed: () async {
            final bool save = await _con.data.onPressed();
            if (save) {
              await _con.saveIcon(_con.data.icon);
              Navigator.of(_scaffoldContext, rootNavigator: true).pop();
            } else {
              ScaffoldMessenger.maybeOf(_scaffoldContext)?.showSnackBar(
                SnackBar(
                  content: Text('Not saved.'.tr),
                ),
              );
            }
          },
          child: const Icon(Icons.save),
        ),
      );

  Future<void> _onPopInvoked(bool didPop) async {
    //
    if (!_con.data.hasChanged) {
      return;
    }

    final TextStyle dialogTextStyle = theme!.textTheme.titleMedium!
        .copyWith(color: theme!.textTheme.bodySmall!.color);

    final pop = await showDialog<bool>(
          useRootNavigator: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard new event?'.tr, style: dialogTextStyle),
              actions: _listButtons(),
            );
          },
        ) ??
        false;

    if (pop) {
      await Navigator.maybePop(context);
    }
  }

  List<Widget> _listWidgets() {
    //
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
            if (v!.isEmpty) {
              return 'Cannot be empty.'.tr;
            }
            return null;
          },
          onSaved: (value) {
            _con.data.item = value!;
          },
        ),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Center(
          child: Icon(
            IconData(int.tryParse(_con.data.icon!)!,
                fontFamily: 'MaterialIcons'),
          ),
        ),
        DateTimeItem(
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

    final _favIcons = _con.favIcons!;

    if (_favIcons.isNotEmpty && _favIcons.first.isNotEmpty) {
      widgets.add(
        InkWell(
          onLongPress: _editFavIcons,
          child: Container(
            height: 10.h, //100,
            decoration: BoxDecoration(
              border: Border.all(width: 4),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: IconItems(
                icons: {
                  for (var e in _favIcons) e.values.first: e.values.first
                },
                icon: _con.data.icon!,
                onTap: (icon) {
                  setState(() {
                    _con.data.icon = icon;
                  });
                }),
          ),
        ),
      );
    }

    widgets.add(
      Builder(
        builder: (BuildContext context) {
          // So to access the Scaffold's state object.
          _scaffoldContext = context;
          return SizedBox(
            height: 60.h, //600,
            child: IconItems(
              icons: _con.icons,
              icon: _con.data.icon!,
              onTap: (icon) async {
//                await _con.saveIcon(icon);
                _con.pickedIcon(icon);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
    return widgets;
  }

  /// Determine the order of AppBar items
  AppBar _appBar({Widget? title, bool? leftHanded}) {
    leftHanded = leftHanded ?? false;

    final settingsButton = ElevatedButton(
      onPressed: () {
        LEDColor.show(
          context: context,
          color: Color(_con.data.notifyColor),
          onColorChanged: (Color color) => _con.data.notifyColor = color.value,
        );
      },
      child: const Icon(Icons.settings),
    );

    List<Widget>? actions;

    // Switch the buttons around when indicated.
    if (leftHanded) {
      if (title == null) {
        title = settingsButton;
      } else {
        title = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [settingsButton, title],
        );
      }
    } else {
      actions = [settingsButton];
    }
    return AppBar(
      title: title,
      actions: actions,
    );
  }

  List<Widget> _listButtons() {
    Widget leading;
    Widget trailing;
    Widget temp;

    leading = ElevatedButton(
      onPressed: () {
        Navigator.of(context)
            .pop(false); // Pops the confirmation dialog but not the page.
      },
      child: L10n.t('Cancel'),
    );

    trailing = ElevatedButton(
      onPressed: () {
        Navigator.of(context)
            .pop(true); // Returning true to _onWillPop will pop again.
      },
      child: L10n.t('Discard'),
    );

    // Switch the buttons around when indicated.
    if (Settings.leftSidedPrefs()) {
      temp = leading;
      leading = trailing;
      trailing = temp;
    }
    return [leading, trailing];
  }

  // Open a screen for you to manage your favourite icons.
  Future<void> _editFavIcons() async {
    //
    final Route<Map<String, dynamic>> route = MaterialPageRoute(
      settings: const RouteSettings(name: '/todo/favs'),
      builder: (BuildContext context) => const FavIcons(),
      fullscreenDialog: true,
    );
    await Navigator.of(context).push(route);
    // Refresh the previous screen
    setState(() {});
  }
}

///
enum DismissDialogAction {
  ///
  cancel,

  ///
  discard,

  ///
  save,
}
