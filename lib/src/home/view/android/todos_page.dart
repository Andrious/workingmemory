import 'package:workingmemory/src/controller.dart' show App, Controller;

import 'package:workingmemory/src/model.dart' hide Icon, Icons;

import 'package:workingmemory/src/view.dart';

/// MVC design pattern is the 'View' -- the build() in this State object.
class TodosAndroid extends StateX<TodosPage> {
  ///
  TodosAndroid() : super(Controller()) {
    _con = controller as Controller;
  }

  late Controller _con;

  @override
  Widget build(BuildContext context) {
    final _editObj = _con.data;
    final _items = _editObj.items;
    final _leftHanded = Settings.isLeftHanded();
    final offset = OffsetPrefs('AddOffset');
    return Scaffold(
      drawer: Drawer(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SettingsWidget(),
      ),
      appBar:
          _appBar(title: Text('Working Memory'.tr), leftHanded: _leftHanded),
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
      floatingActionButtonLocation: _leftHanded
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: _items.isEmpty || _items[0].isEmpty
            ? const SizedBox()
            : Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  const ScreenCircularProgressIndicator(),
                  ListView.builder(
                    padding: const EdgeInsets.all(6),
                    itemCount: _items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final icon = Icon(
                        IconData(int.tryParse(_items[index]['Icon'])!,
                            fontFamily: 'MaterialIcons'),
                      );
                      Widget? leading;
                      Widget? trailing;
                      if (_leftHanded) {
                        trailing = icon;
                      } else {
                        leading = icon;
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
                            leading: Icon(Icons.delete,
                                color: Colors.white, size: 36),
                            trailing: Icon(Icons.delete,
                                color: Colors.white, size: 36),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: App.themeData!.dividerColor),
                            ),
                          ),
                          child: ListTile(
                            leading: leading,
                            title: Align(
                              alignment: _leftHanded
                                  ? Alignment.center
                                  : Alignment.centerLeft,
                              child: Text(_items[index]['Item']),
                            ),
                            subtitle: Align(
                              alignment: _leftHanded
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(
                                _editObj.dateFormat.format(DateTime.tryParse(
                                    _items[index]['DateTime'])!),
                              ),
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
                ],
              ),
      ),
    );
  }

  /// Determine the order of AppBar items
  AppBar _appBar({Widget? title, bool? leftHanded}) {
    //
    leftHanded = leftHanded ?? false;

    final settingsButton = WorkMenu().popupMenuButton;

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

  ///
  Future<void> editToDo([Map<String, dynamic>? todo]) async {
    final Route<Map<String, dynamic>> route = MaterialPageRoute(
      settings: const RouteSettings(name: '/todos/todo'),
      builder: (BuildContext context) => TodoPage(todo: todo),
      fullscreenDialog: true,
    );
    await Navigator.of(context).push(route);
    // Refresh the previous screen
    setState(() {});
  }

  // A custom error routine if you want.
  @override
  void onError(FlutterErrorDetails details) {
    super.onError(details);
  }
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
