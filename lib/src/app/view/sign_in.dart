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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workingmemory/src/app/view/loading_screen.dart';
import 'package:workingmemory/src/controller.dart';
import 'package:workingmemory/src/view.dart';

///
class SignIn extends StatefulWidget {
  ///
  const SignIn({Key? key}) : super(key: key);
  @override
  State createState() => _SignInState();
}

class _SignInState extends StateX<SignIn> {
  _SignInState() : super() {
    app = WorkingController();
    spinner = WorkingSpinnerIndicator();
  }
  late WorkingController app;
  late WorkingSpinnerIndicator spinner;
  // Widget working = const SizedBox();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 40),
            child: GestureDetector(
              onTap: () async {
                spinner.start();
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
                spinner.start();
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
                spinner.start();
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
                spinner.start();
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
      ),
      spinner,
    ]);
  }

  // void _working() {
  //   working = App.useMaterial
  //       ? const Center(child: CircularProgressIndicator())
  //       : const Center(child: CupertinoActivityIndicator());
  //   setState(() {});
  // }
}
