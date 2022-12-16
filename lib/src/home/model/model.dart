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

import 'dart:async' show Future, unawaited;

import 'package:workingmemory/src/model.dart';

import 'package:workingmemory/src/view.dart';

///
class Model {
  ///
  factory Model() => _this ??= Model._();
  Model._();
  static Model? _this;
  late ToDo _tToDo;
  late CloudDB _cloud;
  late FireBaseDB _fbDB;
  late IconFavourites _iconDB;

  ///
  static const fbKeyField = 'KeyFld';

  ///flutter doctor -v
  Future<bool> initAsync() async {
    // Removed from constructor to prevent a stack overflow.
    _fbDB = FireBaseDB();
    _cloud = CloudDB();
    _tToDo = ToDo();
    _iconDB = IconFavourites();
    bool init = await _fbDB.initAsync();
    if (init && !kIsWeb) {
      // No database on the Web
      // Initialize the database
      init = await _tToDo.initAsync();
    }
    if (init) {
      if (!App.hotReload) {
        // firebase records
        await _fbDB.records();
        init = await _cloud.initAsync();
      }
    }
    if (init && !kIsWeb) {
      // Synchronize any records from other devices.
      // Nothing to sync, don't return false.
      await _cloud.sync();
    }
    return init;
  }

  ///
  Future<List<Map<String, dynamic>>> list() async {
    List<Map<String, dynamic>> recs = [];
    if (kIsWeb) {
      final Map<String, dynamic> map = await _fbDB.records();
      recs.add(map);
    } else {
      recs = await _tToDo.notDeleted(ordered: itemsOrdered());
    }
    return recs;
  }

  ///
  Future<List<Map<String, dynamic>>> listAll() => _tToDo.list();

  ///
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

  ///
  Item get item => _item ??= Item();
  Item? _item;

  ///
  String get defaultIcon {
    String? icon;
    final map = _tToDo.newrec[ToDo.TABLE_NAME];
    if (map != null) {
      icon = map['Icon'];
    }
    return icon ?? '0xe15b';
  }

  ///
  Future<List<Map<String, dynamic>>> listIcons() async {
    List<Map<String, dynamic>> list;
    if (kIsWeb) {
      list = await _iconDB.fbQuery();
    } else {
      list = await _iconDB.retrieve();
    }
    return list;
  }

  ///
  Future<bool> saveIcon(String icon) async {
    bool save;
    if (kIsWeb) {
      save = await _iconDB.saveRef(icon);
    } else {
      save = await _iconDB.saveRec(icon);
    }
    return save;
  }

  ///
  Future<bool> save(Map<String, dynamic> data) async {
    //
    Map<String, dynamic> newRec;
    bool save;
    bool newFireRec;

    if (kIsWeb) {
      //
      save = true;
      newRec = data;
      newFireRec = newRec[fbKeyField] == null;
      if (newFireRec) {
        newRec[fbKeyField] = null;
      }
    } else {
      //
      newRec = validRec(data);

      save = newRec.isNotEmpty;

      newFireRec = newRec[fbKeyField] == null;

      //   await _tToDo.runTxn(() async {
      //  Save to SQLite
      if (save) {
        save = await saveRec(newRec);
      }
    }
    // Save to Firebase
    if (save) {
      save = await saveFirebase(newRec);
    }
    // Supply the Firebase key field
    if (newFireRec && save && !kIsWeb) {
      save = await saveRec(newRec);
    }
    return save;
  }

  ///
  Future<bool> saveRec(Map<String, dynamic> data) async {
    final Map<String, dynamic> rec =
        await _tToDo.saveRec(ToDo.TABLE_NAME, data);
    return rec.isNotEmpty;
  }

  ///
  Future<bool> saveFirebase(Map<String, dynamic> newRec) async {
    // Don't bother is not online.
    final online = await _fbDB.isOnline();
    if (!online && !kIsWeb) {
      return _cloud.update({
        'id': newRec['rowid'],
        'key': newRec[_fbDB.key],
        'action': 'UPDATE',
        'timestamp': _cloud.timeStamp
      });
    }

    // Save to Firebase
    final bool save = await _fbDB.save(newRec);
    // Sync changes
    if (save) {
      await _cloud.insert(newRec[_fbDB.key], 'UPDATE');
    }
    return save;
  }

  /// Supply a 'new record' including the provided data.
  Map<String, dynamic> newRec(Map<String, dynamic> data) =>
      _tToDo.newRecord(data);

