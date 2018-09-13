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

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import 'package:dbutils/sqllitedb.dart';

import 'package:sqflite/sqflite.dart';

import 'package:auth/Auth.dart';

import 'package:mvc/App.dart';




class Model{

//  FireBase _fireBase;

  DatabaseReference _tasksRef;

  var tToDo = ToDo();


  Future<List<Map>> list(){
//    return tToDo.notDeleted();
    return tToDo.list();
  }


  Future<bool> save(Map data) async {

    Map newRec = tToDo.newRecord(data);

    if(!newRec.containsKey('rowid'))
      return Future.value(false);

    if(!newRec.containsKey('Icon'))
      newRec['Icon'] = tToDo.newrec[ToDo.TABLE_NAME]['Icon'];

    if(!newRec.containsKey('Item'))
      return Future.value(false);

    if(!newRec.containsKey('DateTime'))
      return Future.value(false);

    if(newRec['DateTime'] is! DateTime)
      return Future.value(false);

    if(newRec['Item'] is! String)
      return Future.value(false);

    String item = newRec['Item'];

    if(item.isEmpty)
      return Future.value(false);

    if(newRec['DateTime'] is! DateTime)
      return Future.value(false);

    DateTime dateTime = newRec['DateTime'];

    tToDo.values[ToDo.TABLE_NAME]['rowid'] = newRec['rowid'];

    tToDo.values[ToDo.TABLE_NAME]['Icon'] = newRec['Icon'];

    tToDo.values[ToDo.TABLE_NAME]['Item'] = item.trim();

    tToDo.values[ToDo.TABLE_NAME]['DateTime'] = dateTime.toString();

    tToDo.values[ToDo.TABLE_NAME]['DateTimeEpoch'] = dateTime.millisecondsSinceEpoch;

    var rec = await tToDo.saveRec(ToDo.TABLE_NAME);

    var save = rec.isNotEmpty;

    if(save){
//      save = await ToDoFirebase.save(rec);
      ToDoFirebase.save(rec).then((saved){
        if(!saved) var ex = DBInterface.getError();
      });
    }

    return Future.value(save) ;
  }


  Future<bool> delete(Map data) async {

    if(!data.containsKey('rowid'))
      return Future.value(false);

    if(data['rowid'] is! int)
      return Future.value(false);

    if(data['rowid'] < 1)
      return Future.value(false);

    var rows = await tToDo.delete(ToDo.TABLE_NAME, data['rowid']);

    return Future.value(rows > 0) ;
  }

  
  Future<bool> init() {

    var init = tToDo.init();

    return init;
  }


  void dispose(){
    tToDo.dispose();
  }
}



class ToDo extends DBInterface {

  ToDo(){

    _create_not_deleted =
        "CREATE TEMP VIEW IF NOT EXISTS $NONDELETED_VIEW AS SELECT $keyField"
            + " AS _id, * FROM $TABLE_NAME"
            + " WHERE deleted = 0";

    _select_not_deleted = "SELECT $keyField AS _id, * FROM $NONDELETED_VIEW";
  }
  
  bool finished;

  static const TABLE_NAME = 'working';

  static const NONDELETED_VIEW = 'temp.notdeleted';

  get name => 'ToDo';

  get version => 1;

  String _create_not_deleted, _select_not_deleted;

  @override
  Future<bool> init() {
    var init = super.init().then((init){
      if(init) rawQuery(_create_not_deleted);
      return init;
    });
    return init;
  }

  @override
  Future onCreate(Database db, int version) {
    return db.execute("""
       CREATE TABLE IF NOT EXISTS $TABLE_NAME(
       Icon VARCHAR DEFAULT 0xe15b,
       Item VARCHAR, 
       KeyFld VARCHAR, 
       DateTime VARCHAR, 
       DateTimeEpoch Long, 
       TimeZone VARCHAR, 
       ReminderEpoch Long, 
       ReminderChk integer default 0, 
       LEDColor integer default 0, 
       Fired integer default 0, 
       deleted integer default 0)
    """);
  }

  Future<List<Map>> list() async {
    var list = await this.getTable(ToDo.TABLE_NAME);
    return list;
  }

  Future<List<Map>> notDeleted() async {
    var list = await rawQuery(_select_not_deleted);
    return list;
  }

  Map newRecord([Map data]){
    return super.newRec(ToDo.TABLE_NAME, data);
  }
}


class ToDoFirebase{

  
  static Future<bool> save(Map rec) async {

    var key = await updateRec(rec);

    return key.isNotEmpty;
  }


  static Future<String> updateRec(Map rec) async {

    String key = "";

    if(!rec.containsKey('KeyFld')) return Future.value(key);

    var foxRec = Map.from(rec);

    key = foxRec['KeyFld'];

    foxRec.remove('KeyFld');

    try{

      var dbRef = tasksRef(Auth.uid);

      if(key == null || key.isEmpty) key = dbRef.push().key;

      await dbRef.update({key: foxRec}).catchError((ex) {
        key = "";
        DBInterface.setError(ex);
      });
    } catch (ex){

      key = "";
      DBInterface.setError(ex);
    }

    return Future.value(key);
  }


  static DatabaseReference tasksRef(String id){

    DatabaseReference dbRef;

    if(id == null){

      dbRef = FireBase.reference().child("tasks").child("dummy");
    }else{

      dbRef = FireBase.reference().child("tasks").child(id);
    }
    return dbRef;
  }
}