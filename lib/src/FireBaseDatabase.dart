import 'FireBase.dart';

import 'package:firebase_database/firebase_database.dart' as fb;

import 'package:firebase_core/firebase_core.dart';


class FireBaseDatabase {

  static fb.FirebaseDatabase database;

  static FirebaseApp fireBaseApp;

  FireBaseDatabase() {
    database = FireBase.database();

    fireBaseApp = database.app;
  }

}