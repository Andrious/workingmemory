///
/// Copyright (C) 2019 Andrious Solutions
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
///          Created  16 Aug 2019
///
///

import 'package:flutter/material.dart';

import 'package:workingmemory/src/view.dart' show Menu;

import 'package:workingmemory/src/controller.dart' show Controller;

class WorkMenu extends Menu{
  WorkMenu():super(){
    _con = Controller();
  }
  Controller _con;

  @override
  List<PopupMenuItem<dynamic>> menuItems() => [
    PopupMenuItem(value: "Resync", child: Text("Resync")),
  ];

  @override
  List<PopupMenuItem<dynamic>> tailItems = [
    PopupMenuItem(value: "Logout", child: Text("Logout")),
  ];

  @override
  void onSelected(dynamic menuItem){
    switch (menuItem) {
      case 'Resync':
        _con.reSync();
        break;
      case 'Logout':
        _con.logOut();
        break;
      default:
    }
  }
}

