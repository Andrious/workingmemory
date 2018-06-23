import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:dbutils/sqllitedb.dart';

class Model extends DBInterface{

  get name => 'todo.db';

  get version => 1;


  @override
  Future onCreate(Database db, int version) async {

     await db.execute("""
        CREATE TABLE Working(
           item VARCHAR, 
           key VARCHAR, 
           datetime VARCHAR, 
           epoch LONG, 
           timezone VARCHAR, 
           reminder LONG, 
           checked INTEGER DEFAULT 0,
           color INTEGER DEFAULT 0,
           fired INTEGER DEFAULT 0, 
           deleted INTEGER DEFAULT 0
        )
     """);
  }


  Future<bool> init() async {

    return Future.value(true);
  }

  dispose(){
    
  }
}


class Todo {
  bool finished;
  String name;

  Todo(this.finished, this.name);
}