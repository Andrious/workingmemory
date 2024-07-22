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
import 'dart:async' show Future;
import 'dart:collection' show LinkedHashMap;

import 'package:auth/auth.dart' show User;

import 'package:dbutils/firebase_db.dart' as f;

import 'package:flutter/widgets.dart' show AppLifecycleState;

import '/src/controller.dart'
    show App, Controller, DeviceInfo, WorkingController;

import '/src/model.dart';

///
class FireBaseDB {
  ///
  factory FireBaseDB({
    void Function(DatabaseEvent data)? once,
    void Function(DatabaseEvent event)? onChildAdded,
    void Function(DatabaseEvent event)? onChildRemoved,
    void Function(DatabaseEvent event)? onChildChanged,
    void Function(DatabaseEvent event)? onChildMoved,
    void Function(DatabaseEvent event)? onValue,
  }) =>
      _this ??= FireBaseDB._(
        once,
        onChildAdded,
        onChildRemoved,
        onChildChanged,
        onChildMoved,
        onValue,
      );

  FireBaseDB._(
    void Function(DatabaseEvent data)? once,
    void Function(DatabaseEvent event)? onChildAdded,
    void Function(DatabaseEvent event)? onChildRemoved,
    void Function(DatabaseEvent event)? onChildChanged,
    void Function(DatabaseEvent event)? onChildMoved,
    void Function(DatabaseEvent event)? onValue,
  ) {
    _db = f.FireBaseDB.init(
      once: once,
      onChildAdded: onChildAdded,
      onChildRemoved: onChildRemoved,
      onChildChanged: onChildChanged,
      onChildMoved: onChildMoved,
      onValue: onValue,
    );
    _reference = _db.reference()!;
  }
  static FireBaseDB? _this;
  static late f.FireBaseDB _db;
  late DatabaseReference _reference;

  /// Critical to get the fbKey
  Future<bool> initAsync() async {
    _fbKey = await fbUserKey();
    return _fbKey?.isNotEmpty ?? false;
  }

  ///
  late Map<String, dynamic> mDataArrayList;

  ///
  static bool mShowDeleted = false;

  ///
  String get key => _keyFld;
  final String _keyFld = 'KeyFld';

  ///
  DatabaseReference reference() => _reference;

  ///
  Future<bool> save(Map<String, dynamic> itemToDo) async {
    bool save;

    if (itemToDo.isEmpty) {
      //
      final String key = await insertRec(itemToDo);

      itemToDo[_keyFld] = key;

      save = key.isNotEmpty;
    } else {
      //
      final key = await updateRec(itemToDo);

      save = key.isNotEmpty;
    }

    if (save) {
      await Semaphore.write();
    }
    return save;
  }

  ///
  Future<String> insertRec(Map<String, dynamic> itemToDo) async {
    //
    String key = '';

    DatabaseReference dbRef;

    try {
      dbRef = tasksRef!;

      key = dbRef.push().key!;

//      mLastRowID = key;

      await dbRef.update(itemToDo);
    } catch (ex) {
      key = '';
    }
    return key;
  }

  ///
  Future<String> updateRec(Map<String, dynamic> rec) async {
    //
    String? key = '';

    // It's got to contain the 'firebase' key field
    if (!rec.containsKey(_keyFld)) {
      return key;
    }

    final Map<String, dynamic> foxRec = Map.from(rec);

    key = foxRec[_keyFld];

    foxRec.remove(_keyFld);

    try {
      //
      final DatabaseReference dbRef = tasksRef!;

      if (key == null || key.isEmpty) {
        key = dbRef.push().key;
        rec[_keyFld] = key;
      }

      await dbRef
          .update({key!: foxRec}).catchError((Object ex, StackTrace stack) {
        key = '';
        _db.setError(ex);
      });
    } catch (ex) {
      key = '';
      _db.setError(ex);
    }

    return key ?? '';
  }

  ///
  DatabaseReference get userRef =>
      databaseReference('users', WorkingController().uid);

  DatabaseReference? _anonymousRef;

  ///
  DatabaseReference get yourDeviceRef =>
      yourDevicesRef.child(DeviceInfo.deviceId);
  // DatabaseReference? _anonymousDeviceRef;

  ///
  DatabaseReference get yourDevicesRef => databaseReference('devices');

  ///
  DatabaseReference get favIconsRef => databaseReference('favicons');

