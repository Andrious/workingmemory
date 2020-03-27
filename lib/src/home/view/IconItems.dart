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
///          Created  29 Aug 2018
///
//import 'dart:developer';

import 'package:flutter/material.dart';

//import 'package:mvc_application/view.dart' show SnappingListScrollPhysics;

import 'package:workingmemory/src/home/model/Icons.dart' as List;

class IconItems extends StatelessWidget {
  IconItems({Key key, @required this.icon, @required this.onTap}) : super(key: key);

  final String icon;
  final ValueChanged<String> onTap;

  final icons = List.Icons.code.keys;

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Column(
      children: <Widget>[
        Expanded(
          child: SafeArea(
            top: false,
            bottom: false,
            child: GridView.count(
              crossAxisCount: (orientation == Orientation.portrait) ? 10 : 20,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              physics: ClampingScrollPhysics(),
              padding: const EdgeInsets.all(4.0),
              childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.2,
              children: icons.where((dynamic icon){
                return IconData(int.tryParse(icon), fontFamily: 'MaterialIcons').fontFamily != null;
              }).map((dynamic icon) {
                return GestureDetector(
                    onTap: () {onTap(icon);},
                    child: Padding(padding: const EdgeInsets.all(2.0),
                      child: Icon(IconData(int.tryParse(icon), fontFamily: 'MaterialIcons')),),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

}
