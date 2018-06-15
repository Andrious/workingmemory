import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:dbutils/sqllitedb.dart';


class WorkingDB extends DBInterface{

  @override
  get name => 'working.db';

  @override
  get version => 1;

  @override
  Future onCreate(Database db, int version) async {

    await db.execute("""
            CREATE TABLE story (
              id INTEGER PRIMARY KEY, 
              user_id INTEGER NOT NULL,
              title TEXT NOT NULL,
              body TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES user (id) 
                ON DELETE NO ACTION ON UPDATE NO ACTION
            )""");

    await db.execute("""
            CREATE TABLE user (
              id INTEGER PRIMARY KEY,
              username TEXT NOT NULL UNIQUE
            )""");

//    await db.execute("""
//            CREATE TABLE working (
//              id INTEGER PRIMARY KEY
//              ,ToDoItem VARCHAR
//              ,ToDoKey VARCHAR
//              ,ToDoDateTime VARCHAR
//              ,ToDoDateTimeEpoch Long
//              ,ToDoTimeZone VARCHAR
//              ,ToDoReminderEpoch Long
//              ,ToDoReminderChk integer default 0
//              ,ToDoLEDColor integer default 0
//              ,ToDoFired integer default 0
//              ,deleted integer default 0
//            )""");
  }
}