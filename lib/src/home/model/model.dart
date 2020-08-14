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
///          Created  23 Jun 2018
///

import 'dart:async' show Future;

import 'package:workingmemory/src/controller.dart' show App, WorkingController;

import 'package:workingmemory/src/model.dart'
    show CloudDB, Database, FireBaseDB, Settings, SQLiteDB;

import 'package:workingmemory/src/view.dart' show FieldWidgets;

class Model {
  factory Model() => _this ??= Model._();
  Model._() {
    _fbDB = FireBaseDB();
    _cloud = CloudDB();
    _tToDo = ToDo();
  }
  static Model _this;

  ToDo _tToDo;
  CloudDB _cloud;
  FireBaseDB _fbDB;

  static const fbKeyField = 'KeyFld';

  Future<bool> initAsync() async {
    await _fbDB.records();
    bool init = await _cloud.init();
    if (init) {
      await _cloud.sync();
    }
    if (init) {
      init = await _tToDo.init();
    }
    return init;
  }

  Future<List<Map<String, dynamic>>> list() =>
      _tToDo.notDeleted(ordered: itemsOrdered());

  Future<List<Map<String, dynamic>>> listAll() => _tToDo.list();

  Future<Map<String, dynamic>> recordByKey(String key) async {
    final List<Map<String, dynamic>> recs = await list();
    Map<String, dynamic> rec = {};
    final Iterator<Map<String, dynamic>> it = recs.iterator;
    while (it.moveNext()) {
      if (it.current[fbKeyField] == key) {
        rec = it.current;
        break;
      }
    }
    return rec;
  }

  Item get item => _item ??= Item();
  Item _item;

  String get defaultIcon {
    String icon;
    final map = _tToDo.newrec[ToDo.TABLE_NAME];
    if (map != null) {
      icon = map['Icon'];
    }
    return icon ?? '0xe15b';
  }

  Future<List<Map<String, dynamic>>> listIcons() => _tToDo.icons();

  Future<bool> saveIcon(String icon) => _tToDo.saveIcon(icon);

  Future<bool> save(Map<String, dynamic> data) async {
    final Map<String, dynamic> newRec = validRec(data);

    bool save = newRec.isNotEmpty;

    //   await _tToDo.runTxn(() async {
    //  Save to SQLite
    if (save) {
      save = await saveRec(newRec);
    }
    // Save to Firebase
    if (save) {
      save = await saveFirebase(newRec);
    }

    return save;
  }

  Future<bool> saveRec(Map<String, dynamic> data) async {
//    DateTime dTime = data["DateTime"];
//    if(dTime != null){
//      data["DateTime"] = dTime.toUtc();
//    }

    final Map<String, dynamic> rec =
        await _tToDo.saveRec(ToDo.TABLE_NAME, data);
    return rec.isNotEmpty;
  }

  Future<bool> saveFirebase(Map<String, dynamic> newRec) async {
    // Save to Firebase
    final bool save = await _fbDB.save(newRec);
    // Sync changes
    if (save) {
      await _cloud.insert(newRec[_fbDB.key], 'UPDATE');
    }
    return save;
  }

  Map<String, dynamic> validRec(Map<String, dynamic> data) {
    final Map<String, dynamic> newRec = _tToDo.newRecord(data);

    if (!newRec.containsKey('rowid')) {
      return {};
    }

    if (!newRec.containsKey('Icon')) {
      newRec['Icon'] = _tToDo.newrec[ToDo.TABLE_NAME]['Icon'];
    }

    if (!newRec.containsKey('Item')) {
      return {};
    }

    if (!newRec.containsKey('DateTime')) {
      return {};
    }

    if (newRec['DateTime'] is String) {
      newRec['DateTime'] = DateTime.parse(newRec['DateTime']);
    }

    if (newRec['DateTime'] is! DateTime) {
      return {};
    }
    if (newRec['Item'] is! String) {
      return {};
    }

    final String item = newRec['Item'];

    if (item.isEmpty) {
      return {};
    }

    if (newRec['DateTime'] is! DateTime) {
      return {};
    }

    final DateTime dateTime = newRec['DateTime'];

    newRec['Item'] = item.trim();

    newRec['DateTime'] = dateTime.toString();

    newRec['DateTimeEpoch'] = dateTime.millisecondsSinceEpoch;

    return newRec;
  }

