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

import 'dart:async' show Future;

import 'package:workingmemory/src/model.dart'
    show CloudDB, SQLiteDB, Database;

import 'package:workingmemory/src/view.dart' show FieldWidgets;

import 'package:workingmemory/src/model/db/FireBaseDB.dart';

import 'package:workingmemory/src/model/db/CloudDB.dart';

class Model {
  factory Model() => _this ??= Model._();
  static Model _this;

  Model._() {
    _tToDo = ToDo();
    FireBaseDB.records();
  }
  ToDo _tToDo;

  Future<List<Map<String, dynamic>>> list() => _tToDo.notDeleted();

  Item get item {
    if (_item == null) _item = Item();
    return _item;
  }

  Item _item;

  get defaultIcon => _tToDo.newrec[ToDo.TABLE_NAME]['Icon'];

  Future<bool> save(Map<String, dynamic> data) async {
    Map<String, dynamic> newRec = validRec(data);

    bool save = newRec.isNotEmpty;

    if (save) save = await FireBaseDB.save(newRec);

    if (save) save = await saveRec(newRec);

    if (save) CloudDB.insert(newRec[FireBaseDB.key], "UPDATE");

    return Future.value(save);
  }

  Future<bool> saveRec(Map<String, dynamic> data) async {
    Map<String, dynamic> rec = await _tToDo.saveRec(ToDo.TABLE_NAME, data);
    return rec.isNotEmpty;
  }

  Map<String, dynamic> validRec(Map<String, dynamic> data) {
    Map<String, dynamic> newRec = _tToDo.newRecord(data);

    if (!newRec.containsKey('rowid')) return {};

    if (!newRec.containsKey('Icon'))
      newRec['Icon'] = _tToDo.newrec[ToDo.TABLE_NAME]['Icon'];

    if (!newRec.containsKey('Item')) return {};

    if (!newRec.containsKey('DateTime')) return {};

    if (newRec['DateTime'] is String)
      newRec['DateTime'] = DateTime.parse(newRec['DateTime']);

    if (newRec['DateTime'] is! DateTime) return {};

    if (newRec['Item'] is! String) return {};

    String item = newRec['Item'];

    if (item.isEmpty) return {};

    if (newRec['DateTime'] is! DateTime) return {};

    DateTime dateTime = newRec['DateTime'];

    newRec['Item'] = item.trim();

    newRec['DateTime'] = dateTime.toString();

    newRec['DateTimeEpoch'] = dateTime.millisecondsSinceEpoch;

    return newRec;
  }

  Future<List<Map<String, dynamic>>> getRecord(String id) async =>
      _tToDo.getRecord(ToDo.TABLE_NAME, int.parse(id));

  Future<bool> delete(Map<String, dynamic> data) async {
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

  Future<bool> undelete(Map<String, dynamic> data) async {
    data['deleted'] = 0;
    return save(data);
  }

  Future<bool> deleteRec(String key) async {
    List<Map<String, dynamic>> rec =
        await _tToDo.getRecord(ToDo.TABLE_NAME, int.parse(key));

    if (rec.length == 0) return false;

    rec[0]['deleted'] = 1;

    bool delete = await save(rec[0]);

    return delete;
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

  void reSync() => CloudDB.reSync();
}

class Item extends FieldWidgets {
  Item([Map rec]) : super(object: rec, label: 'Item', value: rec['Item']);

  void onSaved(v) => object['Item'] = value = v;

  @override
  String onValidator(String v) {
    String errorText;
    if (v.isEmpty) errorText = "Item cannot be empty!";
    return errorText;
  }
}

class Datetime extends FieldWidgets {
  Datetime([Map rec])
      : super(object: rec, label: 'Date Time', value: rec['DateTime']);

  void onSaved(v) => object['DateTime'] = value = v;
}

class Icon extends FieldWidgets {
  Icon([Map rec]) : super(object: rec, label: 'Icon', value: rec['Icon']);

  void onSaved(v) => object['Icon'] = value = v;
}

class ToDo extends SQLiteDB {
  ToDo() {
    keyField(TABLE_NAME).then((String keyFld){
      _selectDeleted = "SELECT $keyFld, * FROM $TABLE_NAME" +
          " WHERE deleted = 1";
      _selectAll =  "SELECT $keyFld, * FROM $TABLE_NAME";
    });
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

  Future<List<Map<String, dynamic>>> list() => this.getTable(ToDo.TABLE_NAME);

  Future<List<Map<String, dynamic>>> notDeleted() async {
    String keyFld = await keyField(TABLE_NAME);
    _selectNotDeleted =
        "SELECT $keyFld, * FROM $TABLE_NAME" + " WHERE deleted = 0";
    return rawQuery(_selectNotDeleted);
  }

  Map<String, dynamic> newRecord([Map<String, dynamic> data]) =>
      super.newRec(ToDo.TABLE_NAME, data);
}
