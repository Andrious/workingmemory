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

class DTAndroid extends StatelessWidget {
  DTAndroid({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
        super(key: key);

  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DefaultTextStyle(
        style: theme.textTheme.subtitle1,
        child: Row(children: <Widget>[
          Expanded(
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: theme.dividerColor))),
                  child: InkWell(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate:
                                  date.subtract(const Duration(days: 30)),
                              lastDate: date.add(const Duration(days: 2555)))
                          .then<void>((DateTime value) {
                        if (value != null) {
                          onChanged(DateTime(value.year, value.month, value.day,
                              time.hour, time.minute));
                        }
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
              child: InkWell(
                onTap: () {
                  showTimePicker(context: context, initialTime: time)
                      .then<void>((TimeOfDay value) {
                    if (value != null) {
                      onChanged(DateTime(date.year, date.month, date.day,
                          value.hour, value.minute));
                    }
                  });
                },
                child: Row(children: <Widget>[
                  Text(time.format(context)),
                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                ]),
              ))
        ]));
  }
}
