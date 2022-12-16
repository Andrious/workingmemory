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
///          Created  29 Aug 2018
///
//import 'dart:developer';

import 'package:workingmemory/src/view.dart';

///
class IconItems extends StatelessWidget {
  ///
  const IconItems(
      {Key? key, required this.icon, required this.onTap, required this.icons})
      : super(key: key);

  ///
  final String icon;

  ///
  final ValueChanged<String> onTap;

  ///
  final Map icons;

  @override
  Widget build(BuildContext context) {
    final icons = this.icons.keys;
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Column(
      children: <Widget>[
        Expanded(
          child: SafeArea(
            top: false,
            bottom: false,
            child: GridView.count(
              crossAxisCount: (orientation == Orientation.portrait) ? 10 : 20,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(4),
              childAspectRatio:
                  (orientation == Orientation.portrait) ? 1.0 : 1.2,
              children: icons.where((dynamic icon) {
                return IconData(int.tryParse(icon)!,
                            fontFamily: 'MaterialIcons')
                        .fontFamily !=
                    null;
              }).map((dynamic icon) {
                return GestureDetector(
                  onTap: () {
                    onTap(icon);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(IconData(int.tryParse(icon)!,
                        fontFamily: 'MaterialIcons')),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
