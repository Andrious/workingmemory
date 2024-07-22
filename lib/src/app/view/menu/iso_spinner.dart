// //import 'dart:math' show cos, pi;
//
// //import 'package:flutter/material.dart';
// import '/src/view.dart';
//
// import 'package:l10n_translator/l10n.dart';
//
// import 'package:fluttery_framework/view.dart' as s;
//
// /// A Spinner listing the available Locales.
// class ISOSpinner extends StatefulWidget {
//   const ISOSpinner({
//     required this.initialItem,
//     Key? key,
//   }) : super(key: key);
//   final int initialItem;
//
//   /// Retrieve the available locales.
//   List<Locale> locales() => L10n.supportedLocales!;
//
//   /// Assign the specified Locale.
//   Future<void> onSelectedItemChanged(int index) async {
//     final List<Locale> localesList = locales();
//     if (localesList != null) {
//       s.App.locale = localesList[index];
//       await s.Prefs.setString('locale', localesList[index].toLanguageTag());
//       s.App.refresh();
//     }
//   }
//
//   @override
//   State createState() => _SpinnerState();
// }
//
// class _SpinnerState extends State<ISOSpinner> {
//   @override
//   void initState() {
//     super.initState();
//     locales = widget.locales();
//     int index;
//     if (widget.initialItem != null && widget.initialItem > -1) {
//       index = widget.initialItem;
//     } else {
//       index = locales.indexOf(s.App.locale!);
//       if (index == null || index < 0) {
//         index = 0;
//       }
//     }
//     controller = FixedExtentScrollController(initialItem: index);
//   }
//
//   late List<Locale> locales;
//   late FixedExtentScrollController controller;
//
//   @override
//   Widget build(BuildContext context) => Container(
//       height: 100,
//       child: s.CupertinoPicker.builder(
//         itemExtent: 25, //height of each item
//         childCount: locales.length,
//         scrollController: controller,
//         onSelectedItemChanged: widget.onSelectedItemChanged,
//         itemBuilder: (BuildContext context, int index) => Text(
//           locales[index].countryCode == null
//               ? locales[index].languageCode
//               : '${locales[index].languageCode}-${locales[index].countryCode}',
//           style: const TextStyle(fontSize: 20),
//         ),
//       ));
// }
