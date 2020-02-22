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

import 'dart:collection' show LinkedHashMap;

import 'package:workingmemory/src/model.dart' show AppModel, FireBaseDB, Model, SyncDB;

import 'package:workingmemory/src/controller.dart'
    show App, Controller, WorkingMemoryApp;

import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, DatabaseReference;

import 'package:auth/auth.dart' show Auth;



class CloudDB {
  factory CloudDB() => _this ??= CloudDB._();

  CloudDB._(){
    _db = FireBaseDB.init();

    _con = Controller.con;

    _model = Controller.model;

    _appModel = AppModel();

    _fireDBRef = FireBaseDB.reference();

    _dbHelper = SyncDB();
  }
  static CloudDB _this;
  FireBaseDB _db;
  Controller _con;
  Model _model;
  AppModel _appModel;
  DatabaseReference _fireDBRef;
  static SyncDB _dbHelper;


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
    DataSync.dispose();
    FireBaseDB.goOffline();
  }

  static void sync() => DataSync.sync();

  static void reSync() => DataSync.reSync();

  static bool insert(String key, String action) {
    return DataSync.insert(key, action);
  }

  static Future<List<Map<String, dynamic>>> getRecs() async {
    return await _dbHelper.rawQuery("SELECT * FROM " + _dbName);
  }

  static Future<List<Map<String, dynamic>>> getRec(String key) {
    String stmt = "SELECT * from $_dbName  WHERE key = \"${key.trim()}\"";

    return _dbHelper.rawQuery(stmt);
  }

  static Future<bool> save(int recId, String key) async {
    bool save = false;

    save = _dbHelper.isOpen;

    if (save) {
      Map<String, dynamic> recValues = {
        "id": recId,
        "key": key,
        "action": "UPDATE",
        "timestamp": DataSync.timeStamp
      };

      // Record is no longer to be deleted but updated.
      String action = await getAction(recId);

      if (action == "DELETE") {
        save = await update(recValues, recId);
      } else {
        save = await insertNew(recValues, recId);
      }
    }
    return save;
  }

  static Future<String> getAction(int recId) async {
    String action;

    List<Map<String, dynamic>> recs = await _dbHelper
        .rawQuery("SELECT action FROM $_dbName WHERE id = $recId");

    if (recs.isEmpty) {
      action = "";
    } else {
      action = recs[0]["action"];
    }
    return action;
  }

  static Future<bool> update(Map<String, dynamic> recValues, int recId) async {
    int rowId = await _dbHelper.getRowID(recId);

    bool update = rowId > 0;

    if (update) {
      rowId = await _dbHelper.update(recValues, rowId);

      update = rowId > 0;
    } else {
      rowId = await _dbHelper.insert(recValues);

      update = rowId > 0;
    }

    return update;
  }

  static Future<bool> insertNew(
      Map<String, dynamic> recValues, int recId) async {
    int rowId = await _dbHelper.getRowID(recId);

    bool insert = rowId < 1;

    // Only insert 'new' records. A 'sync' will delete all these records.
    if (insert) {
      rowId = await _dbHelper.insert(recValues);

      insert = rowId > 0;
    } else {
      // A record is already there.
      insert = true;
    }

    return insert;
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
    _devRef ??= getDevRef();
    return _devRef;
  }

  //todo What to do about this mess.
  static Model _model = Controller.model;


  static DatabaseReference _devRef;

  static DatabaseReference getDevRef() {
    String id = WorkingMemoryApp.uid;

    if (id == null || id.isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }

    DatabaseReference ref;

    if (id == null) {
      // Important to provide a reference that is not likely there in case called by deletion routine.
      ref = FireBaseDB.reference().child("devices").child(App.installNum);
    } else {
      ref =
          FireBaseDB.reference().child("devices").child(id).child(App.installNum);
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
    _syncRef ??= getSyncRef();
    return _syncRef;
  }

  static DatabaseReference _syncRef;

  static DatabaseReference getSyncRef() {
    if (!isOnline()) FireBaseDB.goOnline();

    String id = WorkingMemoryApp.uid;

    if (id == null || id.trim().isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }

    DatabaseReference ref;

    if (id == null) {
      // Important to give a reference that's not  there in case called by deletion routine.
      ref = FireBaseDB.reference()
          .child("sync")
          .child("dummy")
          .child(App.installNum);
    } else {
      ref = FireBaseDB.reference().child("sync").child(id).child(App.installNum);
    }
    return ref;
  }

  static bool isOnline() {
    // Is connected to the Internet.
    return App.isOnline;
  }

  static void sync() async {
    if (!isOnline()) return;

    final DatabaseReference syncRef = DataSync.syncRef;

    final DataSnapshot syncINRef = await syncRef.child("IN").once();

    if (syncINRef.value == null || syncINRef.value is! Map) return;

    bool synced;

    syncINRef.value.forEach((k, v) async {
      synced = false;

      var key = v["key"];

      var action = v["action"];

      var timestamp = v["timestamp"];

      List<Map<String, dynamic>> recs = await CloudDB.getRec(key);

      if (recs.isNotEmpty) {
        Map<String, dynamic> rec = recs[0];

        // If the local is more up to date
        if (timestamp < rec["timestamp"]) {
          synced = true;

          // The remote change is more recent.
        } else {
          // Delete the local sync entry. It's old.
          _model.deleteRec(key);
        }

        if(!synced){

          List<Map<String, dynamic>> local = await _model.getRecord(key);

          LinkedHashMap<String, dynamic> cloud = await FireBaseDB.records();

          // Add to the local device.
          if (local.length == 0){

            if (action == "DELETE"){

              // It's been deleted and not to be added anyway.
              synced = true;
            }else{

              synced = await _model.saveRec(rec);
            }
            // Update the appropriate database with the most recent copy.
          }else{
            if (action == "DELETE"){

              if (cloud.length == 0){

                 //It has been deleted already
                synced = true;
              }else{

                 // Delete the local copy
                synced = await _model.deleteRec(cloud['key']);
              }
            }else{

              // Update the local copy
              synced = await _model.saveRec(cloud);
            }
          }

        }
      }
    });
  }

  static void reSync() async {
    LinkedHashMap recs = await FireBaseDB.records();
    recs.forEach((key, value){
      
    });
  }

  static bool insert(final String key, final String action) {
    if (key == null || key.trim().isEmpty) {
      return false;
    }

    if (action == null || action.trim().isEmpty) {
      return false;
    }

    deviceDirectory();

    replace(key, {"key": key, "action": action, "timestamp": timeStamp});

    return true;
  }

  static void replace(String key, Map<String, dynamic> recValues) async {
    final DatabaseReference syncRef = DataSync.syncRef;

    DataSnapshot snapshot =
        await syncRef.child("OUT").orderByChild("key").equalTo(key).once();

    if (snapshot.value == null || snapshot.value is! Map) return;

    snapshot.value.forEach((k, v) {
      syncRef.child("OUT").child(k).remove();
    });

//    syncRef.child("OUT").child(snapshot.key).remove();

    insertRef(syncRef.child("OUT"), recValues);
  }

  static String insertRef(
      DatabaseReference dbRef, Map<dynamic, dynamic> recValues) {
    String key = "";

    try {
      key = dbRef.push().key;

      dbRef.update({key: recValues});
    } catch (ex) {}

    return key;
  }

  static void dispose() {
    _devRef = null;
    _syncRef = null;
  }
}