  ///
  Map<String, dynamic> validRec(Map<String, dynamic> data) {
    //
    final Map<String, dynamic> newRec = _tToDo.newRecord(data);

    if (!newRec.containsKey('rowid')) {
      return {};
    }

    if (!newRec.containsKey('Icon')) {
      newRec['Icon'] = _tToDo.newrec[ToDo.TABLE_NAME]!['Icon'];
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

    final DateTime dateTime = newRec['DateTime'];

    newRec['Item'] = item.trim();

    newRec['DateTime'] = dateTime.toString();

    newRec['DateTimeEpoch'] = dateTime.millisecondsSinceEpoch;

    return newRec;
  }

  ///
  Future<List<Map<String, dynamic>>>? getRecord(dynamic id) async => _tToDo
      .getRecord(ToDo.TABLE_NAME, id is String ? int.parse(id) : id as int);

  ///
  Future<bool> delete(Map<String, dynamic> data) async {
    //
    final Map<String, dynamic> newRec = _tToDo.newRecord(data);

    newRec['deleted'] = 1;

    final bool delete = await saveRec(newRec);

    final keyFld = newRec[fbKeyField];

    if (keyFld != null && delete) {
      // Remove from tasks Firebase collection.
      final bool syncDelete = await _fbDB.delete(keyFld);
      if (syncDelete) {
        // Record the deletion for the next sync.
        await _cloud.insert(newRec[fbKeyField], 'DELETE');
      } else {
        // Record the deletion for the next sync.
        await _cloud.delete(newRec['rowid'], keyFld);
      }
    }

    return delete;
  }

  ///
  Future<bool> unDelete(Map<String, dynamic> data) async {
    data['deleted'] = 0;
    return save(data);
  }

  ///
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

  ///
  void dispose() {
    if (!App.hotReload) {
      _fbDB.dispose();
      _cloud.dispose();
      _tToDo.disposed();
      _iconDB.dispose();
      _this = null;
    }
  }

  ///
  Future<void> sync() => _cloud.sync();

  ///
  Future<bool> reSync() async {
    // Retrieve all the local records.
    final List<Map<String, dynamic>> records = await listAll();
    final Map<dynamic, dynamic> fireDB = await _fbDB.records();
    String? key;

    // Add local records to Firebase
    for (final Map<String, dynamic> rec in records) {
      key = rec[fbKeyField];
      if (key != null && key.isNotEmpty && !fireDB.containsKey(key.trim())) {
        rec[fbKeyField] = null;
        await saveFirebase(rec);
      }
    }
    final synced = await _cloud.reSync();
    return synced;
  }

  /// Download any Firebase records down to the local database.
  Future<bool> recordDump() async {
    // Retrieve all the local records.
    final List<Map<String, dynamic>> records = await listAll();

    final List<Map<String, dynamic>> newFBRecs = [];

    final Set<String> keys = {};

    for (final Map<String, dynamic> rec in records) {
      if (rec[fbKeyField] != null) {
        // Collect the key field for the corresponding firebase record.
        keys.add(rec[fbKeyField]);
      } else {
        newFBRecs.add(rec);
      }
    }

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
          final dateTime = DateTime.tryParse(rec['DateTime']);
          if (dateTime != null) {
            final difference = DateTime.now().difference(dateTime);
            if (difference.inDays > 365) {
              unawaited(_fbDB.delete(it.current.key));
            }
          }
          continue;
        }
        rec[fbKeyField] = it.current.key;
        rec['rowid'] = null;
        // Add firebase records to the local database.
        save = await saveRec(rec);
      }
      if (save) {
        dump = true;
      }
    }

    // Add local records to Firebase
    for (final Map<String, dynamic> rec in records) {
      if (rec[fbKeyField] == null || rec[fbKeyField] == '') {
        rec[fbKeyField] = null;
        await saveFirebase(rec);
      }
    }
    return dump;
  }

  ///
  bool itemsOrdered([bool? ordered]) {
    if (ordered == null) {
      ordered = Settings.getOrder();
    } else {
      Settings.setOrder(ordered);
    }
    return ordered;
  }
}

///
class Item extends FieldWidgets {
  ///
  Item([Map? rec]) : super(object: rec, label: 'Item', value: rec!['Item']);

  @override
  void onSaved(dynamic v) {
    super.onSaved(v);
    object['Item'] = value = v;
  }

  @override
  String? onValidator(String? v) {
    super.onValidator(v);
    String? errorText;
    if (v!.isEmpty) {
      errorText = 'Item cannot be empty!';
    }
    return errorText;
  }
}

///
class Datetime extends FieldWidgets {
  ///
  Datetime([Map? rec])
      : super(object: rec, label: 'Date Time', value: rec!['DateTime']);

  @override
  void onSaved(dynamic v) {
    super.onSaved(v);
    object['DateTime'] = value = v;
  }
}

///
class Icon extends FieldWidgets {
  ///
  Icon([Map<String, dynamic>? rec])
      : super(object: rec, label: 'Icon', value: rec!['Icon']);

  @override
  void onSaved(dynamic v) {
    super.onSaved(v);
    object['Icon'] = value = v;
  }
}
