/// Copyright 2022 Andrious Solutions Ltd. All rights reserved.
/// Use of this source code is governed by a 2-clause BSD License.
/// The main directory contains that LICENSE file.
///
///          Created  18 July 2022
///
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as t;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Supply timezone information.
class TimeZone {
  /// A factory constructor for only one single instance.
  factory TimeZone() => _this ??= TimeZone._();

  TimeZone._() {
    initializeTimeZones();
  }
  static TimeZone? _this;

  /// Supply a String describing the current timezone.
  Future<String> getTimeZoneName() async => FlutterTimezone.getLocalTimezone();

  /// Returns a Location object from the specified timezone.
  Future<t.Location> getLocation([String? timeZoneName]) async {
    if (timeZoneName == null || timeZoneName.isEmpty) {
      timeZoneName = await getTimeZoneName();
    }
    return t.getLocation(timeZoneName);
  }
}
