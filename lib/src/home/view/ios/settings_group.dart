// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

import 'settings_item.dart';
import 'styles.dart';

// The widgets in this file present a group of Cupertino-style settings items to
// the user. In the future, the Cupertino package in the Flutter SDK will
// include dedicated widgets for this purpose, but for now they're done here.
//
// See https://github.com/flutter/flutter/projects/29 for more info.

///
class SettingsGroupHeader extends StatelessWidget {
  ///
  const SettingsGroupHeader(this.title, {Key? key}) : super(key: key);

  ///
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 6,
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: CupertinoColors.inactiveGray,
          fontSize: 13.5,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

///
class SettingsGroupFooter extends StatelessWidget {
  ///
  const SettingsGroupFooter(this.title, {Key? key}) : super(key: key);

  ///
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 7.5,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Styles.settingsGroupSubtitle,
          fontSize: 13,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}

///
class SettingsGroup extends StatelessWidget {
  ///
  SettingsGroup({
    Key? key,
    this.items,
    this.header,
    this.footer,
  })  : assert(items != null),
        assert(items!.isNotEmpty),
        super(key: key);

  ///
  final List<SettingsItem>? items;

  ///
  final Widget? header;

  ///
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    //
    final dividedItems = <Widget>[items![0]];

    for (int i = 1; i < items!.length; i++) {
      dividedItems.add(Container(
        color: Styles.settingsLineation,
        height: 0.3,
      ));
      dividedItems.add(items![i]);
    }

    return Padding(
      padding: EdgeInsets.only(
        top: header == null ? 35 : 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) header!,
          Container(
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              border: Border(
                top: BorderSide(
                  color: Styles.settingsLineation,
                  width: 0,
                ),
                bottom: BorderSide(
                  color: Styles.settingsLineation,
                  width: 0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: dividedItems,
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