  ///
  DatabaseReference? get tasksRef => databaseReference('tasks');
//  DatabaseReference? _tasksRef;

  ///
  DatabaseReference databaseReference(String? path, [String? id]) {
//
    if (path == null || path.trim().isEmpty) {
      path = '';
    } else {
      path = path.trim();
    }

    // infinite loop if instantiated in constructor.
    id ??= fbKey; //WorkingController().uid;

    if (id == 'dummy' || id.trim().isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }
    DatabaseReference ref;

    if (path.isEmpty) {
      ref = reference().child('dummy');
    } else if (id == null) {
      // Important to provide a reference that is not likely there in case called by deletion routine.
      ref = reference().child(path).child('dummy');
    } else {
      ref = reference().child(path).child(id);
    }
    return ref;
  }

  /// The Firebase Key value for the current user's Firebase records.
  String get fbKey => _fbKey ?? 'dummy';
  String? _fbKey;

  /// Assign the Firebase User key to a property
  Future<String> getFBUserKey() async {
    _fbKey = await fbUserKey();
    return _fbKey!;
  }

  ///
  Future<String> fbUserKey() async {
    final DatabaseReference dbRef = userRef.child('key');
    final online = App.isOnline; //await isOnline();
    if (!online) {
      return 'dummy';
    }
    final dataSnapshot = await dbRef.get();
    final value = dataSnapshot.value as String?;

    /// Can't be saving keys! Another person can use the same phone! gp
    // String key = Prefs.getString('fbKey') ?? '';
    // if (key.isEmpty) {
    //   if (value == null) {
    //     // Likely a brand new user.
    //     key = dbRef.push().key!;
    //   } else {
    //     key = value;
    //   }
    //   await Prefs.setString('fbKey', key);
    // }
    // if (value == null) {
    //   await dbRef.set(key);
    // }
    String key;
    if (value == null) {
      key = dbRef.push().key!;
      await dbRef.set(key);
    } else {
      key = value;
    }
    // Note, key and value may noy be the same
    // The user may have started out as anonymous
    return key;
  }

  ///
  Future<bool> createCurrentRecs() async {
    //
    if (Semaphore.got()) {
      return true;
    }

    final Query? queryRef = tasksRef?.orderByKey();

    if (queryRef == null) {
      return false;
    }

    DatabaseEvent? snapshot;
    try {
      // Just one query
      snapshot = await queryRef.once();
    } catch (ex) {
      snapshot = null;
    }

    if (snapshot == null) {
      return false;
    }

//    mDataArrayList = recArrayList(snapshot, mShowDeleted);

    return true;
  }

  /// Retrieve all the Firebase Task records
  Future<Map<String, dynamic>> records() async {
    // You have the recent data?
    if (Semaphore.got()) {
      return mDataArrayList;
    }

//    DatabaseEvent? data;
    DataSnapshot? data;

    final online = App.isOnline; //await isOnline();

    if (online) {
      try {
        data = await tasksRef?.get(); //.orderByKey().once();
      } catch (ex) {
        data = null;
        _db.setError(ex);
      }
    }

    final value = data?.value; //data?.snapshot.value;

    if (value == null || value is! Map) {
      mDataArrayList = {};
    } else {
      mDataArrayList = Map<String, dynamic>.from(value);
    }
    return mDataArrayList;
  }

  /// Retrieve any data records from the specified reference
  Future<Map<String, dynamic>> dataRecords(DatabaseReference? ref) async {
    //
    Map<String, dynamic> data = {};

    if (ref == null) {
      return data;
    }

    final online = App.isOnline; //await isOnline();

    DataSnapshot? db;

    if (online) {
      try {
        db = await ref.get();
      } catch (ex) {
        db = null;
        _db.setError(ex);
      }
    }

    final value = db?.value; //db?.snapshot.value;

    if (value != null && value is Map) {
      data = Map<String, dynamic>.from(value);
    }

    return data;
  }

  ///
  Future<Map<String, dynamic>> record(String key) async {
    final Map<String, dynamic> fbRecs = await records();
    Map<String, dynamic> rec;
    if (fbRecs[key] == null) {
      rec = {};
    } else {
      rec = Map<String, dynamic>.from(fbRecs[key]);
      rec['KeyFld'] = key;
    }
    return rec;
  }

//  // Not a getter since it returns a Future. gp
//  Future<Iterable<dynamic>> recordValues() async {
//    Map<dynamic, dynamic> recs = await records();
//    return recs?.values;
//  }

