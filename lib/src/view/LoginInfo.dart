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
///          Created  22 Aug 2018
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mvc/App.dart';

import 'package:workingmemory/src/controller/Controller.dart';


class LoginInfo {

  static Widget scaffold(Controller _con){
    return Scaffold(
    appBar: AppBar(title: Text("My Home Page")),
    endDrawer: AppDrawer(),
    body: LoginInfo.body(_con));
  }

  static Widget body(Controller _con) {

    Future<String> _message = Future<String>.value('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RaisedButton(
          child: Text("My Todos"),
          onPressed:(){Navigator.of(_con.context).pushNamed("/todos");},
        ),
        MaterialButton(
            child: const Text('Test signInAnonymously'),
            onPressed: () {
              _con.setState(() {
                _message = Controller.signInAnonymously();
              });
            }),
        MaterialButton(
            child: const Text('Test signInWithGoogle'),
            onPressed: () {
              _con.setState(() {
                _message = Controller.signInWithGoogle();
              });
            }),
        Text('User id: ${Controller.uid}'),
        Text('User Name: ${Controller.name}'),
        Text('Anonymous: ${Controller.isAnonymous}'),
        Text('Email:     ${Controller.email}'),
        Text('Provider:  ${Controller.provider}'),
        Text('Photo:     ${Controller.photo}'),
//          Text('Token Id:  ${Controller.tokenId}'),
//          Text('AcessToken:${Controller.token}'),
        FutureBuilder<String>(
            future: _message,
            builder: (_, AsyncSnapshot<String> snapshot) {
              return Text(snapshot.data ?? '',
                  style: const TextStyle(
                      color: const Color.fromARGB(255, 0, 155, 0)));
            }),
      ],
    );
  }
}
