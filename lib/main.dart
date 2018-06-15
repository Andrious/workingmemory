import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import 'src/App.dart';
import 'src/model.dart';
import 'src/appprefs.dart';
import 'src/loadingscreen.dart';
import 'package:flutter/material.dart';

import 'src/auth/auth.dart';
import 'src/FireBase.dart';

Auth _auth;

FireBase _fireBase;

void main() {

  _auth = Auth();

  _fireBase = FireBase();

  /// The default is to dump the error to the console.
  /// Instead, a custom function is called.
  FlutterError.onError = (FlutterErrorDetails details) async {
    await _reportError(details);
  };

//  runApp(MyApp());


  // https://stackoverflow.com/questions/44379849/display-app-theme-immediately-in-flutter-app
  runApp(new FutureBuilder(
    future: App.init(),
    builder: (_, snapshot) {
      return snapshot.hasData ?
      MyApp() :
      LoadingScreen();
    },
  ));
}


/// Root MaterialApp
class MyApp extends StatefulWidget {

  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DatabaseReference _tasksRef;

  @override
  void initState() {
    super.initState();
    FireBase.dataRef('tasks');
  }

  @override
  Widget build(BuildContext context) {
    var _routes = <String, WidgetBuilder>{
      "/todos": (BuildContext context) => TodosPage(),
      // add another page,
    };

    return new MaterialApp(
      title: "My App",
      theme: AppPrefs.getThemeData(),
      home: HomePage(),
      routes: _routes,
    );
  }
}

/// place: "/"
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<String> _message = Future<String>.value('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Home Page")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            child: Text("My Todos"),
            onPressed: _onPressed,
          ),
          MaterialButton(
              child: const Text('Test signInAnonymously'),
              onPressed: () {
                setState(() {
                  _message = _auth?.signInAnonymously();
                });
              }),
          MaterialButton(
              child: const Text('Test signInWithGoogle'),
              onPressed: () {
                setState(() {
                  _message = _auth?.signInWithGoogle();
                });
              }),
          Text('User id: ${setState((){_auth.user;})}'),
          FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return Text(snapshot.data ?? '',
                    style: const TextStyle(
                        color: const Color.fromARGB(255, 0, 155, 0)));
              }),
        ],
      ),
    );
  }

  void _onPressed() {
    Navigator.of(context).pushNamed("/todos");
  }
}


/// place: "/todos"
class TodosPage extends StatefulWidget {
  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Todos")),
      body: RefreshIndicator(
        child: ListView.builder(itemBuilder: _itemBuilder),
        onRefresh: _onRefresh,
      ),
    );
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = Completer<Null>();
    Timer timer = Timer(Duration(seconds: 3), () {
      completer.complete();
    });
    return completer.future;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Todo todo = getTodo(index);
    return TodoItemWidget(todo: todo);
  }

  Todo getTodo(int index) {
    return Todo(false, "Todo $index");
  }
}

class TodoItemWidget extends StatefulWidget {
  TodoItemWidget({Key key, this.todo}) : super(key: key);

  final Todo todo;

  @override
  _TodoItemWidgetState createState() => new _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("-"),
      title: Text(widget.todo.name),
      onTap: _onTap,
    );
  }

  void _onTap() {
    Route route = MaterialPageRoute(
      settings: RouteSettings(name: "/todos/todo"),
      builder: (BuildContext context) => TodoPage(todo: widget.todo),
    );
    Navigator.of(context).push(route);
  }
}

/// place: "/todos/todo"
class TodoPage extends StatefulWidget {
  TodoPage({Key key, this.todo}) : super(key: key);

  final Todo todo;

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  Widget build(BuildContext context) {
    var _children = <Widget>[
      Text("finished: " + widget.todo.finished.toString()),
      Text("name: " + widget.todo.name),
    ];
    return Scaffold(
      appBar: AppBar(title: new Text("My Todo")),
      body: Column(
        children: _children,
      ),
    );
  }
}


/// Reports [error] along with its [stackTrace]
Future<Null> _reportError(FlutterErrorDetails details) async {
  // details.exception, details.stack

  FlutterError.dumpErrorToConsole(details);
}


