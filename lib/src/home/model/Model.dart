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
    show CloudDB, FireBaseDB, SQLiteDB, Database;

import 'package:workingmemory/src/view.dart' show FieldWidgets;

class Model {
  factory Model() => _this ??= Model._();
  static Model _this;
  Model._() {
    _fbDB = FireBaseDB();
    _cloud = CloudDB();
    _tToDo = ToDo();
  }
  ToDo _tToDo;
  CloudDB _cloud;
  FireBaseDB _fbDB;

  static final fbKeyField = "KeyFld";

  Future<bool> initAsync() async {
    _fbDB.records();
    bool init = await _cloud.init();
    if (init) await _cloud.sync();
    if (init) init = await _tToDo.init();
    return init;
  }

  Future<List<Map<String, dynamic>>> list() => _tToDo.notDeleted();

  Future<Map<String, dynamic>> recordByKey(String key) async {
    List<Map<String, dynamic>> recs = await list();
    Map<String, dynamic> rec = Map();
    Iterator<Map<String, dynamic>> it = recs.iterator;
    while(it.moveNext()){
       if(it.current[fbKeyField] == key) {
         rec = it.current;
         break;
       }
    }
    return rec;
  }

  Item get item {
    if (_item == null) _item = Item();
    return _item;
  }

  Item _item;

  get defaultIcon => _tToDo.newrec[ToDo.TABLE_NAME]['Icon'];

  Future<bool> save(Map<String, dynamic> data) async {
    Map<String, dynamic> newRec = validRec(data);

    bool save = newRec.isNotEmpty;

    //   await _tToDo.runTxn(() async {
    //  Save to SQLite
    if (save) save = await saveRec(newRec);
    // Save to Firebase
    if (save) save = await _fbDB.save(newRec);
    // Sync changes
    if (save) _cloud.insert(newRec[_fbDB.key], "UPDATE");

    //   });
    return save;
  }

  Future<bool> saveRec(Map<String, dynamic> data) async {
//    DateTime dTime = data["DateTime"];
//    if(dTime != null){
//      data["DateTime"] = dTime.toUtc();
//    }
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

    bool delete = await saveRec(newRec);

    if (delete) {
      // Remove from tasks Firebase collection.
      bool syncDelete = await _fbDB.delete(newRec[fbKeyField]);
      if (syncDelete) {
        // Record the deletion for the next sync.
        _cloud.insert(newRec[fbKeyField], "DELETE");
      } else {
        // Record the deletion for the next sync.
        _cloud.delete(newRec['rowid'], newRec[fbKeyField]);
      }
    }

    return delete;
  }

  Future<bool> unDelete(Map<String, dynamic> data) async {
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

  void dispose() {
    _tToDo.disposed();
  }

  Future<void> sync() => _cloud.sync();

  void reSync() => _cloud.reSync();

  Future<bool> recordDump() async {
    List<Map<String, dynamic>> records = await list();
    // There's records already. Don't bother.
    if(records.isNotEmpty) return false;
    Set<String> keys = Set();
    records.forEach((Map<String, dynamic> rec) {
      keys.add(rec[fbKeyField]);
    });
    Map<dynamic, dynamic> fireDB = await _fbDB.records();

    bool dump = fireDB.isNotEmpty;

    Iterator<dynamic> it = fireDB.entries.iterator;

    while (it.moveNext()) {
      if (!keys.remove(it.current.key)) {
        if(it.current.value is! Map) continue;
        Map<String, dynamic> rec = Map.from(it.current.value);
        if(rec["deleted"] == 1) continue;
        rec[fbKeyField] = it.current.key;
        rec["rowid"] = null;
        dump = await saveRec(rec);
      }
      if (!dump) {
        break;
      }
    }
    return dump;
  }
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
  factory ToDo() => _this ??= ToDo._();
  ToDo._(){
    _cloud = CloudDB();
    _fbDB = FireBaseDB();
  }
  static ToDo _this;
  CloudDB _cloud;
  FireBaseDB _fbDB;

  String _selectAll, _selectNotDeleted, _selectDeleted;

  bool finished;

  static const TABLE_NAME = 'working';

  get name => 'ToDo';

  get version => 1;

  @override
  Future<bool> init() async {
    bool init = await super.init();
    String keyFld = await keyField(TABLE_NAME);
    _selectDeleted =
        "SELECT $keyFld, * FROM $TABLE_NAME" + " WHERE deleted = 1";
    _selectAll = "SELECT $keyFld, * FROM $TABLE_NAME";
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
      _cloud.timeStampDevice();
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
