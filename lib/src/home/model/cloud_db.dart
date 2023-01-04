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
///
import 'dart:async';

///
import 'dart:collection' show LinkedHashMap;

///
import 'package:firebase_database/firebase_database.dart'
    show DatabaseReference, DatabaseEvent;

///
import 'package:workingmemory/src/controller.dart'
    show App, Controller, DeviceInfo, WorkingController;

///
import 'package:workingmemory/src/model.dart'
    show AppModel, FireBaseDB, Model, Semaphore, LocalSyncDB;

///
import 'package:workingmemory/src/view.dart';

/// What is done, with every change, it's recorded in every other device
/// to be synced when those devices start up.
class CloudDB {
  ///
  factory CloudDB() => _this ??= CloudDB._();
  CloudDB._() {
//    _appModel = AppModel();
    _fbDB = FireBaseDB();
    _con = Controller();
    _model = _con.model;
    _offlineSync = LocalSyncDB();
    _dataSync = DataSync();
  }
  static CloudDB? _this;

  late FireBaseDB _fbDB;
  AppModel? _appModel;

  late Controller _con;
  late Model _model;
  late LocalSyncDB _offlineSync;
  late DataSync _dataSync;

  /// A flag indicating it's syncing right now.
  bool _syncing = false;

  /// Allow for easy access to 'this singular instance' throughout the application.
//  static CloudDB get object => _this ?? CloudDB();

  static const String _dbName = 'sync';

  ///
  Future<bool> initAsync() => _offlineSync.open();

  ///
//  int get timeStamp => DataSync.timeStamp;
  String get timeStamp => DataSync.timeStamp;

  /// Set the device entry in the cloud with an assigned timestamp.
  Future<void>? timeStampDevice() => _dataSync.timeStampDevice();

