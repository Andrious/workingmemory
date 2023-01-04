// Copyright 2018 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a Apache License, Version 2.0 that can be
// found in the LICENSE file.
import 'package:workingmemory/src/model.dart';

// ignore: avoid_classes_with_only_static_members
///
class Semaphore {
  ///
  static const String _SIGNAL = 'semaphore';

  ///
  static const int STAMP_RESET = -1;

  static int _timeStamp = STAMP_RESET;

  static int _stamp = 0;

  ///
  static bool got() => _stamp == _timeStamp;

  ///
  static bool gotIt(DataSnapshot snapshot) {
    if (snapshot.key!.endsWith(_SIGNAL)) {
      _timeStamp = snapshot.value as int;
    } else {
      _timeStamp = STAMP_RESET;
    }
    return got();
  }

  ///
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

  ///
  static int get timeStamp => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  ///
  static DateTime getDateTime(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

//  static DatabaseReference get dbRef => FireBaseDB().tasksRef.child('semaphore');
  ///
  static DatabaseReference get dbRef => FireBaseDB().userRef.child(_SIGNAL);
}
