///
/// Copyright (C) 2020 Andrious Solutions
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
///          Created  22 Feb 2020
///
///

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key key}) : super(key: key);
  @override
  State createState() => SignInState();
}

class SignInState extends StateMVC<SignIn> {
  SignInState() : super() {
    app = WorkingController();
  }
  WorkingController app;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 40),
          child: GestureDetector(
            onTap: () async {
              final bool signIn = await app.signInWithFacebook();
              if (signIn) {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                FontAwesomeIcons.facebook,
                //                 color: Color(0xFF0084ff),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 40),
          child: GestureDetector(
            onTap: () async {
              final bool signIn = await app.signInWithTwitter();
              if (signIn) {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                FontAwesomeIcons.twitter,
                //                 color: Color(0xFF0084ff),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 40),
          child: GestureDetector(
            onTap: () async {
              final bool signIn = await app.signInEmailPassword(context);
              if (signIn) {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                FontAwesomeIcons.envelope,
//                  color: Color(0xFF0084ff),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: () async {
              final bool signIn = await app.signInWithGoogle();
              if (signIn) {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                FontAwesomeIcons.google,
                //                 color: Color(0xFF0084ff),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
