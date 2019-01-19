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

import 'package:flutter/material.dart';

import 'package:mvc_application/app.dart' show AppController;

import 'package:auth/auth.dart' show Auth;

import 'package:firebase/firebase.dart' show FireBase;

import 'package:workingmemory/src/model/db/CloudDB.dart';

class WorkingMemoryApp extends AppController {
  factory WorkingMemoryApp() {
    if (_this == null) _this = WorkingMemoryApp._();
    return _this;
  }
  static WorkingMemoryApp _this;

  WorkingMemoryApp._();

  /// Allow for easy access to 'the Controller' throughout the application.
  static WorkingMemoryApp get con => _this;

  @override
  Future<bool> init() async {
    super.init();
    CloudDB.init();
    return await signIn();
  }

  @override
  void initState() {
    super.initState();
    FireBase.init();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    FireBase.didChangeAppLifecycleState(state);
    CloudDB.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    FireBase.dispose();
    CloudDB.dispose();
    super.dispose();
  }

  static String get uid => Auth.uid;

  static get email => Auth.email;

  static get name => Auth.displayName;

  static get provider => Auth.providerId;

  static get isAnonymous => Auth.isAnonymous;

  static get photo => Auth.photoUrl;

  static get token => Auth.accessToken;

  static get tokenId => Auth.idToken;

  static Future<bool> signIn() => Auth.signIn();

  static Future<bool> signInAnonymously() => Auth.signInAnonymously();

  static Future<bool> signInWithGoogle() => Auth.logInWithGoogle();
}
