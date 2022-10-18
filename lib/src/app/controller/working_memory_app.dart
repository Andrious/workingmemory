///
/// Copyright (C) 2018 Andrious Solutions
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
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

import 'package:flutter/foundation.dart'
    show FlutterErrorDetails, FlutterExceptionHandler;

import 'package:fluttery_framework/controller.dart'; // as c;

import 'package:workingmemory/src/model.dart'
    show CloudDB, DefaultFirebaseOptions, FireBaseDB, RemoteConfig;

import 'package:workingmemory/src/view.dart' show ReportErrorHandler, showBox;

import 'package:workingmemory/src/view.dart' as v;

import 'package:workingmemory/src/controller.dart'
    show AppController, Controller, ThemeController;

import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;

import 'package:auth/auth.dart' show Auth;

import 'package:firebase_core/firebase_core.dart' show Firebase;

import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    show FirebaseCrashlytics;

// ignore: avoid_void_async
///
Future<void> runApp(
  Widget app, {
  FlutterExceptionHandler? handler,
  ErrorWidgetBuilder? builder,
  ReportErrorHandler? report,
  bool allowNewHandlers = false,
}) async {
  // Allow for FirebaseCrashlytics.instance
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    // Allow for FirebaseCrashlytics.instance
    await Firebase
        .initializeApp(); //(options: DefaultFirebaseOptions.currentPlatform);
  }

  // Supply Firebase Crashlytics
  final FirebaseCrashlytics crash = FirebaseCrashlytics.instance;

  handler ??= crash.recordFlutterError;

  report ??= crash.recordError;

  // If true, then crash reporting data is sent to Firebase.
  await crash.setCrashlyticsCollectionEnabled(false);

  v.runApp(
    app,
    errorHandler: handler,
    errorScreen: builder,
    errorReport: report,
    allowNewHandlers: allowNewHandlers,
  );
}

/// The Controller for the Application as a whole.
class WorkingController extends AppController {
  ///
  factory WorkingController() => _this ??= WorkingController._();
  WorkingController._();
  static WorkingController? _this;

  @override
  Future<bool> initAsync() async {
    await super.initAsync();
    // Set this app's theme.
    final _theme = ThemeController();
    await _theme.initAsync();

    // Firebase remote configuration.
    _remoteConfig = RemoteConfig(key: 'rij;vwf553676-tgh2pc;jblrgncwjfc2cgncc');
//    await _remoteConfig.initAsync();
    // Provide the sign in and the loading database info.
    _auth = Auth(
      listener: _logInUser,
      firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    );

    // Removed from constructor to prevent a stack overflow.
    // Must be initialized before signIn();
    _con = Controller();
    if (!App.hotReload) {
      await signIn();
    }
    await _con.initAsync();

    return true;
  }

  late Controller _con;
  late bool _loggedIn;
  late Auth _auth;

  ///
  RemoteConfig get config => _remoteConfig;
  late RemoteConfig _remoteConfig;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FireBaseDB.didChangeAppLifecycleState(state);
    CloudDB.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    if (!App.hotReload) {
      _con.dispose();
      _auth.dispose();
      _remoteConfig.dispose();
//    L10n.dispose();
      _this = null;
      super.dispose();
    }
  }

  ///
  bool get loggedIn => _loggedIn;

  /// logout and refresh
  void logOut() {
    signOut();
    rebuild();
  }

  void _logInUser(dynamic user) {
    //
    if (user != null) {
      userStamp();
    }
    FirebaseCrashlytics.instance.setUserIdentifier(_auth.displayName);
  }

  /// 'disconnect' from Firebase
  Future<void> signOut() => _auth.signOut().then(_logInUser);

  /// Sign in the user to Firebase
  Future<bool> signIn() async {
    _loggedIn = await signInSilently();
    if (!_loggedIn) {
      _loggedIn = await signInAnonymously();
    }
    if (_auth.isAnonymous) {
      await FireBaseDB().removeAnonymous();
      _auth.listener = _con.recordDump;
    }
    return _loggedIn;
  }

  ///
  Future<bool> signInAnonymously() => _auth.signInAnonymously();

  ///
  Future<bool> signInSilently() => _auth.signInSilently();

  ///
  Future<bool> signInWithFacebook() async {
    await FireBaseDB().removeAnonymous();
    await _auth.delete();
    await signOut();
    final signIn = _auth.signInWithFacebook();
    return signIn;
  }

  //    List<String> items = App.packageName.split(".");
  ///
  Future<bool> signInWithTwitter() async {
//    return Future.value(false);
    //
    final PackageInfo info = await PackageInfo.fromPlatform();

    final List<String> items = info.packageName.split('.');

    final String one = await _remoteConfig.getStringed(items[0]);
    if (one.isEmpty) {
      return false;
    }
    final String two = await _remoteConfig.getStringed(items[1]);
    if (two.isEmpty) {
      return false;
    }
    await FireBaseDB().removeAnonymous();
    await _auth.delete();
    await signOut();

    final bool signIn = await _auth
        .signInWithTwitter(
      key: one,
      secret: two,
    )
        .catchError(
      (error) async => false,
      test: (error) {
        getError(error);
        return true;
      },
    );

    if (!signIn) {
      final Exception? ex = _auth.getError();
      await showBox(text: ex.toString(), context: (_con.state?.context)!);
    }
    return signIn;
  }

  ///
  Future<bool> signInEmailPassword(BuildContext context) async {
    //
    const String email = '';

    const String password = '';

    await FireBaseDB().removeAnonymous();
    await _auth.delete();
    await signOut();

    final bool signIn = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!signIn) {
      final Exception? ex = _auth.getError();
      await showBox(text: ex.toString(), context: context);
    }
    return signIn;
  }

  ///
  Future<bool> signInWithGoogle() async {
    await FireBaseDB().removeAnonymous();
    await _auth.delete();
    await signOut();
    final bool signIn = await _auth.signInWithGoogle();
    if (!signIn) {
      final Exception? ex = _auth.getError();
      await showBox(text: ex.toString(), context: (_con.state?.context)!);
    }
    await rebuild();
    return signIn;
  }

  /// Stamp the user information to the firebase database.
  void userStamp() => FireBaseDB().userStamp();

  ///
  Future<void> rebuild() async {
    _loggedIn = _auth.isLoggedIn();
    setState(() {});
    // Pops only if on the stack and not on the first screen.
    final BuildContext? context = _con.state?.context;
    if (context != null) {
      await Navigator.of(context).maybePop();
    }
  }

  ///
  String get uid => _auth.uid;

  ///
  String get email => _auth.email;

  ///
  String get name => _auth.displayName;

  ///
  String get provider => _auth.providerId;

  ///
  bool get isNewUser => _auth.isNewUser;

  ///
  bool get isAnonymous => _auth.isAnonymous;

  ///
  String get photo => _auth.photoUrl;

  ///
  String get token => _auth.accessToken;

  ///
  String get tokenId => _auth.idToken;

  /// Override if you like to customize error handling.
  @override
  void onError(FlutterErrorDetails details) {
    super.onError(details);
  }

  ///
  bool get hasError => _error != null;

  ///
  bool get inError => _error != null;
  Object? _error;

  ///
  Exception? getError([Object? error]) {
    // Return the stored exception
    Exception? ex;
    if (_error != null) {
      ex = _error as Exception;
    }
    // Empty the stored exception
    if (error == null) {
      _error = null;
    } else {
      if (error is! Exception) {
        error = Exception(error.toString());
      }
      _error = error;
    }
    // Return the exception just past if any.
    return ex ??= error as Exception;
  }
}
