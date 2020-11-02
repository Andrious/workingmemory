///
/// Copyright (C) 2019 Andrious Solutions
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
///          Created  16 Aug 2019
///
///

import 'package:flutter/material.dart';

import 'package:workingmemory/src/model.dart' show Settings;

import 'package:workingmemory/src/view.dart';

import 'package:workingmemory/src/controller.dart' show Controller;

import 'package:universal_platform/universal_platform.dart';

class WorkMenu extends Menu {
  WorkMenu() : super() {
    _con = Controller();

    if (_con.app.loggedIn) {
      if (_con.app.isAnonymous) {
        tailItems = [
          PopupMenuItem(value: 'SignIn', child: I10n.t('Sign in...')),
        ];
      } else {
        tailItems = [
          PopupMenuItem(value: 'Logout', child: I10n.t('Logout')),
        ];
      }
    } else {
      tailItems = [
        PopupMenuItem(value: 'SignIn', child: I10n.t('Sign in...')),
      ];
    }
  }
  Controller _con;

  @override
  List<PopupMenuItem<dynamic>> menuItems() => [
        PopupMenuItem(value: 'Resync', child: I10n.t('Resync')),
        PopupMenuItem(
            value: 'interface',
            child: Text('${I10n.s('Interface:')} $interface')),
        PopupMenuItem(
            value: 'Locale',
            child: Text('${I10n.s('Locale:')} ${App.locale.toLanguageTag()}')),
      ];

  // Supply what the interface
  String get interface => App.useMaterial ? 'Material' : 'Cupertino';

  @override
  Future<void> onSelected(dynamic menuItem) async {
    switch (menuItem) {
      case 'Resync':
        _con.reSync();
        break;
      case 'interface':
        App.changeUI(App.useMaterial ? 'Cupertino' : 'Material');
        bool switchUI;
        if (App.useMaterial) {
          if (UniversalPlatform.isAndroid) {
            switchUI = false;
          } else {
            switchUI = true;
          }
        } else {
          if (UniversalPlatform.isAndroid) {
            switchUI = true;
          } else {
            switchUI = false;
          }
        }
        await Prefs.setBool('switchUI', switchUI);
        break;
      case 'Locale':
        // await MsgBox(
        //   context: context,
        //   title: I10n.s('Current Language'),
        //   msg: I10n.s('Pick another:'),
        //   body: const [ISOSpinner()],
        // ).show();

        final initialItem = I10n.supportedLocales.indexOf(App.locale);
        final spinner = ISOSpinner(initialItem: initialItem);

        await DialogBox(
          context: _con.state.context,
          title: I10n.s('Current Language'),
          body: [spinner],
          press01: () {
            spinner.onSelectedItemChanged(initialItem);
          },
          press02: () {},
          switchButtons: Settings.getLeftHanded(),
        ).show();

        break;
      case 'Logout':
        _con.logOut();
        break;
      case 'SignIn':
        unawaited(_con.signIn());
        break;
      default:
    }
  }
}
