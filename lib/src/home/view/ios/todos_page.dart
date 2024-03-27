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
///          Created  01 Mar 2020

/// place: "/todos"
import 'package:workingmemory/src/controller.dart' show Controller;

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart';

///
class TodosiOS extends StateX<TodosPage> {
  ///
  TodosiOS() : super(controller: Controller()) {
    con = controller as Controller;
  }

  ///
  late Controller con;

  late Widget _leading;
  late Widget _trailing;

  // The iOS version
  @override
  Widget buildiOS(BuildContext context) => buildAndroid(context);

  @override
  Widget buildAndroid(BuildContext context) {
    // Supply the leading and trailing buttons.
    _supplyButtons();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: _leading,
        trailing: _trailing,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: MemoryList(parent: this)),
          ],
        ),
      ),
    );
  }

  ///
  Future<void> editToDo(BuildContext context,
      [Map<String, dynamic>? todo]) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => TodoPage(todo: todo),
    );
    setState(() {});
  }

  void _supplyButtons() {
    //
    _leading = CupertinoButton(
      padding: const EdgeInsets.all(12),
      onPressed: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => const SettingsWidget(),
        );
        setState(() {});
      },
      child: L10n.t('Settings'),
    );

    _trailing = CupertinoButton(
      padding: const EdgeInsets.all(12),
      onPressed: () {
        editToDo(con.state!.context);
      },
      child: L10n.t('New'),
    );

    if (Settings.leftSided) {
      final temp = _leading;
      _leading = _trailing;
      _trailing = temp;
    }
  }
}

///
class MemoryList extends StatelessWidget {
  ///
  const MemoryList({required this.parent, super.key});

  ///
  final TodosiOS parent;

  @override
  Widget build(BuildContext context) {
    //
    final List<Map<String, dynamic>> _items = parent.con.data.items;
    final bool itemsEmpty = parent.con.data.items.isEmpty;
    final bool leftSided = Settings.leftSidedPrefs();

    Widget? leading;
    Widget? trailing;
    final Widget sortArrow = Material(child: parent.widget.sortArrow);
    if (leftSided) {
      leading = sortArrow;
    } else {
      trailing = sortArrow;
    }

    return SafeArea(
      child: CustomScrollView(
//              shrinkWrap: true,
        semanticChildCount: _items.length,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Working Memory'.tr),
            leading: leading,
            trailing: trailing,
          ),
          if (itemsEmpty) const SizedBox(),
          if (!itemsEmpty)
            SliverSafeArea(
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _items.length) {
                      return null;
                    }
                    return Dismissible(
                      key: ObjectKey(_items[index]['rowid']),
                      direction: leftSided
                          ? DismissDirection.startToEnd
                          : DismissDirection.endToStart,
                      onDismissed: (DismissDirection direction) {
                        Controller().data.delete(_items[index]);
                        final String action =
                            (direction == DismissDirection.endToStart)
                                ? 'deleted'.tr
                                : 'archived'.tr;
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          SnackBar(
                            content: Text('You $action an item.'.tr),
                            action: SnackBarAction(
                              label: 'UNDO'.tr,
                              onPressed: () {
                                Controller().data.undo(_items[index]);
                              },
                            ),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        child: const Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            leading: Icon(Icons.delete,
                                color: Colors.white, size: 36),
                            trailing: Icon(Icons.delete,
                                color: Colors.white, size: 36),
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: App.themeData!.dividerColor),
                          ),
                        ),
                        child: Material(
                          //  type: MaterialType.transparency,
                          child: ListTile(
                            leading: Icon(IconData(
                                int.tryParse(_items[index]['Icon'])!,
                                fontFamily: 'MaterialIcons')),
                            title: Text(_items[index]['Item']),
                            subtitle: Text(
                              parent.con.data.dateFormat.format(
                                  DateTime.tryParse(
                                      _items[index]['DateTime'])!),
                            ),
                            onTap: () =>
                                parent.editToDo(context, _items[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
