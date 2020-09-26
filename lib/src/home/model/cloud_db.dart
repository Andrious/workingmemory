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
///          Created  23 Jun 2018
///

import 'dart:collection' show LinkedHashMap;

import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, DatabaseReference;

// What is done, with every change, it's recorded in every other device
// to be synced when those devices start up.
import 'package:flutter/material.dart';
import 'package:workingmemory/src/controller.dart'
    show App, Controller, WorkingController;
import 'package:workingmemory/src/model.dart'
    show AppModel, FireBaseDB, Model, Semaphore, SyncDB;

class CloudDB {
  factory CloudDB() => _this ??= CloudDB._();
  CloudDB._() {
    _fbDB = FireBaseDB();
    _appModel = AppModel();
    _fireDBRef = _fbDB.reference();
    _dbHelper = SyncDB();
    _dataSync = DataSync();
  }
  static CloudDB _this;

  FireBaseDB _fbDB;
  AppModel _appModel;
  DatabaseReference _fireDBRef;
  SyncDB _dbHelper;
  DataSync _dataSync;

  /// Allow for easy access to 'this singular instance' throughout the application.
//  static CloudDB get object => _this ?? CloudDB();

  static const String _dbName = 'sync';

  Future<bool> init() => _dbHelper.open();

  // Set the device entry in the cloud with an assigned timestamp.
  Future<void> timeStampDevice() => _dataSync.timeStampDevice();

