import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' show App, Controller;

/// MVC design pattern is the 'View' -- the build() in this State object.
class TodosAndroid extends StateX<TodosPage> {
  ///
  TodosAndroid() : super(Controller()) {
    _con = controller as Controller;
  }
  late Controller _con;
  late WorkMenu _menu;

  @override
  Widget build(BuildContext context) {
    // Rebuilt the menu if state changes.
    _menu = WorkMenu();
    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: Text('Working Memory'.tr),
        actions: [
          _menu.show(this),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: editToDo,
        child: const Icon(
          Icons.add,
        ),
      ),
      body: SafeArea(
        child: _con.data.items.isEmpty
            ? Container()
            : ListView.builder(
                padding: const EdgeInsets.all(6),
                itemCount: _con.data.items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: ObjectKey(_con.data.items[index]['rowid']),
                    onDismissed: (DismissDirection direction) {
                      _con.data.delete(_con.data.items[index]);
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        SnackBar(
                          content: Text('You deleted an item.'.tr),
                          action: SnackBarAction(
                              label: 'UNDO'.tr,
                              onPressed: () {
                                _con.data.undo(_con.data.items[index]);
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
                                color: Colors.white, size: 36))),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: App.themeData!.dividerColor))),
                      child: ListTile(
                        leading: Icon(IconData(
                            int.tryParse(_con.data.items[index]['Icon'])!,
                            fontFamily: 'MaterialIcons')),
                        title: Text(_con.data.items[index]['Item']),
                        subtitle: Text(_con.data.dateFormat.format(
                            DateTime.tryParse(
                                _con.data.items[index]['DateTime'])!)),
                        onTap: () => editToDo(_con.data.items[index]),
                      ),
                    ),
                  );
                },
              ),
      ),
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
    setState(() {});
  }

  // A custom error routine if you want.
  @override
  void onError(FlutterErrorDetails details) {
    super.onError(details);
  }
}
