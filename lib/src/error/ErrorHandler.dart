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
///          Created  23 Jun 2018
///

import 'dart:async' show Future, runZoned;
import 'dart:isolate' show Isolate, RawReceivePort;

import 'package:flutter/foundation.dart' show FlutterError, FlutterErrorDetails;
import 'package:flutter/material.dart' show FlutterError, FlutterErrorDetails, Widget, runApp;

/// Must acknowledge https://github.com/yjbanov/crashy
dynamic exeApp(Widget app) async {

  /// The default is to dump the error to the console.
  /// Instead, a custom function is called.
  FlutterError.onError = (FlutterErrorDetails details) async {
    await _reportErrorDetails(details);
  };

  /// All Dart code runs in an isolate.  Isolates is Dart's way to work with threads.
  /// Your app runs in its own isolate and can spawn new isolates.
  Isolate.current.addErrorListener(new RawReceivePort((dynamic pair) async {
    await _reportError(
      (pair as List<String>).first,
      (pair as List<String>).last,
    );
  }).sendPort);

  /// The initial `main` function runs in the default or 'root' zone.
  /// We can, instead, create a new zone using [runZoned] and catch any errors.
  runZoned<Future<Null>>(() async {
    runApp(app);
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

/// Reports [error] along with its [stackTrace]
Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  // details.exception, details.stack

  FlutterError.dumpErrorToConsole(FlutterErrorDetails(
  exception: error,
  stack: stackTrace,));
}

/// Reports [error] along with its [stackTrace]
Future<Null> _reportErrorDetails(FlutterErrorDetails details) async {
  // details.exception, details.stack

  FlutterError.dumpErrorToConsole(details);
}