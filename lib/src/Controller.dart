
import 'dart:async';

import 'package:mvc/MVC.dart';

import 'package:prefs/prefs.dart';

import 'FireBase.dart';
import 'package:firebase_database/firebase_database.dart';

import 'auth/auth.dart';

import 'Model.dart';

class Controller extends MVController {

  var _model = Model();

  var _fireBase = FireBase();

  Future<bool> _init;

  Future<bool> init() async {

    await Prefs.init();

    _init = await _model.init();

    signInAnonymously();

    return _init;
  }

  @override
  void initState() {
    super.initState();

    FireBase.dataRef('tasks');
  }
  
  @override
  void dispose(){

    Prefs.dispose();

    Auth.dispose();

    _model.dispose();

    _model = null;
    
    _fireBase = null;

    super.dispose();
  }

  static signInAnonymously() async {
    Auth.init();
    return Auth.signInAnonymously();
  }

  static signInWithGoogle() async{
    return Auth.signInWithGoogle();
  }

  static get user => Auth.user ?? '<unknown>';
}