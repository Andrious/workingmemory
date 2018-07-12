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

import 'package:workingmemory/src/model/db/FireBase.dart';

import 'package:firebase_database/firebase_database.dart' as fb;

import 'package:firebase_core/firebase_core.dart';


class FireBaseDatabase {

  static fb.FirebaseDatabase database;

  static FirebaseApp fireBaseApp;

  FireBaseDatabase() {
//    database = FireBase.database();
//
//    fireBaseApp = database.app;
  }

}