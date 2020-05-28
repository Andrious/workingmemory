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

import 'package:flutter/foundation.dart' show FlutterExceptionHandler;

import 'package:mvc_application/controller.dart' as a show runApp;

import 'package:workingmemory/src/model.dart'
    show CloudDB, FireBaseDB, RemoteConfig; //, RemoteConfigValue;

import 'package:workingmemory/src/view.dart' show ReportErrorHandler, showBox;

import 'package:package_info/package_info.dart' show PackageInfo;

import 'package:workingmemory/src/controller.dart'
    show AppController, Controller;

import 'package:auth/auth.dart' show Auth, FirebaseUser, GoogleSignInAccount;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

runApp(
  Widget app, {
  FlutterExceptionHandler handler,
  ErrorWidgetBuilder builder,
  ReportErrorHandler reportError,
}) {
  // Supply Firebase Crashlytics
  handler ??= Crashlytics.instance.recordFlutterError;

  reportError ??= Crashlytics.instance.recordError;

  a.runApp(app, handler: handler, builder: builder, reportError: reportError);
}

class WorkingMemoryApp extends AppController {
  factory WorkingMemoryApp() => _this ??= WorkingMemoryApp._();
  static WorkingMemoryApp _this;
//
//  /// Allow for easy access to 'the Controller' throughout the application.
//  static WorkingMemoryApp get con => _this;
  WorkingMemoryApp._() {
    _auth = Auth(listener: _logInUser);
    _con = Controller();
    _auth.listener = _con.recordDump;
    _remoteConfig = RemoteConfig();
  }

  /// Provide the sign in and the loading database info.
  @override
  Future<bool> initAsync() async {
    super.initAsync();
    await signIn();
    await _remoteConfig.initAsync();
    await _con.initAsync();
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

  @override
  void onError(FlutterErrorDetails details) => super.onError(details);

  bool get loggedIn => _loggedIn;

  // logout and refresh
  void logOut() async {
    await signOut();
    rebuild();
  }

  void _logInUser(dynamic user) {
    //
    if (user != null) {
      userStamp();
    }

    Crashlytics.instance.setUserEmail(_auth.email);

    Crashlytics.instance.setUserIdentifier(_auth.displayName);

    Crashlytics.instance.setUserName(_auth.displayName);
  }

  // 'disconnect' from Firebase
  Future<void> signOut() => _auth.signOut().then(_logInUser);

  Future<bool> signIn() async {
    _loggedIn = await signInSilently();
    if (!_loggedIn) _loggedIn = await signInAnonymously();
    return _loggedIn;
  }

  Future<bool> signInAnonymously() => _auth.signInAnonymously();

  Future<bool> signInSilently() => _auth.signInSilently();

  Future<bool> signInWithFacebook() => _auth.signInWithFacebook();
  //    List<String> items = App.packageName.split(".");

  Future<bool> signInWithTwitter() async {
    //
    PackageInfo info = await PackageInfo.fromPlatform();

    List<String> items = info.packageName.split(".");

    String one = await _remoteConfig.getStringed(items[0]);
    if (one.isEmpty) {
      return false;
    }
    String two = await _remoteConfig.getStringed(items[1]);
    if (two.isEmpty) {
      return false;
    }
    bool signIn = await _auth
        .signInWithTwitter(
      key: one,
      secret: two,
    )
        .catchError((error) {
      getError(error);
    });

    if (!signIn) {
      Exception ex = _auth.getError();
      showBox(text: ex.toString(), context: context);
    }
    return signIn;
  }

  Future<bool> signInEmailPassword(BuildContext context) async {
    //
    String email = "";

    String password = "";

    bool signIn = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!signIn) {
      Exception ex = _auth.getError();
      showBox(text: ex.toString(), context: context);
    }
    return signIn;
  }

  Future<bool> signInWithGoogle() async {
    bool signIn = await _auth.signInWithGoogle();

    if (!signIn) {
      Exception ex = _auth.getError();
      showBox(text: ex.toString(), context: context);
    }
    return signIn;
  }

  // Stamp the user information to the firebase database.
  void userStamp() => FireBaseDB().userStamp();

  void rebuild() async {
    _loggedIn = await _auth.isLoggedIn();
//    _con.refresh();
    // Pops only if on the stack and not on the first screen.
    if (_con.context != null) Navigator.of(_con.context).maybePop();
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
