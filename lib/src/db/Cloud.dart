import 'dart:collection';

import '../app/AppController.dart';

import '../auth/auth.dart';

import 'package:firebase_database/firebase_database.dart';

class DataSync{

  static String _installNum = '';
  get installNum => _installNum;

  init(){

    AppController.getInstallNum()
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