  ///
  static List<Map<String, String>> recArrayList(
      DataSnapshot? data, bool showDeleted) {
    final List<Map<String, String>> list = [];

    if (data == null || data.value is! LinkedHashMap) {
      return list;
    }

    ///
    final LinkedHashMap recs = data.value as LinkedHashMap;

    recs.map(MapEntry.new);

    // This is awesome! No middle man!
    final Object fieldsObj = Object();

    ///
    Map fldObj;

//    for (DataSnapshot shot : snapshot.getChildren()){
//
//    if(!shot.hasChildren()){
//
//    continue;
//    }
//
//    try{
//
//    fldObj = (Map) shot.getValue(fieldsObj.getClass());
//
//    for (Object key : fldObj.keySet()){
//
//    switch (fldObj.get(key).getClass().getName()){
//
//    case "java.lang.Boolean":
//
//    fldObj.put(key, (Boolean)fldObj.get(key) ? "true" : "false");
//
//    break;
//    case "java.lang.Long":
//
//    fldObj.put(key, Long.toString((Long)fldObj.get(key)));
//
//    break;
//    case "java.lang.Double":
//
//    fldObj.put(key, Double.toString((Double) fldObj.get(key)));
//    }
//    }
//    }catch (Exception ex){
//
//    ErrorHandler.logError(ex);
//
//    continue;
//    }
//
//    // Skip deleted records
//    if (!showDeleted && fldObj.containsKey("Deleted") &&
//    fldObj.get("Deleted").equals(Long.parseLong("1"))){
//
//    continue;
//    }
//
//    fldObj.put("key", shot.getKey());
//
//    list.add(fldObj);
//    }

    return list;
  }

  ///
  Future<bool> delete(final String? key) async {
    if (key == null || key.isEmpty) {
      return false;
    }
    final online = await _db.isOnline();
    if (!online) {
      return false;
    }
    bool delete;
    try {
      final DatabaseReference rec = tasksRef!.child(key);
      // Delete that record
      await rec.set(null);
      delete = true;
      // Retain the semaphore.
      await Semaphore.write();
    } catch (ex) {
      delete = false;
    }
    return delete;
  }

  ///
  static void didChangeAppLifecycleState(AppLifecycleState state) =>
      _db.didChangeAppLifecycleState(state);

  ///
  void dispose() {
    if (!App.hotReload) {
      _db.dispose();
      _this = null;
    }
  }

  // ignore: avoid_setters_without_getters
  set changedListener(void Function(DatabaseEvent event) func) =>
      _db.changedListener = func;

  // ignore: avoid_setters_without_getters
  set addedListener(void Function(DatabaseEvent event) func) =>
      _db.addedListener = func;

  // ///
  // Future<bool> isOnline() => Future.value(App.isOnline);

  ///
  static Future<void>? goOnline() => _db.goOnline();

  ///
  static Future<void>? goOffline() => _db.goOffline();

  ///
  Future<bool> loginUser(User? user) async {
    //
    bool login = user != null;

    if (login) {
      //
      if (user.isAnonymous) {
        _anonymousRef ??= userRef;
      } else {
        if (_anonymousRef != null) {
          // Bring over any anonymous records over.
          final switchOver = await switchOverTasks(_anonymousRef);
          if (switchOver) {
            await takeInTasks();
            await Controller().requery();
          }
        }
      }
    }

    if (login) {
      //
      login = updateUser();
    }
    return login;
  }

  ///
  bool updateUser() {
    bool update = true;
    final WorkingController con = WorkingController();
    try {
      final DatabaseReference dbRef = userRef.child('profile');
      dbRef.child('name').set(con.name);
      dbRef.child('isAnonymous').set(con.isAnonymous);
      dbRef.child('provider').set(con.provider);
      dbRef.child('new user').set(con.isNewUser);
      dbRef.child('photo').set(con.photo);
    } catch (ex) {
      update = false;
      con.getError(ex);
    }
    return update;
  }

