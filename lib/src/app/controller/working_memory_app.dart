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

import 'package:auth/auth.dart' show Auth, GoogleListener, User;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    show FirebaseCrashlytics;
import 'package:flutter/foundation.dart'
    show FlutterErrorDetails, FlutterExceptionHandler, kIsWeb;
import 'package:fluttery_framework/controller.dart'; // as c;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:workingmemory/src/controller.dart'
    show AppController, Controller, ThemeController;
import 'package:workingmemory/src/model.dart'
    show CloudDB, DefaultFirebaseOptions, FireBaseDB, RemoteConfig;
import 'package:workingmemory/src/view.dart'
    show Prefs, ReportErrorHandler, showBox;
import 'package:workingmemory/src/view.dart' as v;

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

  if (!kIsWeb) {
    //
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
    // Send if in Production
    await crash.setCrashlyticsCollectionEnabled(!App.inDebugger);
  }

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
    bool init;
    init = await super.initAsync();

    if (init) {
      // Set this app's theme.
      final _theme = ThemeController();
      init = await _theme.initAsync();
    }

    if (init) {
      // Firebase remote configuration.
      _remoteConfig =
          RemoteConfig(key: 'rij;vwf553676-tgh2pc;jblrgncwjfc2cgncc');
      // await _remoteConfig.initAsync();
    }

    if (init) {
      // Provide the sign in and the loading database info.
      _auth = Auth(
        listener: _logInUser,
        firebaseOptions: DefaultFirebaseOptions.currentPlatform,
      );
      init = await _auth.initAsync();
    }

    if (init) {
      // Removed from constructor to prevent a stack overflow.
      // Must be initialized before signIn();
      _con = Controller();
      if (!App.hotReload) {
        init = await signIn();
      }
    }

    if (init) {
      init = await _con.initAsync();
    }

    return init;
  }

  late Controller _con;
  late bool _loggedIn;
  late Auth _auth;

  ///
  RemoteConfig get config => _remoteConfig;
  late RemoteConfig _remoteConfig;

  @override
  void initState() {
    super.initState();
    if (_auth.isAnonymous && _auth.uid.isNotEmpty) {
      final uid = Prefs.getString('fbUid');
      if (uid.isEmpty) {
        Prefs.setString('fbUid', _auth.uid);
      }
    }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FireBaseDB.didChangeAppLifecycleState(state);
    CloudDB.didChangeAppLifecycleState(state);
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
    if (user != null && App.isOnline) {
      FireBaseDB().loginUser(user as User);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.setUserIdentifier(_auth.displayName);
      }
    }
  }

  /// 'disconnect' from Firebase
  Future<void> signOut() => _auth.signOut(); //.then(_logInUser);

  /// Sign in the user to Firebase
  Future<bool> signIn() async {
    _loggedIn = await signInSilently();
    if (!_loggedIn) {
      if (kIsWeb) {
        // var uid = Prefs.getString('fbUid');
        // if (uid.isEmpty && App.inDebugger) {
        //   // A hack. Prefs doesn't work when debugging web.
        //   uid = 'h9Jh3FYddfOPs08qF4XHK29dYqx1';
        // }
        // if (uid.isEmpty) {
        //   // record the current Firebase uid
        //   _auth.addListener(signInAnonymousUser);
        // } else {
        //   _auth.uid = uid;
        //   _loggedIn = true;
        // }
        signInAnonymousUser();
      }
    }
    if (!_loggedIn) {
      _loggedIn = await signInAnonymously();
    }
    // if (_auth.isAnonymous) {
    //   await FireBaseDB().dealWithAnonymous();
    //   // _auth.listener = _con.syncUpRecords;
    // }
    return _loggedIn;
  }

  ///
  Future<bool> signInAnonymously() => _auth.signInAnonymously();

  ///
  Future<bool> signInSilently() => _auth.signInSilently();

  ///
  void signInAnonymousUser([User? user]) {
    //
    if (user == null) {
      _auth.addListener(signInAnonymousUser);
    }

    final uid = Prefs.getString('fbUid');

    if (uid.isEmpty) {
      if (user != null) {
        if (_auth.isAnonymous && user.uid.isNotEmpty) {
          final uid = Prefs.getString('fbUid');
          if (uid.isEmpty) {
            Prefs.setString('fbUid', user.uid);
          }
        }
      }
    } else {
      _auth.uid = uid;
      _loggedIn = true;
    }
  }

  ///
  Future<bool> signInWithFacebook() async {
    await FireBaseDB().dealWithAnonymous();
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
    await FireBaseDB().dealWithAnonymous();
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

    await FireBaseDB().dealWithAnonymous();
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
  /// https://stackoverflow.com/a/60804020/8692691
  Future<bool> signInWithGoogle({GoogleListener? listen}) async {
    final bool signIn = await _auth.signInWithGoogle(listen: listen);
    if (!signIn) {
      final ex = _auth.getError();
      if (ex != null) {
        // Record the error
        await App.errorHandler?.reportError(ex, StackTrace.empty);
        await showBox(text: ex.toString(), context: (_con.state?.context)!);
      }
    }
//    await rebuild();
    return signIn;
  }

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
  String get uid {
    // if (_auth.uid.trim().isEmpty && App.inDebugger) {
    //   // A hack. Prefs doesn't work when debugging web.
    //   _auth.uid = 'h9Jh3FYddfOPs08qF4XHK29dYqx1';
    // }
    return _auth.uid;
  }

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