  ///
  static void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {}
  }

  ///
  void dispose() {
    if (!App.hotReload) {
      _offlineSync.disposed();
      FireBaseDB.goOffline();
      _this = null;
    }
  }

  /// Synchronize any changes made in other devices while running here.
  void syncRecListener(DatabaseEvent event) {
    // Map<String, dynamic> data;
    // final DataSnapshot snapshot = event.snapshot;
    // if (snapshot?.value == null || snapshot?.value is! Map) {
    //   data = {};
    // } else {
    //   data = Map<String, dynamic>.from(snapshot.value);
    // }
    sync();
  }

  /// Delete the 'offline' record change
  Future<bool> deleteOfflineSync(int id) => _offlineSync.deleteLocalSync(id);

  /// Perform a synchronization of any records specified as 'new' or 'changed'
  /// since the last time this function was run.
  Future<bool> sync({bool? ignorePastDue, bool? saveTimeZone}) async {
    // Nothing synced should return true anyway.
    bool synced = true;
    // Don't call this function again while it's running.
    if (_syncing) {
      return synced;
    }
    _syncing = true;
    try {
      // Do 'offline' first
      // Nothing to sync, don't return false.
      await offlineSync();
      // Nothing to sync. Don't return false.
      await _dataSync.sync(
        this,
        ignorePastDue: ignorePastDue ?? true,
        saveTimeZone: saveTimeZone ?? true,
      );
    } catch (ex) {
      // // Only return false if there is an error.
      synced = false;
      App.catchError(ex);
    }
    _syncing = false;
    return synced;
  }

  /// Update local records to sync with firebase records
  Future<bool> sendRecsToSync() async {
    bool sync = true;
    try {
      await _dataSync.sendRecsToSync();
    } catch (e) {
      sync = false;
    }
    return sync;
  }

  /// Internet connectivity may be available
  /// Attempt to sync any offline records
  Future<bool> syncOfflineRecs() async {
    // Enforce a delay---just to be certain we're online for good.
    await Future.delayed(const Duration(seconds: 3), () {});
    // If not online don't continue
    bool synced = App.isOnline;
    if (synced) {
      synced = await sync(ignorePastDue: true, saveTimeZone: true);
    }
    return synced;
  }

  /// Synchronize any offline changes to Firebase.
  Future<bool> offlineSync() async {
    // If not online don't bother.
    bool sync = App.isOnline;

    if (!sync) {
      return sync;
    }

    dynamic recId;
    String id;
    List<Map<String, dynamic>?>? recs;
    Map<String, dynamic>? rec;
    bool isDeleted;

    // Any changes made offline.
    final List<Map<String, dynamic>> offlineRecs = await getOfflineChanges();

    for (final offlineRec in offlineRecs) {
      //
      recId = offlineRec['id'];

      // Note the discrepancy and continue.
      if (recId == null) {
        sync = false;
        continue;
      }

      recs = await _model.getRecord(recId);

      // Didn't find the corresponding record in the phone.
      if (recs == null || recs.isEmpty) {
        //
        rec = null;
        isDeleted = true;
      } else {
        //
        rec = recs[0];
        isDeleted = rec!['deleted'] == 1;
      }

      if (rec == null) {
        // It's an old offline record. The record's long gone. Ignore.
      } else if (offlineRec['action'] == 'DELETE') {
        // If still deleted on the phone, delete it up in Firebase.
        if (isDeleted) {
          await _fbDB.delete(rec['KeyFld']);
        }
      } else {
        if (isDeleted) {
          // It's an old offline record. The record's already deleted. Ignore.
        } else {
          await _model.updateFBRec(rec);
        }
      }
      // Delete that offline change record.
      final delete = await deleteOfflineSync(recId);

      // For some reason, the offline record was not removed.
      if (!delete) {
        sync = false;
      }
    }
    return sync;
  }

  /// Insert a 'synchronization' record to the other devices.
  Future<bool> insert(String key, String action) =>
      _dataSync.insert(key, action);

  /// Notify the other devices there was a deletion.
  Future<bool> delete(int recId, String key) async {
    final Map<String, dynamic> recValues = {};

    recValues['id'] = recId;

    recValues['KeyFld'] = key;

    recValues['action'] = 'DELETE';

    // time is seconds
    recValues['timestamp'] = Semaphore.timeStamp;

    final int count = await _offlineSync.update(recValues);

    return count > 0;
  }

  /// Return a list of the 'offline' changes that may have been made.
  Future<List<Map<String, dynamic>>> getOfflineChanges() =>
      _offlineSync.rawQuery('SELECT * FROM $_dbName');

  /// Return a specific 'offline' change record.
  Future<List<Map<String, dynamic>>> getOfflineRec(String? key) async {
    List<Map<String, dynamic>> recs;
    if (key == null || key.trim().isEmpty) {
      recs = [{}];
    } else {
      recs = await _offlineSync
          .rawQuery('SELECT * from $_dbName  WHERE key = "${key.trim()}"');
    }
    return recs;
  }

  /// Save an 'offline' record change record.
  Future<bool> save(int recId, String key) async {
    bool save = false;

    save = _offlineSync.isOpen;

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
        save = await update(recValues);
      } else {
        save = await insertNew(recValues, recId);
      }
    }
    return save;
  }

  /// Return the 'Action' of the specified 'offline' record change record.
  Future<String> getAction(int recId) async {
    String action;

    final List<Map<String, dynamic>> recs = await _offlineSync
        .rawQuery('SELECT action FROM $_dbName WHERE id = $recId');

    if (recs.isEmpty) {
      action = '';
    } else {
      action = recs[0]['action'];
    }
    return action;
  }

  /// Save the 'offline records' to the local database.
  Future<bool> update(Map<String, dynamic> recValues) async {
    //
    final recId = recValues['id'];

    bool update = false;

    if (recId == null) {
      return update;
    }

    int rowId = await _offlineSync.getRowID(recId);

    update = rowId > 0;

    if (update) {
      rowId = await _offlineSync.update(recValues);

      update = rowId > 0;
    } else {
      rowId = await _offlineSync.insert(recValues);

      update = rowId > 0;
    }
    return update;
  }

  /// Insert a 'new' offline record change record.
  Future<bool> insertNew(Map<String, dynamic> recValues, int recId) async {
    //
    int rowId = await _offlineSync.getRowID(recId);

    bool insert = rowId < 1;

    // Only insert 'new' records. A 'sync' will delete all these records.
    if (insert) {
      rowId = await _offlineSync.insert(recValues);

      insert = rowId > 0;
    } else {
      // A record is already there.
      insert = true;
    }

    return insert;
  }
}

///
abstract class OnLoginListener {
  ///
  void onLogin();
}

///
class DataSync {
  ///
  factory DataSync() => _this ??= DataSync._();
  DataSync._() {
    _fireDB = FireBaseDB();
    _con = Controller();
    _model = _con.model;
  }
  static DataSync? _this;
  late FireBaseDB _fireDB;
  late Controller _con;
  late Model _model;
  String? _id;
  DatabaseReference? _syncRef;
  DatabaseReference? _syncINRef;

  /// Set the last time this device has 'updated' data.
  Future<void> timeStampDevice() => devRef.set(timeStamp);