  /// Tasks moved to registered account.
  Future<bool> switchOverTasks(DatabaseReference? ref) async {
    // Ensure the new user's fb key
    _fbKey = await fbUserKey();

    bool switchOver = ref != null;

    DataSnapshot dataSnapshot;

    String id = 'dummy';

    if (switchOver) {
      //
      dataSnapshot = await ref.child('key').get();

      final value = dataSnapshot.value;

      if (value != null && value is String) {
        id = value;
      }

      final DatabaseReference oldTasks = reference().child('tasks').child(id);

      final tasks = await dataRecords(oldTasks);

      // Are there any tasks?
      if (tasks.entries.isNotEmpty) {
        //
        final con = Controller();

        final Iterator<dynamic> it = tasks.entries.iterator;

        while (it.moveNext()) {
          //
          if (it.current.value is! Map) {
            continue;
          }

          final Map<String, dynamic> rec = Map.from(it.current.value);

          // They will have different primary keys.
          rec['rowid'] = null;

          final savedRec = await con.save(rec);

          switchOver = savedRec.isNotEmpty;

          if (!switchOver) {
            break;
          }
        }

        if (switchOver) {
          await deleteRef(oldTasks);
        }
      }
    }

    if (switchOver) {
      //
      final oldDevice = reference().child('devices').child(id);

      final moveDevice = await switchOverDevices(oldDevice);

      if (moveDevice) {
        await deleteRef(oldDevice);
      }
    }

    if (switchOver) {
      //
      await deleteRef(reference().child('sync').child(id));

      //
      await deleteRef(ref);
    }

    return switchOver;
  }

  /// Take in the registered accounts own tasks
  Future<bool> takeInTasks() async {
    // Ensure the new account's fb key
    _fbKey = await fbUserKey();

    final con = Controller();

    final DatabaseReference newTasks = tasksRef!;

    final tasks = await dataRecords(newTasks);

    // Are there any tasks?
    final takeIn = tasks.entries.isNotEmpty;

    for (final fbRec in tasks.entries) {
      //
      final Map<String, dynamic> rec = Map.from(fbRec.value);

      // They will have different primary keys.
      rec['rowid'] = null;

      // Specify the firebase record
      rec[_keyFld] = fbRec.key;

      await con.saveRec(rec);
    }

    return takeIn;
  }

  ///
  Future<bool> deleteRef(DatabaseReference? ref) async {
    bool delete = false;
    if (ref != null) {
      try {
        await ref.set(null);
        delete = true;
      } catch (ex) {
        delete = false;
      }
    }
    return delete;
  }

  Future<bool> switchOverDevices(DatabaseReference? oldRef) async {
    //
    bool switchOver;

    try {
      switchOver = await _switchOverDevices(oldRef);
    } catch (e) {
      switchOver = false;
    }
    return switchOver;
  }

  Future<bool> _switchOverDevices(DatabaseReference? oldRef) async {
    //
    Map<String, dynamic>? newDevices;

    bool switchOver = oldRef != null;

    if (switchOver) {
      // Are there any devices associated with the old account?
      newDevices = await refData(oldRef);

      switchOver = newDevices.isNotEmpty;
    }

    if (switchOver) {
      // Any devices with the logged in account?
      final oldDevices = await refData(yourDeviceRef);

      newDevices!.forEach((k, v) async {
        // The device is already used!
        // Record the most recent timestamp
        if (oldDevices[k] != null) {
          final oldTime = DateTime.tryParse(oldDevices[k]);
          final newTime = DateTime.tryParse(v);
          // If the 'logged in' account has more recent changes.
          if (oldTime != null &&
              newTime != null &&
              oldTime.compareTo(newTime) > 0) {
            v = oldDevices[k];
          }
        }
        await yourDevicesRef.update({k: v});
      });
    }

    return switchOver;
  }

  /// Retrieve the data from a particular Firebase location reference.
  Future<Map<String, dynamic>> refData(DatabaseReference? ref) =>
      refMap<String, dynamic>(ref);

  /// Retrieve a Map object from a particular Firebase location reference.
  Future<Map<K, V>> refMap<K, V>(DatabaseReference? ref) async {
    //
    final Map<K, V> refMap = {};

    if (ref != null) {
      //
      final dataEvent = await ref.once();

      final value = dataEvent.snapshot.value;

      if (value != null && value is Map) {
        try {
          refMap.addAll(Map<K, V>.from(value));
        } catch (e) {
          //
        }
      }
    }
    return refMap;
  }

  ///
  Future<void> dealWithAnonymous() async {
    _anonymousRef ??= userRef;
  }

  ///
  void setEvents(Query ref) => _db.setEvents(ref as DatabaseReference);
}