  Future<List<Map<String, dynamic>>> getRecord(String id) async =>
      _tToDo.getRecord(ToDo.TABLE_NAME, int.parse(id));

  Future<bool> delete(Map<String, dynamic> data) async {
    final Map newRec = _tToDo.newRecord(data);

    newRec['deleted'] = 1;

    final bool delete = await saveRec(newRec);

    if (delete) {
      // Remove from tasks Firebase collection.
      final bool syncDelete = await _fbDB.delete(newRec[fbKeyField]);
      if (syncDelete) {
        // Record the deletion for the next sync.
        await _cloud.insert(newRec[fbKeyField], 'DELETE');
      } else {
        // Record the deletion for the next sync.
        await _cloud.delete(newRec['rowid'], newRec[fbKeyField]);
      }
    }

    return delete;
  }

  Future<bool> unDelete(Map<String, dynamic> data) async {
    data['deleted'] = 0;
    return save(data);
  }

  Future<bool> deleteRec(String key) async {
    final List<Map<String, dynamic>> rec =
        await _tToDo.getRecord(ToDo.TABLE_NAME, int.parse(key));

    if (rec.isEmpty) {
      return false;
    }

    rec[0]['deleted'] = 1;

    final bool delete = await save(rec[0]);

    return delete;
  }

  static void _dataMap(String key, Map map, Map records) {
    // Do something with this later.
//    recs.forEach((k, v){_dataMap(k,v,records);});

    final Map<String, dynamic> rec = {};

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
    final List<Map<String, dynamic>> records = await listAll();
//    // There's records already. Don't bother.
//    if (records.isNotEmpty) return false;

    final List<Map<String, dynamic>> newFBRecs = [];

    final Set<String> keys = {};
    records.forEach((Map<String, dynamic> rec) {
      if (rec[fbKeyField] != null) {
        keys.add(rec[fbKeyField]);
      } else {
        newFBRecs.add(rec);
      }
    });

    final Map<dynamic, dynamic> fireDB = await _fbDB.records();

    bool dump = false; //= fireDB.isNotEmpty;
    bool save = false;
    final Iterator<dynamic> it = fireDB.entries.iterator;

    // Insert Firebase records.
    while (it.moveNext()) {
      if (!keys.remove(it.current.key)) {
        if (it.current.value is! Map) {
          continue;
        }
        final Map<String, dynamic> rec = Map.from(it.current.value);
        if (rec['deleted'] == 1) {
          continue;
        }
        rec[fbKeyField] = it.current.key;
        rec['rowid'] = null;
        save = await saveRec(rec);
      }
      if (save) {
        dump = true;
      }
    }
    // Add local records to Firebase
    records.forEach((Map<String, dynamic> rec) async {
      if (rec[fbKeyField] == null || rec[fbKeyField] == '') {
        await saveFirebase(rec);
      }
    });
    return dump;
  }

  bool itemsOrdered([bool ordered]) {
    if (ordered == null) {
      ordered = Settings.getOrder();
    } else {
      Settings.setOrder(ordered);
    }
    return ordered;
  }
}

class Item extends FieldWidgets {
  Item([Map rec]) : super(object: rec, label: 'Item', value: rec['Item']);

  @override
  void onSaved(v) => object['Item'] = value = v;

  @override
  String onValidator(String v) {
    String errorText;
    if (v.isEmpty) {
      errorText = 'Item cannot be empty!';
    }
    return errorText;
  }
}

class Datetime extends FieldWidgets {
  Datetime([Map rec])
      : super(object: rec, label: 'Date Time', value: rec['DateTime']);

