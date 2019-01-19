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

import 'package:mvc_application/model.dart';

import 'package:mvc_application/view.dart' show Field, Item;

import 'package:workingmemory/src/model/db/FireBaseDB.dart';

import 'package:workingmemory/src/model/db/CloudDB.dart';

class Model {
  factory Model() {
    if (_this == null) _this = Model._();
    return _this;
  }
  static Model _this;

  Model._() {
    _tToDo = ToDo();
    FireBaseDB.records();
  }
  ToDo _tToDo;

  Future<List<Map<String, dynamic>>> list() => _tToDo.notDeleted();

  Item get item{
    if(_item == null) _item = Item();
    return _item;
  }
  Item _item;

  get defaultIcon => _tToDo.newrec[ToDo.TABLE_NAME]['Icon'];

  Future<bool> save(Map data) async {
    Map newRec = _tToDo.newRecord(data);

    if (!newRec.containsKey('rowid')) return Future.value(false);

    if (!newRec.containsKey('Icon'))
      newRec['Icon'] = _tToDo.newrec[ToDo.TABLE_NAME]['Icon'];

    if (!newRec.containsKey('Item')) return Future.value(false);

    if (!newRec.containsKey('DateTime')) return Future.value(false);

    if (newRec['DateTime'] is String) {
      newRec['DateTime'] = DateTime.parse(newRec['DateTime']);
    }

    if (newRec['DateTime'] is! DateTime) return Future.value(false);

    if (newRec['Item'] is! String) return Future.value(false);

    String item = newRec['Item'];

    if (item.isEmpty) return Future.value(false);

    if (newRec['DateTime'] is! DateTime) return Future.value(false);

    DateTime dateTime = newRec['DateTime'];

    _tToDo.values[ToDo.TABLE_NAME]['rowid'] = newRec['rowid'];

    _tToDo.values[ToDo.TABLE_NAME]['Icon'] = newRec['Icon'];

    _tToDo.values[ToDo.TABLE_NAME]['Item'] = item.trim();

    _tToDo.values[ToDo.TABLE_NAME]['DateTime'] = dateTime.toString();

    _tToDo.values[ToDo.TABLE_NAME]['DateTimeEpoch'] =
        dateTime.millisecondsSinceEpoch;

    _tToDo.values[ToDo.TABLE_NAME]['deleted'] = newRec['deleted'];

    bool save = await FireBaseDB.save(_tToDo.values[ToDo.TABLE_NAME]);

    if (save) {
      Map rec = await _tToDo.saveRec(ToDo.TABLE_NAME);
      save = rec.isNotEmpty;
    }
    return Future.value(save);
  }

  Future<bool> delete(Map data) async {
    Map newRec = _tToDo.newRecord(data);

    newRec['deleted'] = 1;

    bool delete = await save(newRec);

    if (delete) {
      FireBaseDB.delete(newRec['KeyFld']);
    }
    return delete;

//    var rows = await _tToDo.delete(ToDo.TABLE_NAME, data['rowid']);

//    return Future.value(rows > 0) ;
  }

  Future<bool> undelete(Map data) async {

    data['deleted'] = 0;

    return save(data);
  }

  static void _dataMap(String key, Map map, Map records) {
    // Do something with this later.
//    recs.forEach((k, v){_dataMap(k,v,records);});

    Map rec = Map<String, dynamic>();

    map.forEach((k, v) {
      rec[k] = v;
    });

    records[key] = rec;
  }

  Future<bool> initState() async {
    bool init = await _tToDo.init();
    sync();
    return init;
  }

  void dispose() {
    _tToDo.disposed();
  }

  void sync() {
    CloudDB.sync();
  }
}

class Item extends Field{
  Item([Map rec])
      : super(object: rec, label: 'Item', value: rec['Item']);

  void onSaved(v) => object['Item'] = value = v;

  @override
  String onValidator(String v) {
    String errorText;
    if(v.isEmpty) errorText = "Item cannot be empty!";
    return errorText;
  }
}

class Datetime extends Field{
  Datetime([Map rec])
      : super(object: rec, label: 'Date Time', value: rec['DateTime']);

  void onSaved(v) => object['DateTime'] = value = v;
}

class Icon extends Field{
  Icon([Map rec])
      : super(object: rec, label: 'Icon', value: rec['Icon']);

  void onSaved(v) => object['Icon'] = value = v;
}

class ToDo extends DBInterface {

  ToDo(){
    _selectNotDeleted = "SELECT $keyField, * FROM $TABLE_NAME" +
        " WHERE deleted = 0";
    _selectDeleted = "SELECT $keyField, * FROM $TABLE_NAME" +
        " WHERE deleted = 1";
    _selectAll = "SELECT $keyField, * FROM $TABLE_NAME";
  }
  String _selectAll, _selectNotDeleted, _selectDeleted;

  bool finished;

  static const TABLE_NAME = 'working';

  get name => 'ToDo';

  get version => 1;

  @override
  Future<bool> init() {
    var init = super.init().then((init) {
//      if (init) notDeleted();
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

  @override
  Future onConfigure(Database db) async {
    int version = await db.getVersion();
    if (version == 0) {
      CloudDB.setDeviceDirectory();
    }
    return version;
  }

  Future<List<Map>> list() => this.getTable(ToDo.TABLE_NAME);

  Future<List<Map<String, dynamic>>> notDeleted() => rawQuery(_selectNotDeleted);

  Map newRecord([Map data]) => super.newRec(ToDo.TABLE_NAME, data);
}
