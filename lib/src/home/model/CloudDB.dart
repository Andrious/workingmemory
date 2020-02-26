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

// What is done, with every change, it's recorded in every other device
// to be synced when those devices start up.
import 'package:flutter/material.dart';

import 'dart:collection' show LinkedHashMap;

import 'package:workingmemory/src/model.dart'
    show AppModel, FireBaseDB, Model, Semaphore, SyncDB;

import 'package:workingmemory/src/controller.dart'
    show App, Controller, WorkingMemoryApp;

import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, DatabaseReference;

import 'package:auth/auth.dart' show Auth;

class CloudDB {
  factory CloudDB() => _this ??= CloudDB._();
  static CloudDB _this;
  CloudDB._();

  final FireBaseDB _db = FireBaseDB.init();

  final AppModel _appModel = AppModel();

  final DatabaseReference _fireDBRef = FireBaseDB.reference();

  final SyncDB _dbHelper = SyncDB();

  final DataSync _dataSync = DataSync();

  /// Allow for easy access to 'this singular instance' throughout the application.
//  static CloudDB get object => _this ?? CloudDB();

  static final String _dbName = "sync";

  Future<bool> init() => _dbHelper.open();

  // Set the device entry in the cloud with an assigned timestamp.
  Future<void> setDeviceDirectory() => _dataSync.deviceDirectory();

  static void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {}
  }

  void dispose() {
    _dbHelper.disposed();
    DataSync.dispose();
    FireBaseDB.goOffline();
  }

  Future<void> sync() => _dataSync.sync(this);

  void reSync() => _dataSync.reSync();

  Future<bool> insert(String key, String action) => _dataSync.insert(key, action);

  Future<bool> delete(int recId, String key) async {
    Map<String, dynamic> recValues;

    recValues["id"] = recId;

    recValues["key"] = key;

    recValues["action"] = "DELETE";

    // time is seconds
    recValues["timestamp"] = Semaphore.timeStamp;

    int count = await _dbHelper.update(recValues, recId);

    return count > 0;
  }

  Future<List<Map<String, dynamic>>> getRecs() async {
    return await _dbHelper.rawQuery("SELECT * FROM " + _dbName);
  }

  Future<List<Map<String, dynamic>>> getRec(String key) {
    String stmt = "SELECT * from $_dbName  WHERE key = \"${key.trim()}\"";

    return _dbHelper.rawQuery(stmt);
  }

  Future<bool> save(int recId, String key) async {
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

  Future<String> getAction(int recId) async {
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

  Future<bool> update(Map<String, dynamic> recValues, int recId) async {
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

  Future<bool> insertNew(Map<String, dynamic> recValues, int recId) async {
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
  static final WorkingMemoryApp _con = WorkingMemoryApp();
  final FireBaseDB _fireDB = FireBaseDB.init();
  void init() {}

  Future<void> deviceDirectory() => devRef.set(timeStamp);

  static DatabaseReference get devRef => _devRef ??= getDevRef();

  //todo What to do about this mess.
  static Model _model = Controller().model;

  static DatabaseReference _devRef;

  static DatabaseReference getDevRef() {
    String id = _con.uid;

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
      ref = FireBaseDB.reference()
          .child("devices")
          .child(id)
          .child(App.installNum);
    }
    return ref;
  }

  // Set the timeStamp this program was last run.
  static int get timeStamp => (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSync && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  Future<DatabaseReference> getSyncRef() async {
    final online = await isOnline();
//    if (!isOnline()) FireBaseDB.goOnline();
    String id;
    if (online){
      id = _con.uid;
    }else{
      id = null;
    }

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
      ref =
          FireBaseDB.reference().child("sync").child(id).child(App.installNum);
    }
    return ref;
  }

  // Is connected to the Internet.
  Future<bool> isOnline() => _fireDB.isOnline();

  Future<void> sync(CloudDB cloud) async {
    final online = await isOnline();
    if (!online) return;

    final DatabaseReference syncRef = await getSyncRef();

    final DataSnapshot syncINRef = await syncRef.child("IN").once();

    if (syncINRef.value == null || syncINRef.value is! Map) return;

    bool synced;

    syncINRef.value.forEach((k, v) async {
      synced = false;

      var key = v["key"];

      var action = v["action"];

      var timestamp = v["timestamp"];

      List<Map<String, dynamic>> recs = await cloud.getRec(key);

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

        if (!synced) {
          List<Map<String, dynamic>> local = await _model.getRecord(key);

          LinkedHashMap<String, dynamic> cloud = await _fireDB.records();

          // Add to the local device.
          if (local.length == 0) {
            if (action == "DELETE") {
              // It's been deleted and not to be added anyway.
              synced = true;
            } else {
              synced = await _model.saveRec(rec);
            }
            // Update the appropriate database with the most recent copy.
          } else {
            if (action == "DELETE") {
              if (cloud.length == 0) {
                //It has been deleted already
                synced = true;
              } else {
                // Delete the local copy
                synced = await _model.deleteRec(cloud['key']);
              }
            } else {
              // Update the local copy
              synced = await _model.saveRec(cloud);
            }
          }
        }
      }
    });
  }

  void reSync() async {
    LinkedHashMap recs = await _fireDB.records();
    recs.forEach((key, value) {
      insert(key, "UPDATE");
    });
  }

  Future<bool> insert(final String key, final String action) async {
    if (key == null || key.trim().isEmpty) {
      return false;
    }
    if (action == null || action.trim().isEmpty) {
      return false;
    }
    bool insert;
    try {
      deviceDirectory();
      await replace(key, {"key": key, "action": action, "timestamp": timeStamp});
      insert = true;
    } catch (ex) {
      insert = false;
    }
    return insert;
  }

  Future<void> replace(
      String key, Map<String, dynamic> recValues) async {
    final DatabaseReference syncRef = await getSyncRef();

    DataSnapshot snapshot =
        await syncRef.child("OUT").orderByChild("key").equalTo(key).once();

    if (snapshot.value == null || snapshot.value is! Map) {
      insertRef(syncRef.child("OUT"), recValues);
    } else {
      Map<String, dynamic> data = snapshot.value;
      data.forEach((k, v) {
        syncRef.child("OUT").child(k).update({k: recValues});
      });
    }
  }

  static Future<String> insertRef(
      DatabaseReference dbRef, Map<dynamic, dynamic> recValues) async {
    String key;
    try {
      key = dbRef.push().key;
      await dbRef.update({key: recValues});
    } catch (ex) {
      key = "";
    }
    return key;
  }

  static void dispose() {
    _devRef = null;
  }
}
