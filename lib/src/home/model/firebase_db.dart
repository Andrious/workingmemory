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

import 'package:workingmemory/src/model.dart' show Semaphore;

import 'package:dbutils/firebase_db.dart' as f;

import 'package:workingmemory/src/controller.dart' show App, WorkingController;

import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, DatabaseReference, Event, Query;

import 'package:flutter/widgets.dart' show AppLifecycleState;

class FireBaseDB {
  factory FireBaseDB({
    void Function(DataSnapshot data) once,
    void Function(Event event) onChildAdded,
    void Function(Event event) onChildRemoved,
    void Function(Event event) onChildChanged,
    void Function(Event event) onChildMoved,
    void Function(Event event) onValue,
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
    var once,
    var onChildAdded,
    var onChildRemoved,
    var onChildChanged,
    var onChildMoved,
    var onValue,
  ) {
    _db = f.FireBaseDB.init(
      once: once,
      onChildAdded: onChildAdded,
      onChildRemoved: onChildRemoved,
      onChildChanged: onChildChanged,
      onChildMoved: onChildMoved,
      onValue: onValue,
    );
    _reference = _db.reference();
  }
  static FireBaseDB _this;
  static f.FireBaseDB _db;
  DatabaseReference _reference;
  Map<String, dynamic> mDataArrayList;

  static bool mShowDeleted = false;

  final String _keyFld = 'KeyFld';
  String get key => _keyFld;

  DatabaseReference reference() => _reference;

  Future<bool> save(Map<String, dynamic> itemToDo) async {
    bool save;

    if (itemToDo.isEmpty) {
      final String key = await insertRec(itemToDo);

      itemToDo['key'] = key;

      save = key.isNotEmpty;
    } else {
      final key = await updateRec(itemToDo);

      save = key.isNotEmpty;
    }

    if (save) {
      await Semaphore.write();
    }
    return save;
  }

  Future<String> insertRec(Map<String, dynamic> itemToDo) async {
    String key = '';

    DatabaseReference dbRef;

    try {
      dbRef = tasksRef;

      key = dbRef.push().key;

//      mLastRowID = key;

      await dbRef.update(itemToDo);
    } catch (ex) {
      key = '';
    }
    return key;
  }

  Future<String> updateRec(Map<String, dynamic> rec) async {
    String key = '';

    if (!rec.containsKey(_keyFld)) {
      return key;
    }

    final foxRec = Map.from(rec);

    key = foxRec[_keyFld];

    foxRec.remove(_keyFld);

    try {
      final DatabaseReference dbRef = tasksRef;

      if (key == null || key.isEmpty) {
        key = dbRef.push().key;
        rec[_keyFld] = key;
      }

      await dbRef.update({key: foxRec}).catchError((Exception ex) {
        key = '';
        _db?.setError(ex);
      });
    } catch (ex) {
      key = '';
      _db?.setError(ex);
    }

    return key;
  }

  DatabaseReference get userRef {
    // infinite loop if instantiated in constructor.
    String id = WorkingController().uid;

    if (id == null || id.trim().isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }

    DatabaseReference ref = reference().child('users');

    if (id == null) {
      ref = ref.child('dummy');
    } else {
      ref = ref.child(id);
    }
    return ref;
  }

  DatabaseReference get yourDeviceRef => yourDevicesRef.child(App.installNum);

  DatabaseReference get yourDevicesRef {
    // infinite loop if instantiated in constructor.
    String id = WorkingController().uid;

    if (id == null || id.trim().isEmpty) {
      id = null;
    } else {
      id = id.trim();
    }

    DatabaseReference ref;

    if (id == null) {
      // Important to provide a reference that is not likely there in case called by deletion routine.
      ref = reference().child('devices').child('dummy');
    } else {
      ref = reference().child('devices').child(id);
    }
    return ref;
  }

  DatabaseReference get tasksRef {
    DatabaseReference ref;

    // infinite loop if instantiated in constructor.
    final String id = WorkingController().uid;

    if (id.isEmpty) {
      ref = _db?.reference()?.child('tasks')?.child('dummy');
    } else {
      ref = _db?.reference()?.child('tasks')?.child(id);
    }
    return ref;
  }

  Future<bool> createCurrentRecs() async {
    if (Semaphore.got()) {
      return true;
    }

    final Query queryRef = tasksRef.orderByKey();

    if (queryRef == null) {
      return false;
    }

    DataSnapshot snapshot;
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

  Future<Map<String, dynamic>> records() async {
    // You have the recent data?
    if (Semaphore.got()) {
      return mDataArrayList;
    }

    DataSnapshot data;

    try {
      data = await tasksRef.orderByKey().once();
    } catch (ex) {
      data = null;
      _db?.setError(ex);
    }

    if (data?.value == null || data?.value is! Map) {
      mDataArrayList = {};
    } else {
      mDataArrayList = Map<String, dynamic>.from(data.value);
    }
    return mDataArrayList;
  }

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

  static List<Map<String, String>> recArrayList(
      DataSnapshot data, bool showDeleted) {
    final List<Map<String, String>> list = [];

    if (data == null || data.value is! LinkedHashMap) {
      return list;
    }

    final LinkedHashMap recs = data.value;

    recs.map((rec, that) => MapEntry(rec, that));

    // This is awesome! No middle man!
    final Object fieldsObj = Object();

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

  Future<bool> delete(final String key) async {
    if (key == null || key.isEmpty) {
      return false;
    }
    final online = await _db.isOnline();
    if (!online) {
      return false;
    }
    bool delete;
    try {
      final DatabaseReference rec = tasksRef.child(key);
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

  static void didChangeAppLifecycleState(AppLifecycleState state) =>
      _db.didChangeAppLifecycleState(state);

  void dispose() => _db.dispose();

  Future<bool> isOnline() => _db.isOnline();

  static Future<void> goOnline() => _db.goOnline();

  static Future<void> goOffline() => _db.goOffline();

  bool userStamp() {
    bool stamp = true;
    final WorkingController con = WorkingController();
    try {
      final DatabaseReference dbRef = userRef.child('profile');
      dbRef.child('name').set(con.name);
      dbRef.child('isAnonymous').set(con.isAnonymous);
      dbRef.child('provider').set(con.provider);
      dbRef.child('new user').set(con.isNewUser);
      dbRef.child('photo').set(con.photo);
    } catch (ex) {
      stamp = false;
      con.getError(ex);
    }
    return stamp;
  }
}