  ///
  DatabaseReference get devRef => _fireDB.yourDeviceRef;

  /// Set the timeStamp this program was last run.
//  static int get timeStamp => DateTime.now().millisecondsSinceEpoch ~/ 1000;
  static String get timeStamp => DateTime.now().toIso8601String();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSync && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  ///
  Future<DatabaseReference> getSyncINRef() async {
    final DatabaseReference ref = await yourSyncRef();
    if (_syncINRef == null) {
//      ref.child(_installNum).child('IN');
//      _syncINRef = ref.child('IN');
      _syncINRef = ref;
      _fireDB.setEvents(_syncINRef!);
    }
    return _syncINRef!;
  }

  ///
  Future<DatabaseReference> yourSyncRef() async {
    //
    final online = App.isOnline; //await isOnline();

    String? id;

    if (online) {
      id = _fireDB.fbKey; //_appCon.uid;
    } else {
      id = null;
    }

    if (id == null || id.trim().isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }

    // Save the reference.
    if (_syncRef != null) {
      if (_id != null && id == _id) {
        return _syncRef!;
      } else {
        await _syncRef!.remove();
      }
    }
    // Set to null so a 'new' reference can be made.
    _syncINRef = null;

    _id = id;

    if (id == null) {
      // Important to give a reference that's not  there in case called by deletion routine.
      _syncRef = _fireDB.reference().child('sync').child('dummy');
    } else {
      _syncRef = _fireDB.reference().child('sync').child(id);
    }
    return _syncRef!;
  }

  // /// Is connected to the Internet.
  // Future<bool> isOnline() => _fireDB.isOnline();

  /// Synchronize any changes made on other devices.
  Future<bool> sync(
    CloudDB cloud, {
    bool? ignorePastDue,
    bool? saveTimeZone,
  }) async {
    //
    final online = App.isOnline;

    // Don't bother to continue. You're not even online.
    if (!online) {
      return false;
    }

    // Any changes from the user's other devices.
    final DatabaseReference ref = await yourSyncRef();
    final DatabaseReference syncRef = ref.child(DeviceInfo.deviceId);

    DatabaseEvent? syncINRef;

    try {
      syncINRef = await syncRef.once();
    } catch (ex) {
      syncINRef = null;
    }

    // Nothing to sync.
    if (syncINRef == null ||
        syncINRef.snapshot.value == null ||
        syncINRef.snapshot.value is! Map) {
      return false;
    }

    final recs = syncINRef.snapshot.value as Map;
    bool synced = false;

    for (final rec in recs.entries) {
      //
      final key = rec.value['key'];

      final action = rec.value['action'];

      final timestamp = rec.value['timestamp'];

      // Find that record in the offline changes table.
      final List<Map<String, dynamic>> offlineRecs =
          await cloud.getOfflineRec(key);

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
          final List<Map<String, dynamic>>? local = await _model.getRecord(key);

          final _cloud = await _fireDB.records()
              as LinkedHashMap<String, Map<String, dynamic>>;

          // Add to the local device.
          if (local!.isEmpty) {
            if (action == 'DELETE') {
              // It's been deleted and not to be added anyway.
              synced = true;
            } else {
              synced = await _model.saveRec(rec);
            }
            // Update the appropriate database with the most recent copy.
          } else {
            if (action == 'DELETE') {
              if (_cloud.isEmpty) {
                //It has been deleted already
                synced = true;
              } else {
                // Delete the local copy
// todo  What is this??   synced = await _model.deleteRec(cloud['key']);
              }
            } else {
              // Update the local copy
              synced = await _model.saveRec(_cloud);
              await _con.setNotification(
                _cloud,
                ignorePastDue: ignorePastDue,
                saveTimeZone: saveTimeZone,
              );
            }
          }
          await cloud.deleteOfflineSync(rec['rowid']);
        }
      }

