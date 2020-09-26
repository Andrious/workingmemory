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
///          Created  15 Nov 2018

import 'package:workingmemory/src/model.dart';

class SyncDB extends SQLiteDB {
  factory SyncDB() => _this ??= SyncDB._();
  SyncDB._(): super();
  static SyncDB _this;

  final String _table = 'sync';

  final int _version = 1;

  @override
  String get name => _table;

  @override
  int get version => _version;

  bool get isOpen => _open;
  bool _open = false;

  @override
  Future<void> onCreate(Database db, int version) {
    return db.execute('''
       CREATE TABLE IF NOT EXISTS $_table(
       id Long, 
       key VARCHAR, 
       action VARCHAR, 
       timestamp INTEGER)
    ''');
  }

  @override
  Future<void> onOpen(Database db) {
    _open = true;
    return super.onOpen(db);
  }

  Future<int> getRowID(int recId) async {
    final List<Map<String, dynamic>> recs = await rawQuery(
        'SELECT id FROM $_table WHERE id = $recId ORDER BY id DESC LIMIT 1');

    int rowID;

    if (recs.isEmpty) {
      rowID = 0;
    } else {
      rowID = recs[0]['id'];
    }
    return rowID;
  }

  Future<int> update(Map<String, dynamic> recValues) async {
    int result = 0;

    final id = recValues['id'];

    if (id == null || id <= 0) {
      return result;
    }

    final key = recValues['key'];

    if (key == null || key.trim().isEmpty) {
      return result;
    }

    final Map<String, dynamic> recs = await updateRec(_table, recValues);

    if (recs.isEmpty) {
      result = 0;
    } else {
      result = recs.length;
    }
    return result;
  }

  Future<int> insert(Map<String, dynamic> recValues) async {
    int result;

    final Map<String, dynamic> recs = await updateRec(_table, recValues);

    if (recs.isEmpty) {
      result = 0;
    } else {
      result = recs['id'];
    }
    return result;
  }
}

class SQLHelper {}
