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
///          Created  16 Jun 2018

import 'package:workingmemory/src/controller.dart' show Controller;

import 'package:workingmemory/src/model.dart' hide Icon, Icons;

import 'package:workingmemory/src/view.dart';

///
class TodosPage extends StatefulWidget {
  ///
  const TodosPage({Key? key}) : super(key: key);
  @override
  // ignore: no_logic_in_create_state
  State createState() => App.useMaterial ? TodosAndroid() : TodosiOS();

  ///
  PreferredSizeWidget? get sortArrow {
    //
    if (!Settings.showBottomBar) {
      PreferredSizeWidget? bottomBar;
      return bottomBar;
    }

    IconData icon;
    String orderBy = Settings.itemsOrder;
    if (orderBy == 'descending') {
      icon = Icons.south;
    } else {
      icon = Icons.north;
    }

    final leftSided = Settings.leftSided;

    return PreferredSize(
      preferredSize: const Size(75, 75),
      child: Row(
          mainAxisAlignment:
              leftSided ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (leftSided) const SizedBox(width: 10),
            SizedBox(
              width: 50,
              height: 60,
              child: InkWell(
                onTap: () {
                  orderBy = orderBy == 'ascending' ? 'descending' : 'ascending';
                  Settings.itemsOrder = orderBy;
                  final _con = Controller();
                  _con.requery();
                  _con.setState(() {});
                },
                child: Icon(
                  icon,
                  size: App.useCupertino ? 22 : null,
                  color: App.useCupertino ? null : Colors.white,
                ),
              ),
            ),
            if (!leftSided) const SizedBox(width: 10),
          ]),
    );
  }
}
