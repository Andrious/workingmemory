

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_database/ui/firebase_animated_list.dart';



class FireBase{


  static dataRef(String name) {
      return FirebaseDatabase.instance.reference().child(name);
  }

}


