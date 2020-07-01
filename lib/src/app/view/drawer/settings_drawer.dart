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
///          Created  10 Sep 2018
///

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart';

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  void initState() {
    super.initState();
    _descending = Settings.getOrder();
    _leftHanded = Settings.getLeftHanded();
    _con = Controller();
  }

  bool _descending;
  bool _leftHanded;
  Controller _con;
  bool _refresh;

  void dispose() {
    super.dispose();
    if (_refresh == true) _con.requery();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Drawer(
      child: ListView(
//      mainAxisAlignment: MainAxisAlignment.start,
//      mainAxisSize: MainAxisSize.min,
//      crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text("INTERFACE PREFERENCES"),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Sorted Order of Items",
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                        child: const Text(
                          "Check so the items are in descending order with the most recent items listed first.",
                        ),
                      ),
                      Checkbox(
                        key: null,
                        value: _descending,
                        onChanged: orderItems,
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: const Text(
                          "Switch around dialog buttons",
                        ),
                      ),
                      Checkbox(
                        key: null,
                        value: _leftHanded,
                        onChanged: switchButton,
                      ),
                    ]),
              ]),
            ),
            Card(
              child: InkWell(
                  onTap: () {},
                  child: Column(children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "NOTIFICATION PREFERENCES",
                          ),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Notification Settings",
                          ),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                            child: const Text(
                              "Notification behaviour, popup settings and LED Colour",
                              softWrap: true,
                            ),
                          ),
                        ]),
                  ])),
            ),
            Card(
              child: InkWell(
                  onTap: () {},
                  child: Column(children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.start,
//            mainAxisSize: MainAxisSize.min,
//            crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "RECORD PREFERENCES",
                          ),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Item Record Preferences",
                          ),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                            child: const Text(
                              "How certain records are further handled (eg. deleted, past due, etc.)",
                            ),
                          ),
                        ])
                  ])),
            ),
            Card(
                child: Settings.tapText(
              'About ToDo List',
              () {
                Settings.showAboutDialog(context);
              },
//                  style: const TextStyle(
//                      fontSize: 12.0,
//                      color: const Color(0xFF000000),
//                      fontWeight: FontWeight.w300,
//                      fontFamily: "Roboto"),
            )),
          ]),
    );
  }

  void orderItems(bool value) {
    Settings.setOrder(value);
    setState(() {
      _descending = value;
    });
    _refresh = true;
  }

  void switchButton(bool value) {
    Settings.setLeftHanded(value);
    setState(() {
      _leftHanded = value;
    });
  }

  static void onTap() {
    var test = true;
  }
}
