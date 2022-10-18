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

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import 'package:workingmemory/src/view.dart' show showCupertinoDatePicker;

class DTiOS extends StatelessWidget {
  DTiOS({Key? key, required DateTime dateTime, required this.onChanged})
      : assert(onChanged != null),
        date = DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = DateTime(0, 0, 0, dateTime.hour, dateTime.minute),
        super(key: key);

  final DateTime date;
  final DateTime time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime initDate = date;
    final DateTime initTime = time;
    return DefaultTextStyle(
        style: theme.textTheme.subtitle1!,
        child: Row(children: <Widget>[
          Expanded(
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: theme.dividerColor))),
                  child: GestureDetector(
                    onTap: () {
                      showCupertinoDatePicker(context,
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: date,
//                          backgroundColor: theme.canvasColor,
                          onDateTimeChanged: (DateTime date) {
                        DateTime result;
                        if (date.year > 0) {
                          result = DateTime(date.year, date.month, date.day,
                              time.hour, time.minute);
                        } else {
                          result = initDate;
                        }
                        onChanged(result);
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(DateFormat('EEE, MMM d yyyy').format(date)),
                          const Icon(Icons.arrow_drop_down,
                              color: Colors.black54),
                        ]),
                  ))),
          Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: theme.dividerColor))),
              child: GestureDetector(
                onTap: () {
                  showCupertinoDatePicker(context,
                      mode: CupertinoDatePickerMode.time, initialDateTime: time,
                      onDateTimeChanged: (DateTime time) {
                    DateTime result;
                    if (time.hour > 0 || time.minute > 0) {
                      result = DateTime(date.year, date.month, date.day,
                          time.hour, time.minute);
                    } else {
                      result = DateTime(date.year, date.month, date.day,
                          initTime.hour, initTime.minute);
                    }
                    onChanged(result);
                  });
                },
                child: Row(children: <Widget>[
                  Text(DateFormat('h:mm a').format(time)),
                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                ]),
              ))
        ]));
  }
}
