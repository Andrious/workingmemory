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

import 'package:flutter/material.dart';

import 'package:workingmemory/src/model.dart' show CloudDB, FireBaseDB;

import 'package:workingmemory/src/controller.dart' show AppController, Controller;

import 'package:auth/auth.dart' show Auth;

class WorkingMemoryApp extends AppController {
  factory WorkingMemoryApp() => _this ??= WorkingMemoryApp._();
  static WorkingMemoryApp _this;
  /// Allow for easy access to 'the Controller' throughout the application.
  static WorkingMemoryApp get con => _this;
  WorkingMemoryApp._();

  /// Provide the sign in and the loading database info.
  @override
  Future<bool> init() async {
    super.init();
    _auth = Auth.init();
    await signIn();
    _loggedIn = await _auth.isLoggedIn();
    _con = Controller();
    _con.init();
    return Future.value(true);
  }
  Controller _con;
  bool _loggedIn;
  Auth _auth;
  FireBaseDB _fbDB;

  void didChangeAppLifecycleState(AppLifecycleState state) {
    FireBaseDB.didChangeAppLifecycleState(state);
    CloudDB.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _fbDB?.dispose();
    _con.dispose();
    _auth?.dispose();
    super.dispose();
  }

  bool get loggedIn => _loggedIn;

  void logOut() async {
    await _auth.disconnect();
    rebuild();
  }

  Future<bool> signInWithFacebook() async {
    bool signIn = await _auth.signInWithFacebook();
    rebuild();
    return signIn;
  }

  Future<bool> signInWithTwitter() async {
    bool signIn = await _auth.signInWithTwitter();
    rebuild();
    return signIn;
  }

  Future<bool> signInEmailPassword(BuildContext context) async {
//    bool signIn = await _auth.signInWithEmailAndPassword();
//    rebuild();
//    return signIn;
  }

  Future<bool> signInWithGoogle() async {
    bool signIn = await _auth.signInGoogle();
    rebuild();
    return signIn;
  }

  void rebuild() async {
    _loggedIn = await _auth.isLoggedIn();
    _con.refresh();
  }

  String get uid => _auth.uid;

  get email => _auth.email;

  get name => _auth.displayName;

  get provider => _auth.providerId;

  get isAnonymous => _auth.isAnonymous;

  get photo => _auth.photoUrl;

  get token => _auth.accessToken;

  get tokenId => _auth.idToken;

  Future<bool> signIn() => _auth.signInSilently();
}
