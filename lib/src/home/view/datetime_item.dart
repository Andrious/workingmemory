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

import 'package:flutter/material.dart';

import 'package:workingmemory/src/view.dart' show App, DTAndroid, DTiOS;

class DateTimeItem extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const DateTimeItem(
      {Key? key, required this.dateTime, required this.onChanged})
      : super(key: key);
  final DateTime dateTime;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return App.useCupertino
        ? DTiOS(key: key, dateTime: dateTime, onChanged: onChanged)
        : DTAndroid(key: key, dateTime: dateTime, onChanged: onChanged);
  }
}
