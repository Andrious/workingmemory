import '/src/controller.dart' show App, Controller;

import '/src/model.dart' hide Icon, Icons;

import '/src/view.dart';

/// MVC design pattern is the 'View' -- the build() in this State object.
class TodosAndroid extends StateX<TodosPage> {
  ///
  TodosAndroid() : super(controller: Controller()) {
    _con = controller as Controller;
  }

  late Controller _con;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // The iOS version
  @override
  Widget buildiOS(BuildContext context) => buildAndroid(context);

  @override
  Widget buildAndroid(BuildContext context) {
    final _editObj = _con.data;
    final _items = _editObj.items;
    final _leftSided = Settings.leftSided;
    final _leadingIcon = Settings.leadingIcon;
    final offset = OffsetPrefs('AddOffset');

    // Define the drawer to be used
    Widget? drawer = Drawer(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SettingsWidget(),
    );

    // ignore: avoid_positional_boolean_parameters
    void drawerCallback(bool isOpened) {
      if (!isOpened) {
        // Save the order of items displayed
        Settings.setItemsOrderPrefs(Settings.itemsOrder);
        // Show the sort arrow indicator
        Settings.setBottomBarPrefs(Settings.showBottomBar);
        // Interface elements on the left side of the screen
        Settings.setLeftSidedPrefs(Settings.leftSided);
        // Use the of the endDrawer in the Scaffold widget
        Settings.setDrawerPrefs(Settings.leadingDrawer);
        // Whether items are listed with a leading or trailing icon
        Settings.setLeadingIconPrefs(Settings.leadingIcon);
      }
    }

    Widget? endDrawer;
    // Position the drawer to the other side.
    if (!Settings.leadingDrawer) {
      endDrawer = drawer;
      drawer = null;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: _appBar(title: Text('Working Memory'.tr), leftSided: _leftSided),
      drawer: drawer,
      onDrawerChanged: drawerCallback,
      endDrawer: endDrawer,
      onEndDrawerChanged: drawerCallback,
      floatingActionButton: DraggableFab(
        onDragEnd: offset.set,
        initPosition: offset.get(),
        button: FloatingActionButton(
          onPressed: editToDo,
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
      body: SafeArea(
        child: _items.isEmpty || _items[0].isEmpty
            ? const SizedBox()
            : ListView.builder(
                padding: const EdgeInsets.all(6),
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  final icon = Icon(
                    IconData(int.tryParse(_items[index]['Icon'])!,
                        fontFamily: 'MaterialIcons'),
                  );
                  Widget? leading;
                  Widget? trailing;
                  if (_leadingIcon) {
                    leading = icon;
                  } else {
                    trailing = icon;
                  }
                  return Dismissible(
                    key: ObjectKey(_items[index]['rowid']),
                    onDismissed: (DismissDirection direction) {
                      _editObj.delete(_items[index]);
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        SnackBar(
                          content: Text('You deleted an item.'.tr),
                          action: SnackBarAction(
                              label: 'UNDO'.tr,
                              onPressed: () {
                                _editObj.undo(_items[index]);
                              }),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      child: const ListTile(
                        leading:
                            Icon(Icons.delete, color: Colors.white, size: 36),
                        trailing:
                            Icon(Icons.delete, color: Colors.white, size: 36),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: App.themeData!.dividerColor),
                        ),
                      ),
                      child: ListTile(
                        leading: leading,
                        title: Text(_items[index]['Item']),
                        subtitle: Text(
                          _editObj.dateFormat.format(
                              DateTime.tryParse(_items[index]['DateTime'])!),
                        ),
                        trailing: trailing,
                        onTap: () {
                          editToDo(_items[index]);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// Determine the order of AppBar items
  AppBar _appBar({Widget? title, bool? leftSided}) {
    //
    leftSided = leftSided ?? false;

    final settingsButton = WorkMenu();

    List<Widget>? actions;

    // Switch the buttons around when indicated.
    if (leftSided) {
      if (title == null) {
        title = settingsButton;
      } else {
        title = Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [settingsButton, const SizedBox(width: 10), title],
        );
      }
    } else {
      actions = [
        if (Settings.showBottomBar) widget.sortArrow,
        settingsButton,
      ];
    }

    if (!Settings.leadingDrawer) {
      if (actions != null) {
        actions.add(
          IconButton(
              icon: const Icon(Icons.menu), //color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              }),
        );
      }
    }

    return AppBar(
      title: title,
      actions: actions,
    );
  }

  ///
  Future<void> editToDo([Map<String, dynamic>? todo]) async {
    final Route<Map<String, dynamic>> route = MaterialPageRoute(
      settings: const RouteSettings(name: '/todos/todo'),
      builder: (BuildContext context) => TodoPage(todo: todo),
      fullscreenDialog: true,
    );
    await Navigator.of(context, rootNavigator: true).push(route);
    // Refresh the previous screen
    setState(() {});
  }
}

/// The 'sort' icon displayed to order the items displayed.
class SortItems extends Tab {
  ///
  const SortItems({super.key});
}

/// Deals with the Add Button's offset
class OffsetPrefs {
  /// Must supply a Preference key
  OffsetPrefs(String? key) {
    if (key != null && key.isEmpty) {
      _prefKey = null;
    } else {
      _prefKey = key;
    }
  }
  String? _prefKey;

  ///
  Offset? get() {
    Offset? position;
    final offset = Prefs.getStringList(_prefKey);
    if (offset.isNotEmpty && offset[0].isNum) {
      position = Offset(double.parse(offset[0]), double.parse(offset[1]));
    }
    return position;
  }

  ///
  void set(DraggableDetails details) {
    final offset = <String>['${details.offset.dx}', '${details.offset.dy}'];
    Prefs.setStringList(_prefKey, offset);
  }
}
