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
///          Created  22 Aug 2018
import 'dart:async' show Future;

import 'package:flutter/material.dart'
    show
        AppBar,
        AsyncSnapshot,
        Color,
        Column,
        CrossAxisAlignment,
        FutureBuilder,
        Navigator,
        RaisedButton,
        Scaffold,
        Text,
        TextStyle,
        Widget;

import 'package:workingmemory/src/controller.dart'
    show AppDrawer, WorkingController;

import 'package:mvc_application/view.dart' show AppView;

class LoginInfo {
  final WorkingController con = WorkingController();

  Widget scaffold(AppView _vw) {
    return Scaffold(
        appBar: AppBar(title: const Text('My Home Page')),
        endDrawer: const AppDrawer(),
        body: body(_vw));
  }

  Widget body(AppView _vw) {
    Future<String> _uid = Future.value(con.uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            Navigator.of(_vw.context).pushNamed('/todos');
          },
          child: const Text('My Todos'),
        ),
        RaisedButton(
          onPressed: () {
            _vw.setState(() {
              _uid = con.signInSilently().then((log) {
                return con.uid;
              });
            });
          },
          child: const Text('Test signInSilently'),
        ),
        RaisedButton(
          onPressed: () {
            _vw.setState(() {
              _uid = con.signInWithGoogle().then((log) {
                return con.uid;
              });
            });
          },
          child: const Text('Test signInWithGoogle'),
        ),
        Text('User id: ${con.uid}'),
        Text('User Name: ${con.name}'),
        Text('Anonymous: ${con.isAnonymous}'),
        Text('Email:     ${con.email}'),
        Text('Provider:  ${con.provider}'),
        Text('Photo:     ${con.photo}'),
//          Text('Token Id:  ${Controller.tokenId}'),
//          Text('AcessToken:${Controller.token}'),
        FutureBuilder<String>(
            future: _uid,
            builder: (_, AsyncSnapshot<String> snapshot) {
              return Text(snapshot.data ?? '',
                  style:
                      const TextStyle(color: Color.fromARGB(255, 0, 155, 0)));
            }),
      ],
    );
  }
}
