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

import 'package:flutter/material.dart';

import 'package:workingmemory/src/model/model.dart' show AppModel, Model, SyncDB;

import 'package:workingmemory/src/controller/controller.dart' show App, Controller;

import 'package:firebase_database/firebase_database.dart' show DataSnapshot, DatabaseReference;

import 'package:auth070/auth.dart' show Auth;

import 'package:firebase/firebase.dart' show FireBase;

Controller _con = Controller.con;

Model _model = Controller.model;

AppModel _appModel = AppModel();

DatabaseReference _fireDBRef = FireBase.reference();

SyncDB _dbHelper = SyncDB();

class CloudDB {
  factory CloudDB() {
    if (_this == null) _this = CloudDB._();
    return _this;
  }
  static CloudDB _this;

  CloudDB._();

  /// Allow for easy access to 'this singular instance' throughout the application.
  static CloudDB get object => _this ?? CloudDB();

  static final String _dbName = "sync";

  static Future<bool> init() {
    return _dbHelper.init();
  }

  // Set the device entry in the cloud with an assigned timestamp.
  static void setDeviceDirectory() {
    DataSync.deviceDirectory();
  }

  static void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {}
  }

  static void dispose() {
    _dbHelper.disposed();
  }

  static void sync(){
    DataSync.sync();
  }


  static bool insert(String key, String action){

//    return DataSync.insert(key, action);
  }

  static Future<List<Map<String, dynamic>>> getRecs() async {
    return await _dbHelper.rawQuery("SELECT * FROM " + _dbName);
  }

  static Future<List<Map<String, dynamic>>> getRec(String key) {
//    List<Map<String, dynamic>> recValues = List<Map<String, dynamic>>();
//
//    if (key == null || key.isEmpty) return recValues;

    String stmt = "SELECT * from $_dbName  WHERE key = \"${key.trim()}\"";

    return _dbHelper.rawQuery(stmt);

//      for (Map<String, dynamic> name in recs) {
//
//        int index = rec.getColumnIndex(name);
//
//        switch (rec.getType(index)) {
//        // null
//          case 0:
//            recValues.put(name, "");
//
//            break;
//        // int
//          case 1:
//            recValues.put(name, rec.getInt(index));
//
//            break;
//        // float
//          case 2:
//            recValues.put(name, rec.getFloat(index));
//
//            break;
//        // string
//          case 3:
//            recValues.put(name, rec.getString(index));
//
//            break;
//        // blob
//          case 4:
//            recValues.put(name, rec.getBlob(index));
//
//            break;
//          default:
//            recValues.put(name, rec.getString(index));
//        }
//      }
//    return recValues;
  }
}

abstract class OnLoginListener {
  void onLogin();
}

class DataSync {
  final String installNum = App.installNum;

  void init() {}

  static void deviceDirectory() {
    devRef.set(timeStamp);
  }

  static DatabaseReference get devRef {
    if (_devRef == null) _devRef = getDevRef();
    return _devRef;
  }

  static DatabaseReference _devRef;

  static DatabaseReference getDevRef() {
    String id = Auth.uid;

    if (id == null || id.isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }

    DatabaseReference ref;

    if (id == null) {
      // Important to provide a reference that is not likely there in case called by deletion routine.
      ref = FireBase.reference().child("devices").child(App.installNum);
    } else {
      ref =
          FireBase.reference().child("devices").child(id).child(App.installNum);
    }
    return ref;
  }

  static int get timeStamp => (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSync && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  static DatabaseReference get syncRef {
    if (_syncRef == null) _syncRef = getSyncRef();
    return _syncRef;
  }

  static DatabaseReference _syncRef;

  static DatabaseReference getSyncRef() {
    String id = Auth.uid;

    if (id == null || id.isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }

    DatabaseReference ref;

    if (id == null) {
      // Important to give a reference that's not  there in case called by deletion routine.
      ref = FireBase.reference()
          .child("sync")
          .child("dummy")
          .child(App.installNum);
    } else {
      ref = FireBase.reference().child("sync").child(id).child(App.installNum);
    }
    return ref;
  }


//  static bool insert(final String key, final String action){
//
//    // Record with a timestamp the time of this insertion. (to determine last used on server)
//    //System.currentTimeMillis() / 1000 / 86400  will give you days.
//    deviceDirectory();
//
//    if (key == null || key.isEmpty){ return false; }
//
//    if (action == null || action.isEmpty){ return false; }
//
//    replace(key, new afterValueEventListener(){
//
//    public void afterDataChange(DataSnapshot snapshot){
//
//    ContentValues recValues = new ContentValues();
//
//    recValues.put("key", key);
//
//    recValues.put("action", action.toUpperCase().trim());
//
//    // time is seconds
//    recValues.put("timestamp", System.currentTimeMillis() / 1000);
//
//    insert(recValues);
//    }
//    });
//
//    return true;
//  }
//
//
//  static String insert(ContentValues recValues){
//
//    return insert(syncRef(Auth.getUid()).child("OUT"), recValues);
//  }
//
//  static String insert(DatabaseReference DBRef, ContentValues recValues){
//
//    String key = "";
//
//    try{
//
//      key = DBRef.push().getKey();
//
//      Map<String, Object> childUpdates = new HashMap<>();
//
//      childUpdates.put(key, toMap(recValues));
//
//      DBRef.updateChildren(childUpdates, new DatabaseReference.CompletionListener(){
//
//      public void onComplete(DatabaseError error, DatabaseReference ref){
//
//      if (error != null){
//
//      ErrorHandler.logError("Could not save sync record!");
//      }
//      }
//      });
//    }catch (Exception ex){
//
//    key = "";
//    }
//
//    return key;
//  }

  static bool isOnline() {
    // Is connected to the Internet.
    return App.isOnline;
  }

  static void sync() async {
    if (!isOnline()) return;

    final DatabaseReference syncRef = DataSync.syncRef.child("IN");

    final DataSnapshot syncINRef = await syncRef.child("IN").once();

    if(syncINRef == null) return;
  }
}
