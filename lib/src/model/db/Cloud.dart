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

import 'dart:collection';

import 'package:mvc/App.dart';

import 'package:auth/Auth.dart';

import 'package:firebase_database/firebase_database.dart';

class DataSync{

  static String _installNum = '';
  get installNum => _installNum;

  init(){

    App.getInstallNum()
        .then((id){_installNum = id;})
        .catchError((e){_installNum = '';});

  }


  static DatabaseReference syncRef(String userId){

//    if (!isOnline()){
//
//      mDatabase.goOnline();
//    }

    String id;

    if (userId == null || userId.isEmpty){

      id = null;
    }else{

      id = userId.trim();
    }

    DatabaseReference ref;

    if (id == null){

      // Important to give a reference that's not  there in case called by deletion routine.
      ref = FirebaseDatabase.instance.reference()
          .child("sync")
          .child("dummy")
          .child(_installNum);
    }else{

      ref = FirebaseDatabase.instance.reference()
          .child("sync")
          .child(id)
          .child(_installNum);
    }
    return ref;
  }


  static DatabaseReference getDevRef(String userId){

    String id;

    if (userId == null || userId.isEmpty){

      id = null;
    }else{

      id = userId.trim();
    }

    DatabaseReference ref;

    if (id == null){

      // Important to provide a reference that is not likely there in case called by deletion routine.
      ref = FirebaseDatabase.instance.reference()
          .child("devices")
          .child(_installNum);
    }else{

      ref = FirebaseDatabase.instance.reference()
          .child("devices")
          .child(id)
          .child(_installNum);
    }
    return ref;
  }


//  static void sync(final dbInterface dbLocal, final dbInterface dbCloud, final appModel AppModel) {
//    if (!isOnline()) {
//      return;
//    }
//
//    final DatabaseReference syncINRef = syncRef(Auth.getUid()).child("IN");
//
//    FirebaseDatabase.instance
//        .reference()
//        .child('messages')
//        .once()
//        .catchError((ex){})
//        .then((DataSnapshot snapshot) {
//
//      // Process the online sync table records if any.
//      var sync = snapshot != null;
//
//      if (sync) {
//
//        DataSync.syncData(snapshot, dbLocal, dbCloud);
//      }
//
//      // Local records updated
//      if (getRecs().getCount() > 0) {
//        // Should sync
//        sync = true;
//
//        // Update the dbFirebase database now that there is online access.
//        DataSync.updateCloud(dbLocal, dbCloud);
//      }
//    });
//  }
}