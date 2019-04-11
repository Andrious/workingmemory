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
import 'dart:async' show Future;

import 'package:flutter/material.dart' show AppBar, AsyncSnapshot, Color, Column, CrossAxisAlignment, FutureBuilder, Navigator, RaisedButton, Scaffold, Text, TextStyle, Widget;

import 'package:workingmemory/src/controller/controller.dart' show AppDrawer, WorkingMemoryApp;

import 'package:mxc_application/view.dart' show AppView;

class LoginInfo {
  static Widget scaffold(AppView _vw) {
    return Scaffold(
        appBar: AppBar(title: Text("My Home Page")),
        endDrawer: AppDrawer(),
        body: LoginInfo.body(_vw));
  }

  static Widget body(AppView _vw) {
    Future<String> _uid = Future.value(WorkingMemoryApp.uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RaisedButton(
          child: Text("My Todos"),
          onPressed: () {
            Navigator.of(_vw.context).pushNamed("/todos");
          },
        ),
        RaisedButton(
            child: const Text('Test signIn'),
            onPressed: () {
              _vw.setState(() {
                _uid = WorkingMemoryApp.signIn().then((log){
                  return WorkingMemoryApp.uid;
                });
              });
            }),
        RaisedButton(
            child: const Text('Test signInAnonymously'),
            onPressed: () {
              _vw.setState(() {
                _uid = WorkingMemoryApp.signInAnonymously().then((log){
                  return WorkingMemoryApp.uid;
                });
              });
            }),
        RaisedButton(
            child: const Text('Test signInWithGoogle'),
            onPressed: () {
              _vw.setState(() {
                _uid = WorkingMemoryApp.signInWithGoogle().then((log){
                  return WorkingMemoryApp.uid;
                });
              });
            }),
    Text('User id: ${WorkingMemoryApp.uid}'),
    Text('User Name: ${WorkingMemoryApp.name}'),
    Text('Anonymous: ${WorkingMemoryApp.isAnonymous}'),
    Text('Email:     ${WorkingMemoryApp.email}'),
    Text('Provider:  ${WorkingMemoryApp.provider}'),
    Text('Photo:     ${WorkingMemoryApp.photo}'),
//          Text('Token Id:  ${Controller.tokenId}'),
//          Text('AcessToken:${Controller.token}'),
        FutureBuilder<String>(
            future: _uid,
            builder: (_, AsyncSnapshot<String> snapshot) {
              return Text(snapshot.data ?? '',
                  style: const TextStyle(
                      color: const Color.fromARGB(255, 0, 155, 0)));
            }),
      ],
    );
  }
}
