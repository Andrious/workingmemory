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

import 'dart:async';

import 'package:mvc/App.dart';

import 'package:workingmemory/src/model/Model.dart';

import 'package:auth/Auth.dart';


class Controller extends AppController{



  @override
  Future<bool> init() async {
    var init = await super.init();

    await signIn();

    await _model.init();

    /// Access Firebase
    await FireBase.init();

    return init;
  }



  @override
  void dispose(){

    FireBase.dispose();

    _model.dispose();

    _model = null;

    super.dispose();
  }



  static var _model = Model();


  
  static Future<List<Map>> list(){

    return _model.list();
  }



  static Future<bool> save(Map data){

    return _model.save(data);
  }

  

  static Future<bool> saveRec(Map diffRec, Map oldRec){
    Map newRec = Map();

    if(oldRec == null) {

      newRec.addAll(diffRec);
    }else {

      newRec.addAll(oldRec);

      newRec.addEntries(diffRec.entries);
    }
    return save(newRec);
  }


  static Future<bool> delete(Map data){

    return _model.delete(data);
  }

  static get defaultIcon => _model.tToDo.newrec[ToDo.TABLE_NAME]['Icon'];


  static get uid => Auth.uid;

  static get email => Auth.email;

  static get name => Auth.displayName;

  static get provider => Auth.providerId;

  static get isAnonymous => Auth.isAnonymous;

  static get photo => Auth.photoUrl;

  static get token => Auth.accessToken;

  static get tokenId => Auth.idToken;



  static Future<String> signInAnonymously() async {
    await Auth.signInAnonymously();
    return Auth.displayName;
  }



  static Future<String> signInWithGoogle() async{
    await Auth.logInWithGoogle();
    return Auth.displayName;
  }



  static Future<bool> signIn() async{
    await Auth.signInAnonymously();
    return Auth.uid.isNotEmpty;
  }
}