///
/// Copyright (C) 2019 Andrious Solutions
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
///          Created  16 Aug 2019
///
///

import 'package:flutter/material.dart';

import 'package:workingmemory/src/view.dart' show Menu, unawaited;

import 'package:workingmemory/src/controller.dart' show Controller;

class WorkMenu extends Menu {
  WorkMenu() : super() {
    _con = Controller();

    if (_con.app.loggedIn) {
      if (_con.app.isAnonymous) {
        tailItems = [
          const PopupMenuItem(value: 'SignIn', child: Text('Sign in...')),
        ];
      } else {
        tailItems = [
          const PopupMenuItem(value: 'Logout', child: Text('Logout')),
        ];
      }
    } else {
      tailItems = [
        const PopupMenuItem(value: 'SignIn', child: Text('Sign in...')),
      ];
    }
  }
  Controller _con;

  @override
  List<PopupMenuItem<dynamic>> menuItems() => [
        const PopupMenuItem(value: 'Resync', child: Text('Resync')),
      ];

  @override
  Future<void> onSelected(dynamic menuItem) async {
    switch (menuItem) {
      case 'Resync':
        _con.reSync();
        break;
      case 'Logout':
        _con.logOut();
        break;
      case 'SignIn':
        unawaited(_con.signIn());
        break;
      default:
    }
  }
}
