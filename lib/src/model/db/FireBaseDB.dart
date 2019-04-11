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
import 'dart:collection';

import 'package:workingmemory/src/model/model.dart' show DBInterface, Semaphore;

import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, DatabaseReference;

import 'package:auth070/auth.dart' show Auth;

import 'package:firebase/firebase.dart' show FireBase;

class FireBaseDB {
  static LinkedHashMap mDataArrayList;

  static bool mShowDeleted = false;

  static Future<bool> save(Map rec) async {
    String key = await updateRec(rec);

    bool save = key.isNotEmpty;

    if (save) Semaphore.write();

    return save;
  }

  static Future<String> updateRec(Map rec) async {
    String key = "";

    if (!rec.containsKey('KeyFld')) return Future.value(key);

    var foxRec = Map.from(rec);

    key = foxRec['KeyFld'];

    foxRec.remove('KeyFld');

    try {
      DatabaseReference dbRef = FireBaseDB.tasksRef;

      if (key == null || key.isEmpty) {
        key = dbRef.push().key;
        rec['KeyFld'] = key;
      }

      await dbRef.update({key: foxRec}).catchError((ex) {
        key = "";
        DBInterface.setError(ex);
      });
    } catch (ex) {
      key = "";
      DBInterface.setError(ex);
    }

    return Future.value(key);
  }

  static DatabaseReference get tasksRef {
    DatabaseReference dbRef;

    String id = Auth.uid;

    if (id == null) {
      dbRef = FireBase.reference().child("tasks").child("dummy");
    } else {
      dbRef = FireBase.reference().child("tasks").child(id);
    }
    return dbRef;
  }

  static Future<LinkedHashMap> records() async {

    if (Semaphore.got()) return mDataArrayList;

    DataSnapshot data;

    try {

      data =
          await FireBaseDB.tasksRef.orderByKey().once().catchError((ex) {

        DBInterface.setError(ex);
      });
    } catch (ex) {

      data = null;
      DBInterface.setError(ex);
    }

    if (data == null) {

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
}
