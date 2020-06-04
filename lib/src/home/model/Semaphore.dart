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
///          Created  29 Nov 2018
///

import 'package:firebase_database/firebase_database.dart';

import 'package:workingmemory/src/model.dart';

class Semaphore {
  //
  static const String _SIGNAL = "semaphore";

  static const int STAMP_RESET = -1;

  static int _timeStamp = STAMP_RESET;

  static int _stamp = 0;

  static bool got() => _stamp == _timeStamp;

  static bool gotIt(DataSnapshot snapshot) {
    if (snapshot.key.endsWith(_SIGNAL)) {
      _timeStamp = snapshot.value;
    } else {
      _timeStamp = STAMP_RESET;
    }
    return got();
  }

  static Future<bool> write() async {
    _stamp = Semaphore.timeStamp;
    bool write;
    try {
      await dbRef.set(_stamp);
      await CloudDB().timeStampDevice();
      write = true;
    } catch (ex) {
      write = false;
    }
    return write;
  }

  static int get timeStamp => (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  static DateTime getDateTime(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

//  static DatabaseReference get dbRef => FireBaseDB().tasksRef.child('semaphore');

  static DatabaseReference get dbRef => FireBaseDB().userRef.child(_SIGNAL);
}
