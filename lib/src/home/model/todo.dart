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

import 'package:workingmemory/src/model.dart';

///
class ToDo extends SQLiteDB {
  ///
  factory ToDo() => _this ??= ToDo._();
  ToDo._() {
    _cloud = CloudDB();
    // _fbDB = FireBaseDB();
  }
  static ToDo? _this;
  late CloudDB _cloud;
  late FireBaseDB _fbDB;

  late String _selectAll, _selectNotDeleted, _selectDeleted;

  ///
  bool? finished;

  ///
  static const TABLE_NAME = 'working';

  @override
  String get name => 'ToDo';

  @override
  int get version => 1;

  String? _keyFld;

  ///
  Future<bool> initAsync() async {
    ///
    final init = await super.init();

    _keyFld = await keyField(TABLE_NAME);

    _selectNotDeleted = 'SELECT $_keyFld, * FROM $TABLE_NAME WHERE deleted = 0';

    _selectDeleted = 'SELECT $_keyFld, * FROM $TABLE_NAME WHERE deleted = 1';

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
       ReminderChk integer default 0, 
       LEDColor integer default 0, 
       AlarmId integer default -1,
       Fired integer default 0, 
       deleted integer default 0)
    ''');

    await db.execute(IconFavourites.CREATE_TABLE);
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

  ///
  Future<List<Map<String, dynamic>>> list() => getTable(ToDo.TABLE_NAME);

  ///
  Future<List<Map<String, dynamic>>> notDeleted({bool ordered = false}) {
    var select = _selectNotDeleted;
    if (ordered) {
      select = '$select order by datetime(DateTime)';
    }
    return rawQuery(select);
  }

  ///
  Future<List<Map<String, dynamic>>> isDeleted({bool ordered = false}) {
    var select = _selectDeleted;
    if (ordered) {
      select += ' order by datetime(DateTime)';
    }
    return rawQuery(select);
  }

  ///
  Map<String, dynamic> newRecord(Map<String, dynamic> data) =>
      super.newRec(ToDo.TABLE_NAME, data);

  ///
  void dispose() {
    _cloud.dispose();
    disposed();
    _this = null;
  }
}