  @override
  void onSaved(v) => object['DateTime'] = value = v;
}

class Icon extends FieldWidgets {
  Icon([Map rec]) : super(object: rec, label: 'Icon', value: rec['Icon']);

  @override
  void onSaved(v) => object['Icon'] = value = v;
}

class ToDo extends SQLiteDB {
  factory ToDo() => _this ??= ToDo._();
  ToDo._() {
    _cloud = CloudDB();
    _fbDB = FireBaseDB();
    _iconDB = _IconFavourites(this);
  }
  static ToDo _this;
  CloudDB _cloud;
  FireBaseDB _fbDB;
  _IconFavourites _iconDB;

  String _selectAll, _selectNotDeleted, _selectDeleted;

  bool finished;

  static const TABLE_NAME = 'working';

  @override
  String get name => 'ToDo';

  @override
  int get version => 1;

  String _keyFld;

  @override
  Future<bool> init() async {
    //
    final init = await super.init();

    _keyFld = await keyField(TABLE_NAME);

    _selectNotDeleted =
        'SELECT $_keyFld, * FROM $TABLE_NAME" + " WHERE deleted = 0';

    _selectDeleted =
        'SELECT $_keyFld, * FROM $TABLE_NAME" + " WHERE deleted = 1';

    _selectAll = 'SELECT $_keyFld, * FROM $TABLE_NAME';

    return init;
  }

  @override
  Future<void> onCreate(Database db, int version) async {
    //
    await db.execute('''
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
       AlarmId integer default -1,
       Fired integer default 0, 
       deleted integer default 0)
    ''');

    await db.execute(_IconFavourites.CREATE_TABLE);
  }

  @override
  Future<int> onConfigure(Database db) async {
    //
    final version = await db.getVersion();

    if (version == 0) {
      await _cloud.timeStampDevice();
    }
    return version;
  }

  @override

  /// Upgrade to a higher version.
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) {
    return Future.value();
  }

  Future<List<Map<String, dynamic>>> list() => getTable(ToDo.TABLE_NAME);

  Future<List<Map<String, dynamic>>> notDeleted({bool ordered = false}) {
    var select = _selectNotDeleted;
    if (ordered) {
      select = '$select order by datetime(DateTime)';
    }
    return rawQuery(select);
  }

  Future<List<Map<String, dynamic>>> isDeleted({bool ordered = false}) {
    var select = _selectDeleted;
    if (ordered) {
      select += ' order by datetime(DateTime)';
    }
    return rawQuery(select);
  }

  Map<String, dynamic> newRecord([Map<String, dynamic> data]) =>
      super.newRec(ToDo.TABLE_NAME, data);

  Future<List<Map<String, dynamic>>> icons() => _iconDB.query();

  Future<bool> saveIcon(String icon) => _iconDB.saveRec(icon);
}

class _IconFavourites {
  _IconFavourites(this.db);
  final SQLiteDB db;

  static const TABLE_NAME = 'icons';

  static const CREATE_TABLE = '''
       CREATE TABLE IF NOT EXISTS $TABLE_NAME(
       icon VARCHAR DEFAULT 0xe15b,
       deleted INTEGER DEFAULT 0)
    ''';

  Future<List<Map<String, dynamic>>> list() => db.getTable(TABLE_NAME);

  Future<List<Map<String, dynamic>>> query([String icon]) {
//    String keyFld = await db.keyField(_IconFavourites.TABLE_NAME);
    if (icon == null) {
      icon = '';
    } else {
      icon = ' icon = "$icon" AND ';
    }
    final String select =
        'SELECT icon FROM ${_IconFavourites.TABLE_NAME} WHERE $icon deleted = 0';
    return db.rawQuery(select);
  }

  Future<bool> saveRec(String icon) async {
    //
    final icons = await query(icon);
    if (icons.isNotEmpty) {
      return true;
    }
    final rec = await db.saveRec(TABLE_NAME, {'icon': icon});
    return rec.isNotEmpty;
  }
}
