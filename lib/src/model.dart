///
/// Copyright (C) 2019 Andrious Solutions
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
///          Created  10 Apr 2019
///
///           import 'package:workingmemory/model.dart';

/// sql
export 'package:dbutils/sqlite_db.dart';

/// sql plugin
//export 'package:sqflite/sqflite.dart' show Database;

/// remote
export 'package:remote_config/remote_config.dart'
    show RemoteConfig, RemoteConfigValue;

/// Firebase
export 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, DatabaseReference, DatabaseEvent, Query;

/// App's model
export '/src/app/app_model.dart';

/// Homescreen's model
export '/src/home/home_model.dart';
