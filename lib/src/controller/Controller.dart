///
/// Copyright (C) 2018 Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  23 Jun 2018
///

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mvc/App.dart';

import 'package:workingmemory/src/model/Model.dart';

import 'package:auth/Auth.dart';


class Controller extends AppController{

  var model = Model();


  @override
  Future<bool> init() async{
    var login = await Auth.logInWithGoogle(
         listen:(account){setState((){});}
      );

    model.init();
    return login;
  }

  get user => Auth.uid;

  get email => Auth.email;

  get name => Auth.displayName;

  get provider => Auth.providerId;

  get isAnonymous => Auth.isAnonymous;

  get photo => Auth.photoUrl;

  get token => Auth.accessToken;

  get tokenId => Auth.idToken;



  @override
  void initState() {
    super.initState();
  }


  
  @override
  void dispose(){
    model.dispose();
    super.dispose();
  }



  Future<String> signInAnonymously() async {
    await Auth.signInAnonymously();
    return Auth.uid;
  }



  Future<String> signInWithGoogle() async{
    await Auth.signIn();
    return Auth.uid;
  }
}







class TodoItemWidget extends StatefulWidget {
  TodoItemWidget({Key key, this.todo}) : super(key: key);

  final ToDo todo;

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

  final ToDo todo;

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