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
///          Created  10 Sep 2018
///

import 'package:flutter/material.dart';

import 'package:workingmemory/src/controller.dart' show Settings;

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {

  bool descending;
  bool leftHanded;

  @override
  void initState(){
     super.initState();
     descending = Settings.getOrder();
     leftHanded = Settings.getLeftHanded();
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Column(
//      mainAxisAlignment: MainAxisAlignment.start,
//      mainAxisSize: MainAxisSize.min,
//      crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text("INTERFACE PREFERENCES",
                          style: const TextStyle(
                              fontSize: 12.0,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w200,
                              fontFamily: "Georgia")),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text("Sorted Order of Items",
                          style: const TextStyle(
                              fontSize: 12.0,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w300,
                              fontFamily: "Roboto")),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                        child: const Text(
                          "Check so the items are in descending order with the most recent items listed first.",
                          style: const TextStyle(
                              fontSize: 12.0,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w200,
                              fontFamily: "Roboto"),
                          softWrap: true,
                        ),
                      ),
                      Checkbox(
                        key: null,
                        value: descending,
                        onChanged: orderItems,
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          child: const Text("Switch around dialog buttons",
                              style: const TextStyle(
                                  fontSize: 12.0,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w300,
                                  fontFamily: "Roboto"))),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: const Text(
                            "Possibly preferred by left-handed people.",
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w200,
                                fontFamily: "Roboto")),
                      ),
                      Checkbox(
                        key: null,
                        value: leftHanded,
                        onChanged: switchButton,
                      ),
                    ]),
              ]),
            ),
            Card(
              child: GestureDetector(
                onTap: () {
                  onTap();
                },
                child: Column(children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Text("NOTIFICATION PREFERENCES",
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w200,
                                fontFamily: "Georgia")),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Text("Notification Settings",
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w300,
                                fontFamily: "Roboto")),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                          child: const Text(
                            "Notification behaviour, popup settings and LED Colour",
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w200,
                                fontFamily: "Roboto"),
                            softWrap: true,
                          ),
                        ),
                      ]),
                ]),
              ),
            ),
            Card(
              child: GestureDetector(
                onTap: () {
                  onTap();
                },
                child: Column(children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.start,
//            mainAxisSize: MainAxisSize.min,
//            crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text("RECORD PREFERENCES",
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w200,
                                fontFamily: "Georgia")),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Text("Item Record Preferences",
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w300,
                                fontFamily: "Roboto")),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                          child: const Text(
                              "How certain records are further handled (eg. deleted, past due, etc.)",
                              style: const TextStyle(
                                  fontSize: 12.0,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w200,
                                  fontFamily: "Roboto")),
                        ),
                      ])
                ]),
              ),
            ),
            Card(
              child: Settings.tapText('About ToDo List', (){Settings.showAboutDialog(context: context);},
              style: const TextStyle(
                  fontSize: 12.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w300,
                  fontFamily: "Roboto")
              )
            )
          ]),
    );
  }

  void orderItems(bool value) {
    Settings.setOrder(value);
    setState(() {
      descending = value;
    });
  }

  void switchButton(bool value){
    Settings.setLeftHanded(value);
    setState(() {
      leftHanded = value;
    });
  }

  static void onTap() {
    var test = true;
  }
}