      if (!synced) {
        //  Get the online copy of the record.
        final Map<String, dynamic> cloudRec = await _fireDB.record(key);

        // Get a local copy of the record.
        final Map<String, dynamic> localRec = await _model.recordByKey(key);

        // Add to the local device.
        if (localRec.isEmpty) {
          if (cloudRec.isEmpty) {
            // Nothing to sync
            synced = true;
          } else if (action == 'DELETE') {
            // It's been deleted and not to be added anyway.
            synced = true;
          } else {
            // Save to local database
            synced = await _model.saveRec(cloudRec);
          }
          // Update the appropriate database with the most recent copy.
        } else {
          if (action == 'DELETE') {
            if (cloudRec.isEmpty) {
              // It has been deleted already from the cloud
              localRec['deleted'] = 1;
              synced = await _model.saveRec(localRec);
            } else {
              // Delete the local copy
              synced = await _model.delete(cloudRec);
            }
          } else if (cloudRec.isEmpty) {
            // Empty for some reason?? (May be under 'dummy')
            // Update the cloud copy
            var key = await _fireDB.updateRec(localRec);
            if (key == '') {
              key = await _fireDB.insertRec(localRec);
            }
            synced = key.isNotEmpty;
          } else {
            // Update the local copy
            synced = await _model.updateRec(localRec, cloudRec);
            await _con.setNotification(
              cloudRec,
              ignorePastDue: ignorePastDue,
              saveTimeZone: saveTimeZone,
            );
          }
        }
      }

      if (synced) {
        //
        final DatabaseReference dbRef = syncRef.child(rec.key);

        // Delete that record
        await dbRef.set(null);
      }
    }
    return synced;
  }

  /// Update local records to sync with firebase records
  Future<void> sendRecsToSync() async {
    final Map<String, dynamic> recs = await _fireDB.records();
    for (final rec in recs.entries) {
      await insert(rec.key, 'UPDATE', justThisDevice: true);
    }
  }

  ///
  Future<bool> insert(final String? key, final String? action,
      {bool? justThisDevice}) async {
    if (key == null || key.trim().isEmpty) {
      return false;
    }
    if (action == null || action.trim().isEmpty) {
      return false;
    }
    bool insert;
    try {
      await timeStampDevice();
      await notifyDevices(
        key,
        {'key': key, 'action': action, 'timestamp': timeStamp},
        justThisDevice: justThisDevice,
      );
      insert = true;
    } catch (ex) {
      insert = false;
    }
    return insert;
  }

  ///
  Future<bool> notifyDevices(String key, Map<String, dynamic> recValues,
      {bool? justThisDevice}) async {
    // Retrieve all your devices.
    final DatabaseReference dRef = _fireDB.yourDevicesRef;

    DatabaseEvent? event;

    try {
      event = await dRef.once();
    } catch (e) {
      event = null;
    }

    if (event == null ||
        event.snapshot.value == null ||
        event.snapshot.value is! Map) {
      return false;
    }

    final data = Map<String, dynamic>.from(event.snapshot.value as Map);
    // Remove the device you're current on.
    if (justThisDevice ?? false) {
      data.removeWhere((key, value) => key != DeviceInfo.deviceId);
    } else {
      data.removeWhere((key, value) => key == DeviceInfo.deviceId);
    }

    bool replace = data.isNotEmpty;

    // Retrieve all your sync records.
    final DatabaseReference syncRef = await yourSyncRef();

    // Iterate through your devices and log the change.
    final Iterator<dynamic> it = data.entries.iterator;

    for (final rec in data.entries) {
      final dateTimeStamp = rec.value; // it.current.value;
      if (dateTimeStamp == null ||
          dateTimeStamp is! String ||
          dateTimeStamp.isEmpty) {
        continue;
      }
      final deviceId = rec.key; // it.current.key;
      // if (deviceId is! String) {
      //   continue;
      // }
      // Remove devices that are more than a year old.
//      final DateTime timeStamp = Semaphore.getDateTime(it.current.value);
      final DateTime timeStamp = DateTime.parse(dateTimeStamp);
      final int daysOld = DateTime.now().difference(timeStamp).inDays;
      if (daysOld > 365 * 7) {
        try {
          // Delete that record
          await dRef.child(deviceId).set(null);
          await syncRef.child(deviceId).set(null);
        } catch (ex) {
          // there's no such child.
          continue;
        }
        continue;
      }
      // Go through the records for this device.
      final DatabaseReference ref = syncRef.child(deviceId);
      event = await dRef.once();
      if (event.snapshot.value == null || event.snapshot.value is! Map) {
        continue;
      }
      event = await ref.orderByChild('key').equalTo(key).once();
      if (event.snapshot.value == null || event.snapshot.value is! Map) {
        final newKey = await insertRef(ref, recValues);
        replace = newKey.isNotEmpty;
        // Is there already a sync record.
      } else {
        await ref.child(key).update(recValues);
      }
    }
    return replace;
  }

  ///
  Future<String> insertRef(
      DatabaseReference dbRef, Map<String, dynamic> recValues) async {
    String key;
    try {
      key = dbRef.push().key!;
      await dbRef.update({key: recValues});
    } catch (ex) {
      key = '';
    }
    return key;
  }

  ///
  void dispose() {}
}
