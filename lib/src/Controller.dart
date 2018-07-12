
import 'dart:async';

import 'package:mvc/MVC.dart';

import 'package:prefs/prefs.dart';

import 'FireBase.dart';

import 'package:auth/auth.dart';

import 'Model.dart';

class Controller extends MVController {

  var _model = Model();

  var _fireBase = FireBase();

  Future<bool> _init;

  Future<bool> init() async {

    Prefs.init();

    _init = _model.init();

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

  static Future<String> signInAnonymously() async {
    await Auth.signInAnonymously();
    return Auth.displayName;
  }

  static signInWithGoogle() async{
    await Auth.logInWithGoogle();
    return Auth.displayName;
  }

  static get user => Auth.user ?? '<unknown>';
}