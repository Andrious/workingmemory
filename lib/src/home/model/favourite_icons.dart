///
/// Copyright (C) 2020 Andrious Solutions
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
///          Created  26 Oct 2020
///

import '/src/model.dart';

///
class IconFavourites {
  ///
  factory IconFavourites() => _this ??= IconFavourites._();
  IconFavourites._() {
    _fbDB = FireBaseDB();
    _db = ToDo();
    _icons = Icons.code;
  }
  static IconFavourites? _this;
  late SQLiteDB _db;
  late FireBaseDB _fbDB;

  /// All the icons available to the user.
  late Map<String, String> _icons;

  ///
  // ignore: constant_identifier_names
  static const TABLE_NAME = 'icons';

  ///
  // ignore: constant_identifier_names
  static const CREATE_TABLE = '''
       CREATE TABLE IF NOT EXISTS $TABLE_NAME(
       icon VARCHAR DEFAULT 0xe15b,
       deleted INTEGER DEFAULT 0)
    ''';

  ///
  Future<List<Map<String, dynamic>>> list() => _db.getTable(TABLE_NAME);

  ///
  Future<List<Map<String, dynamic>>> retrieve([String? icon]) {
    //
    if (icon == null) {
      icon = '';
    } else {
      // Leave the 'AND' It works.
      icon = ' icon = "$icon" AND ';
    }
    final String select =
        'SELECT icon FROM ${IconFavourites.TABLE_NAME} WHERE $icon deleted = 0';
    return _db.rawQuery(select);
  }

  /// Save the specified icon as a favourite icon.
  Future<bool> saveRec(String icon) async {
    //
    final icons = await retrieve(icon);

    if (icons.isNotEmpty) {
      return true;
    }

    final rec = await _db.saveRec(TABLE_NAME, {'icon': icon});

    return rec.isNotEmpty;
  }

  /// Delete specified record.
  Future<bool> deleteRec(String icon) async {
    //
    final icons = await retrieve(icon);

    if (icons.isNotEmpty) {
      return true;
    }

    final rec =
        await _db.deleteRec(TABLE_NAME, where: 'icon = ?', whereArgs: [icon]);

    return rec > 0;
  }

  /// Return favourite icons from Firebase
  Future<List<Map<String, dynamic>>> fbQuery() async {
    //
//    final DatabaseEvent dbEvent = await _fbDB.favIconsRef.once();
//    final value = dbEvent.snapshot.value;

    final DataSnapshot snapshot = await _fbDB.favIconsRef.get();
    final value = snapshot.value;

    Map<String, dynamic> icons;

    if (value == null || value is! Map) {
      icons = {};
    } else {
      icons = Map.from(value);
    }
    return [icons];
  }

  ///
  Future<bool> saveRef(String code) async {
    bool save;
    final String name = _icons[code]!;
    try {
      await _fbDB.favIconsRef.child(code).set(name);
      save = true;
    } catch (ex) {
      save = false;
    }
    return save;
  }

  ///
  void dispose() {
    _fbDB.dispose();
    _db.disposed();
    _this = null;
  }
}