  static void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {}
  }

  void dispose() {
    _dbHelper.disposed();
    FireBaseDB.goOffline();
  }

  Future<void> sync() async {
    //
    try {
      await _dataSync.sync(this);
    } catch (ex) {
      App.catchError(ex);
    }
    return;
  }

  void reSync() => _dataSync.reSync();

  Future<bool> insert(String key, String action) =>
      _dataSync.insert(key, action);

  Future<bool> delete(int recId, String key) async {
    final Map<String, dynamic> recValues = {};

    recValues['id'] = recId;

    recValues['key'] = key;

    recValues['action'] = 'DELETE';

    // time is seconds
    recValues['timestamp'] = Semaphore.timeStamp;

    final int count = await _dbHelper.update(recValues);

    return count > 0;
  }

  Future<List<Map<String, dynamic>>> getRecs() =>
      _dbHelper.rawQuery('SELECT * FROM $_dbName');

  Future<List<Map<String, dynamic>>> getRec(String key) async {
    List<Map<String, dynamic>> recs;
    if (key == null || key.trim().isEmpty) {
      recs = [{}];
    } else {
      recs = await _dbHelper
          .rawQuery('SELECT * from $_dbName  WHERE key = "${key.trim()}"');
    }
    return recs;
  }

  Future<bool> save(int recId, String key) async {
    bool save = false;

    save = _dbHelper.isOpen;

    if (save) {
      final Map<String, dynamic> recValues = {
        'id': recId,
        'key': key,
        'action': 'UPDATE',
        'timestamp': DataSync.timeStamp
      };

      // Record is no longer to be deleted but updated.
      final String action = await getAction(recId);

      if (action == 'DELETE') {
        save = await update(recValues, recId);
      } else {
        save = await insertNew(recValues, recId);
      }
    }
    return save;
  }

  Future<String> getAction(int recId) async {
    String action;

    final List<Map<String, dynamic>> recs = await _dbHelper
        .rawQuery('SELECT action FROM $_dbName WHERE id = $recId');

    if (recs.isEmpty) {
      action = '';
    } else {
      action = recs[0]['action'];
    }
    return action;
  }

  Future<bool> update(Map<String, dynamic> recValues, int recId) async {
    int rowId = await _dbHelper.getRowID(recId);

    bool update = rowId > 0;

    if (update) {
      rowId = await _dbHelper.update(recValues);

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
  static final WorkingController _con = WorkingController();
  final FireBaseDB _fireDB = FireBaseDB();
  void init() {}

  //todo What to do about this mess.
  static final Model _model = Controller().model;

  Future<void> timeStampDevice() => devRef.set(timeStamp);

  DatabaseReference get devRef => _devRef ??= _fireDB.yourDeviceRef;
  DatabaseReference _devRef;

  // Set the timeStamp this program was last run.
  static int get timeStamp => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSync && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  Future<DatabaseReference> getSyncRef() async {
    final DatabaseReference ref = await yourSyncRef();
    return ref.child(App.installNum);
  }

  Future<DatabaseReference> yourSyncRef() async {
    final online = await isOnline();
    String id;
    if (online) {
      id = _con.uid;
    } else {
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
      ref = _fireDB.reference().child('sync').child('dummy');
    } else {
      ref = _fireDB.reference().child('sync').child(id);
    }
    return ref;
  }

  // Is connected to the Internet.
  Future<bool> isOnline() => _fireDB.isOnline();

  Future<void> sync(CloudDB cloud) async {
    //
    final online = await isOnline();

    if (!online) {
      return;
    }

    final DatabaseReference syncRef = await getSyncRef();

    final DataSnapshot syncINRef = await syncRef.child('IN').once();

    if (syncINRef.value == null || syncINRef.value is! Map) {
      return;
    }

    bool synced;
    syncINRef.value.forEach((k, v) async {
      synced = false;

      final key = v['key'];

      final action = v['action'];

      final timestamp = v['timestamp'];

      final List<Map<String, dynamic>> offlineRecs = await cloud.getRec(key);

      // Maybe device was offline and made changes locally to the same record.
      if (offlineRecs.isNotEmpty) {
        //
        final Map<String, dynamic> rec = offlineRecs[0];

        // If the local is more up to date
        if (timestamp < rec['timestamp']) {
          synced = true;

          // The remote change is more recent.
        } else {
          // Delete the local sync entry. It's old.
          await _model.deleteRec(key);
        }

        if (!synced) {
          //
          final List<Map<String, dynamic>> local = await _model.getRecord(key);

          final LinkedHashMap<String, dynamic> cloud = await _fireDB.records();

          // Add to the local device.
          if (local.isEmpty) {
            if (action == 'DELETE') {
              // It's been deleted and not to be added anyway.
              synced = true;
            } else {
              synced = await _model.saveRec(rec);
            }
            // Update the appropriate database with the most recent copy.
          } else {
            if (action == 'DELETE') {
              if (cloud.isEmpty) {
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

      if (!synced) {
        //  Get the online copy of the record.
        final Map<String, dynamic> cloudRec = await _fireDB.record(key);

        // Get a local copy of the record.
        final Map<String, dynamic> localRec = await Model().recordByKey(key);

        // Add to the local device.
        if (localRec.isEmpty) {
          if (action == 'DELETE') {
            // It's been deleted and not to be added anyway.
            synced = true;
          } else {
            synced = await Model().saveRec(cloudRec);
          }

          // Update the appropriate database with the most recent copy.
        } else {
          if (action == 'DELETE') {
            if (cloudRec.isEmpty) {
              // It has been deleted already
              synced = true;
            } else {
              // Delete the local copy
              synced = await Model().delete(cloudRec);
            }
          } else {
            // Update the local copy
            synced = await Model().saveRec(cloudRec);
          }
        }
      }

      if (synced) {
        final DatabaseReference dbRef = syncRef.child('IN').child(k);

        // Delete that record
        await dbRef.set(null);
      }
    });
  }

  Future<void> reSync() async {
    final Map<String, dynamic> recs = await _fireDB.records();
    recs.forEach((key, value) {
      insert(key, 'UPDATE');
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
      await timeStampDevice();
      await replace(
          key, {'key': key, 'action': action, 'timestamp': timeStamp});
      insert = true;
    } catch (ex) {
      insert = false;
    }
    return insert;
  }

//  Future<void> replace(String key, Map<String, dynamic> recValues) async {
//    final DatabaseReference syncRef = await getSyncRef();
//
//    DataSnapshot snapshot =
//        await syncRef.child("OUT").orderByChild("key").equalTo(key).once();
//
//    if (snapshot.value == null || snapshot.value is! Map) {
//      insertRef(syncRef.child("OUT"), recValues);
//    } else {
//      Map<String, dynamic> data = snapshot.value;
//      data.forEach((k, v) {
//        syncRef.child("OUT").child(k).update({k: recValues});
//      });
//    }
//  }

  Future<bool> replace(String key, Map<String, dynamic> recValues) async {
    // Retrieve all your sync records.
    final DatabaseReference syncRef = await yourSyncRef();

    DataSnapshot snapshot = await syncRef.once();

    if (snapshot.value == null || snapshot.value is! Map) {
      return false;
    }

    // Retrieve all your devices.
    final DatabaseReference dRef = _fireDB.yourDevicesRef;

    snapshot = await dRef.once();

    if (snapshot.value == null || snapshot.value is! Map) {
      return false;
    }

    final Map<String, dynamic> data = Map.from(snapshot.value)
    // Remove the device you're current on.
    ..removeWhere((key, value) => key == App.installNum);

    final bool replace = data.isNotEmpty;
    String key;

    // Iterate through your devices and log the change.
    final Iterator<dynamic> it = data.entries.iterator;

    while (it.moveNext()) {
      if (it.current.value == null || it.current.value is! int) {
        continue;
      }
      if (it.current.key is! String) {
        continue;
      }
      // Remove devices that are more than a year old.
      final DateTime timeStamp = Semaphore.getDateTime(it.current.value);
      final int daysOld = DateTime.now().difference(timeStamp).inDays;
      if (daysOld > 365) {
        try {
          // Delete that record
          await dRef.child(it.current.key).set(null);
          await syncRef.child(it.current.key).set(null);
        } catch (ex) {
          // there's no such child.
          continue;
        }
        continue;
      }
      // Go through the sync entries.
      final DatabaseReference ref = syncRef.child(it.current.key);
      snapshot = await dRef.once();
      if (snapshot.value == null || snapshot.value is! Map) {
        continue;
      }
      // Is there already a sync record.
      snapshot = await ref.child('IN').orderByChild('key').equalTo(key).once();
      if (snapshot.value == null || snapshot.value is! Map) {
        key = await insertRef(ref.child('IN'), recValues);
      } else {
        final Map<String, dynamic> data = snapshot.value;
        data.forEach((k, v) {
          syncRef.child("IN").child(k).update({k: recValues});
        });
      }
    }
    return replace;
  }

  Future<String> insertRef(
      DatabaseReference dbRef, Map<dynamic, dynamic> recValues) async {
    String key;
    try {
      key = dbRef.push().key;
      await dbRef.update({key: recValues});
    } catch (ex) {
      key = '';
    }
    return key;
  }

  void dispose() {
    _devRef = null;
  }
}
