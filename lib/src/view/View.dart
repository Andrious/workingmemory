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

import 'package:workingmemory/src/controller/Controller.dart';

import 'package:workingmemory/src/view/TodosPage.dart';


class View extends AppView{

  View(): super(_con);
  static final Controller _con = Controller();

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
                  _message = _con.signInAnonymously();
                });
              }),
          MaterialButton(
              child: const Text('Test signInWithGoogle'),
              onPressed: () {
                setState(() {
                  _message = _con.signInWithGoogle();
                });
              }),
          Text('User id: ${_con.user}'), //${setState((){_con.user;})}'),
          Text('User Name: ${_con.name}'),
          Text('Anonymous: ${_con.isAnonymous}'),
          Text('Email:     ${_con.email}'),
          Text('Provider:  ${_con.provider}'),
          Text('Photo:     ${_con.photo}'),
//          Text('Token Id:  ${_con.tokenId}'),
//          Text('AcessToken:${_con.token}'),
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