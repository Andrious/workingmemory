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

import 'dart:async' show Future;

import 'package:flutter/material.dart' show AppLifecycleState;

import 'package:workingmemory/src/model.dart' show CloudDB, FireBaseDB;

import 'package:workingmemory/src/controller.dart' show AppController, Controller;

import 'package:auth/auth.dart' show Auth;

class WorkingMemoryApp extends AppController {
  factory WorkingMemoryApp() => _this ??= WorkingMemoryApp._();
  static WorkingMemoryApp _this;

  WorkingMemoryApp._();
  static Auth _auth;
  FireBaseDB _fbDB;


  /// Allow for easy access to 'the Controller' throughout the application.
  static WorkingMemoryApp get con => _this;

  /// Provide the sign in and the loading database info.
  @override
  Future<bool> init() async {
    super.init();
    _auth = Auth.init();
    await signIn();
//    _fbDB = FireBaseDB.init();
    await Controller.list.retrieve();
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    CloudDB.init();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    FireBaseDB.didChangeAppLifecycleState(state);
    CloudDB.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _fbDB?.dispose();
    CloudDB.dispose();
    _auth?.dispose();
    super.dispose();
  }

  static String get uid => _auth.uid;

  static get email => _auth.email;

  static get name => _auth.displayName;

  static get provider => _auth.providerId;

  static get isAnonymous => _auth.isAnonymous;

  static get photo => _auth.photoUrl;

  static get token => _auth.accessToken;

  static get tokenId => _auth.idToken;

  static Future<bool> signIn() => _auth.signInSilently();

  static Future<bool> signInAnonymously() => _auth.signInAnonymously();

  static Future<bool> signInWithGoogle() => _auth.signInGoogle();
}
