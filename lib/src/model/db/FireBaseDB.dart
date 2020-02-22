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
///          Created  29 Nov 2018
///
import 'dart:async' show Future, StreamSubscription;

import 'dart:collection' show LinkedHashMap;

import 'package:workingmemory/src/model.dart' show Semaphore;

import 'package:mvc_application/model.dart' as f;

import 'package:workingmemory/src/controller.dart' show App, WorkingMemoryApp;

import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, DatabaseReference, Event, Query;

import 'package:flutter/widgets.dart' show AppLifecycleState;

class FireBaseDB {
  factory FireBaseDB.init({
    void once(DataSnapshot data),
    void onChildAdded(Event event),
    void onChildRemoved(Event event),
    void onChildChanged(Event event),
    void onChildMoved(Event event),
    void onValue(Event event),
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
  static DatabaseReference _reference;

  static LinkedHashMap mDataArrayList;

  static bool mShowDeleted = false;

  static String _keyFld = "KeyFld";
  static String get key => _keyFld;

  static DatabaseReference reference() => _reference;

  static Future<bool> save(Map<String, dynamic> itemToDo) async {
    bool save;

    if (itemToDo.isEmpty) {
      String key = await insertRec(itemToDo);

      itemToDo['key'] = key;

      save = key.isNotEmpty;
    } else {
      var key = await updateRec(itemToDo);

      save = key.isNotEmpty;
    }

    if (save) {
      Semaphore.write();
    }
    return save;
  }

  static Future<String> insertRec(Map<String, dynamic> itemToDo) async {
    String key = "";

    DatabaseReference dbRef;

    try {
      dbRef = tasksRef;

      key = dbRef.push().key;

//      mLastRowID = key;

      await dbRef.update(itemToDo);
    } catch (ex) {
      key = "";
    }
    return key;
  }

  static Future<String> updateRec(Map rec) async {
    String key = "";

    if (!rec.containsKey(_keyFld)) return Future.value(key);

    var foxRec = Map.from(rec);

    key = foxRec[_keyFld];

    foxRec.remove(_keyFld);

    try {
      DatabaseReference dbRef = FireBaseDB.tasksRef;

      if (key == null || key.isEmpty) {
        key = dbRef.push().key;
        rec[_keyFld] = key;
      }

      await dbRef.update({key: foxRec}).catchError((ex) {
        key = "";
        _db?.setError(ex);
      });
    } catch (ex) {
      key = "";
      _db?.setError(ex);
    }

    return Future.value(key);
  }

  static DatabaseReference get tasksRef {
    DatabaseReference ref;

    String id = WorkingMemoryApp.uid;

    if (id.isEmpty) {
      ref = _db?.reference()?.child("tasks")?.child("dummy");
    } else {
      ref = _db?.reference()?.child("tasks")?.child(id);
    }
    return ref;
  }

  Future<bool> createCurrentRecs() async {
    if (Semaphore.got()) {
      return true;
    }

    Query queryRef = tasksRef.orderByKey();

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

  static Future<LinkedHashMap> records() async {
    if (Semaphore.got()) return mDataArrayList;

    DataSnapshot data;

    try {
      data = await FireBaseDB.tasksRef.orderByKey().once().catchError((ex) {
        _db?.setError(ex);
      });
    } catch (ex) {
      data = null;
      _db?.setError(ex);
    }

    if (data?.value == null || data?.value is! Map) {
      mDataArrayList = LinkedHashMap<dynamic, dynamic>();
    } else {
      mDataArrayList = data.value;
    }
    return mDataArrayList;
  }

  static List<Map<String, String>> recArrayList(
      DataSnapshot data, bool showDeleted) {
    List list = List<Map<String, String>>();

    if (data == null || data.value is! LinkedHashMap) {
      return list;
    }

    LinkedHashMap recs = data.value;

    recs.map((rec, that) => new MapEntry(rec, that));

    // This is awesome! No middle man!
    Object fieldsObj = new Object();

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

  static Future<void> delete(final String key) async {
    if (key == null || key.isEmpty) return;

    DatabaseReference rec = FireBaseDB.tasksRef.child(key);

    // Delete that record
    rec.set(null);

    // Retain the semaphore.
    Semaphore.write();
  }

  static void didChangeAppLifecycleState(AppLifecycleState state) =>
      _db.didChangeAppLifecycleState(state);

  void dispose() => _db.dispose();

  static void goOnline() => _db.goOnline();

  static void goOffline() => _db.goOffline();
}
