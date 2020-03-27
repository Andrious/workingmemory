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

import 'package:workingmemory/src/model.dart'
    show CloudDB, FireBaseDB, RemoteConfig; //, RemoteConfigValue;

import 'package:workingmemory/src/view.dart' show App;

import 'package:workingmemory/src/controller.dart'
    show AppController, Controller;

import 'package:auth/auth.dart' show Auth, FirebaseUser, GoogleSignInAccount;

class WorkingMemoryApp extends AppController {
  factory WorkingMemoryApp() => _this ??= WorkingMemoryApp._();
  static WorkingMemoryApp _this;

  /// Allow for easy access to 'the Controller' throughout the application.
  static WorkingMemoryApp get con => _this;
  WorkingMemoryApp._() {
    _auth = Auth();
    _con = Controller();
    _remoteConfig = RemoteConfig();
  }

  /// Provide the sign in and the loading database info.
  @override
  Future<bool> init() async {
    super.init();
    await signIn();
    await _remoteConfig.init();
    await _con.init();
    return true;
  }

  Controller _con;
  bool _loggedIn;
  Auth _auth;

  RemoteConfig get config => _remoteConfig;
  RemoteConfig _remoteConfig;

  void didChangeAppLifecycleState(AppLifecycleState state) {
    FireBaseDB.didChangeAppLifecycleState(state);
    CloudDB.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _con.dispose();
    _auth?.dispose();
    _remoteConfig.dispose();
    super.dispose();
  }

  bool get loggedIn => _loggedIn;

  // logout and refresh
  void logOut() async {
    await signOut();
    rebuild();
  }

  // 'disconnect' from Firebase
  Future<void> signOut() => _auth.signOut();

  Future<bool> signIn() async {
    _loggedIn = await _auth.signInSilently();
    if (!_loggedIn) _loggedIn = await _auth.signInAnonymously();
    return _loggedIn;
  }

  Future<bool> signInAnonymously() => _auth.signInAnonymously();

  Future<bool> signInSilently() => _auth.signInSilently();

  Future<bool> signInWithFacebook() async {
    bool signIn = await _auth.signInWithFacebook(listener: (FirebaseUser user) {
      if (user != null) {
        userStamp();
        recordDump();
      }
    }).then((signIn) {
      return signIn;
    });
    return signIn;
  }

  Future<bool> signInWithTwitter() async {
    List<String> items = App.packageName.split(".");
    String one = _remoteConfig.getString(items[0]);
    if (one.isEmpty) {
      return false;
    }
    String two = _remoteConfig.getString(items[1]);
    if (two.isEmpty) {
      return false;
    }
//    var encrypt = await _remoteConfig.en(one);
//    encrypt = await _remoteConfig.en(two);
    one = await _remoteConfig.de(one);
    two = await _remoteConfig.de(two);
    bool signIn = await _auth
        .signInWithTwitter(
            key: one,
            secret: two,
            listener: (FirebaseUser user) {
              if (user != null) {
                userStamp();
                recordDump();
              }
            })
        .then((signIn) {
      return signIn;
    }).catchError((error) {
      getError(error);
    });
    return signIn;
  }

  Future<bool> signInEmailPassword(BuildContext context) async {
    String email = "";
    String password = "";
    bool signIn = await _auth
        .signInWithEmailAndPassword(
            email: email,
            password: password,
            listener: (FirebaseUser user) {
              if (user != null) {
                userStamp();
                recordDump();
              }
            })
        .then((signIn) {
      return signIn;
    });
    return signIn;
  }

  Future<bool> signInWithGoogle() async {
    bool signIn =
        await _auth.signInWithGoogle(listen: (GoogleSignInAccount user) {
      if (user != null) {
        userStamp();
        recordDump();
      }
    }).then((signIn) {
      return signIn;
    });
    return signIn;
  }

  // Stamp the user information to the firebase database.
  void userStamp() => FireBaseDB().userStamp();

  Future<void> recordDump() async {
    await _con.model.recordDump();
    rebuild();
  }

  void rebuild() async {
    _loggedIn = await _auth.isLoggedIn();
//    _con.refresh();
    // Pops only if on the stack and not on the first screen.
    Navigator.of(_con.context).maybePop();
  }

  String get uid => _auth.uid;

  get email => _auth.email;

  get name => _auth.displayName;

  get provider => _auth.providerId;

  get isNewUser => _auth.isNewUser;

  get isAnonymous => _auth.isAnonymous;

  get photo => _auth.photoUrl;

  get token => _auth.accessToken;

  get tokenId => _auth.idToken;
}
