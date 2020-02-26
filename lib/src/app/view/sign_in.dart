///
/// Copyright (C) 2020 Andrious Solutions
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
///          Created  22 Feb 2020
///
///

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart';


class SignIn extends StatefulWidget {
  SignIn({Key key}) : super(key: key);
  @override
  State createState() => SignInState();
}

class SignInState extends StateMVC<SignIn>{
  SignInState():super(){
    con = WorkingMemoryApp.con;
  }
  WorkingMemoryApp con;

  @override
  Widget build(BuildContext context) {
    return row;
  }

  Widget get row {
    List<Widget> children;

    children = [
      Padding(
        padding: EdgeInsets.only(top: 10.0, right: 40.0),
        child: GestureDetector(
          onTap: () => con.signInWithFacebook(),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: new Icon(
              FontAwesomeIcons.facebook,
              //                 color: Color(0xFF0084ff),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0, right: 40.0),
        child: GestureDetector(
          onTap: () => con.signInWithTwitter(),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: new Icon(
              FontAwesomeIcons.twitter,
              //                 color: Color(0xFF0084ff),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0, right: 40.0),
        child: GestureDetector(
          onTap: () => con.signInEmailPassword(context),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: new Icon(
              FontAwesomeIcons.envelope,
//                  color: Color(0xFF0084ff),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: GestureDetector(
          onTap: () => con.signInWithGoogle(),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: new Icon(
              FontAwesomeIcons.google,
              //                 color: Color(0xFF0084ff),
            ),
          ),
        ),
      ),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

}

