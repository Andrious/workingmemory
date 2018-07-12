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

import 'package:workingmemory/src/model/db/FireBase.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:dbutils/sqllitedb.dart';

import 'package:sqflite/sqflite.dart';


class Model{

  FireBase _fireBase;

  DatabaseReference _tasksRef;

  var tToDo = ToDo();

  Future<bool> init() async {

    var init = await tToDo.init();

//    FireBase.dataRef('tasks');

    return init;
  }


  void dispose(){
    tToDo.dispose();
  }
}

class ToDo extends DBInterface {
  bool finished;

  static const TABLE_NAME = 'working';

  get name => 'ToDo';

  get version => 1;

  @override
  Future onCreate(Database db, int version) {

    return db.execute("""
       CREATE TABLE IF NOT EXISTS $TABLE_NAME(
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
}