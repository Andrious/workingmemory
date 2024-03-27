// Copyright 2023 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' show StateSetter;

import 'package:workingmemory/src/model.dart';

import 'package:workingmemory/src/view.dart' hide ColorPicker;

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// ignore: avoid_classes_with_only_static_members
/// Concerned with a ColorWheel
///
/// Cricin  2019
/// https://github.com/Cricin/ColorPicker-flutter
///
class LEDColor {
  /// Currently selected color
  static Color? get selectedColor =>
      _selectedColor ??= Color(Prefs.getInt('LEDColor', Colors.blue.value));

  static Color? _selectedColor;

  static StateSetter? _setStateFunc;

  /// Display the LED Colour for the Notification
  static Future<Color?> show({
    required BuildContext context,
    Color? color,
    ValueChanged<Color>? onColorChanged,
    HSVColor? pickerHsvColor,
    ValueChanged<HSVColor>? onHsvColorChanged,
    PaletteType? paletteType,
    bool? enableAlpha,
    List<ColorLabelType>? labelTypes,
    bool? colorIndicator,
    bool? paletteSlider,
    bool? displayThumbColor,
    bool? portraitOnly,
    double? colorPickerWidth,
    double? pickerAreaHeightPercent,
    BorderRadius? pickerAreaBorderRadius,
    bool? hexInputBar,
    TextEditingController? hexInputController,
    List<Color>? colorHistory,
    ValueChanged<List<Color>>? onHistoryChanged,
    Widget? title,
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleTextStyle,
    EdgeInsetsGeometry? contentPadding,
    Color? backgroundColor,
    double? elevation,
    String? semanticLabel,
    EdgeInsets? insetPadding,
    Clip? clipBehavior,
    ShapeBorder? shape,
    AlignmentGeometry? alignment,
    bool? barrierDismissible,
    Color? barrierColor,
    String? barrierLabel,
    bool? useSafeArea,
    bool? useRootNavigator,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    EdgeInsetsGeometry? padding,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
  }) async {
    //
    _selectedColor ??= Color(Prefs.getInt('LEDColor', Colors.blue.value));

    final _colorWheel = ColorPicker(
      pickerColor: _selectedColor!,
      onColorChanged: (Color color) {
        _selectedColor = color;
        if (onColorChanged != null) {
          onColorChanged(color);
        }
        if (_setStateFunc != null) {
          // Calls the StatefulBuilder's State object.
          _setStateFunc!(() {});
        }
      },
      pickerHsvColor: pickerHsvColor,
      onHsvColorChanged: onHsvColorChanged,
      paletteType: paletteType ?? PaletteType.hueWheel,
      enableAlpha: enableAlpha ?? false,
      labelTypes: labelTypes ?? const [],
      colorIndicator: colorIndicator ?? false,
      paletteSlider: paletteSlider ?? false,
      displayThumbColor: displayThumbColor ?? false,
      portraitOnly: portraitOnly ?? false,
      colorPickerWidth: colorPickerWidth ?? 300,
      pickerAreaHeightPercent: pickerAreaHeightPercent ?? 0.7,
      pickerAreaBorderRadius: pickerAreaBorderRadius ??
          const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
      hexInputBar: hexInputBar ?? false,
      hexInputController: hexInputController,
      colorHistory: colorHistory,
      onHistoryChanged: onHistoryChanged,
    );

    final _content = StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        _setStateFunc = setState;
        return Column(
          mainAxisSize: MainAxisSize.min, // Important to keep it compact.
          children: <Widget>[
            // Displays the current color selected.
            Container(
              alignment: alignment ?? Alignment.center,
              padding: padding,
              color: _selectedColor,
              decoration: decoration,
              foregroundDecoration: foregroundDecoration,
              width: width ?? 30.w,
              height: height ?? 5.h,
              constraints: constraints,
              margin: margin,
              transform: transform,
              transformAlignment: transformAlignment,
//              clipBehavior: clipBehavior ?? Clip.none,
              // child: Text(
              //     _selectedColor!.value.toRadixString(16).toUpperCase()),
              child: const Text(''),
            ),
            _colorWheel,
          ],
        );
      },
    );

    // Function called when the OK button is pressed.
    void okBtnPressed() {
      Prefs.setInt('LEDColor', _selectedColor!.value);
      Navigator.pop<Color>(context, _selectedColor);
    }

    // Function when cancel button is pressed.
    void cancelBtnPressed() {
      Navigator.pop(context);
    }

    final _color = await showDialog<Color>(
        context: context,
        barrierDismissible: barrierDismissible ?? true,
        barrierColor: barrierColor ?? Colors.black54,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea ?? true,
        useRootNavigator: useRootNavigator ?? true,
        routeSettings: routeSettings,
        anchorPoint: anchorPoint,
        builder: (BuildContext context) {
//           AlertDialog(
//             title: title,
//             titlePadding: titlePadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 0),
//             titleTextStyle: titleTextStyle,
//             contentPadding:
//             contentPadding ?? const EdgeInsets.fromLTRB(0, 12, 0, 16),
//             backgroundColor: backgroundColor,
//             elevation: elevation,
//             semanticLabel: semanticLabel,
//             insetPadding: insetPadding ??
//                 const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
// //          clipBehavior: clipBehavior ?? Clip.none,
//             shape: shape,
//             alignment: Alignment.center,
//             content: _content,
//             actions: _actions,
//           ),
          if (App.useMaterial) {
            //
            final _actions = <Widget>[];

            final okBtn = ElevatedButton(
              onPressed: okBtnPressed,
              child: const Text('OK'),
            );

            final cancelBtn = ElevatedButton(
              onPressed: cancelBtnPressed,
              child: const Text('Cancel'),
            );

            // Switch around the buttons when indicated.
            if (Settings.leftSided) {
              _actions.addAll([okBtn, cancelBtn]);
            } else {
              _actions.addAll([cancelBtn, okBtn]);
            }

            final _buttons = Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: _actions,
            );

            return SimpleDialog(
              title: title,
              titlePadding:
                  titlePadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 0),
              titleTextStyle: titleTextStyle,
              contentPadding:
                  contentPadding ?? const EdgeInsets.fromLTRB(0, 12, 0, 16),
              backgroundColor: backgroundColor,
              elevation: elevation,
              semanticLabel: semanticLabel,
              insetPadding: insetPadding ??
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              clipBehavior: clipBehavior ?? Clip.none,
              shape: shape,
//          alignment: alignment,
              children: <Widget>[
                _content,
                _buttons,
              ],
            );
          } else {
            //
            final okBtn = CupertinoDialogAction(
              onPressed: okBtnPressed,
              isDefaultAction: true,
//            textStyle:,
              child: const Text('OK'),
            );

            final cancelBtn = CupertinoDialogAction(
              onPressed: cancelBtnPressed,
//              textStyle:,
              child: const Text('Cancel'),
            );

            final _actions = <Widget>[];

            // Switch around the buttons when indicated.
            if (Settings.leftSided) {
              _actions.addAll([okBtn, cancelBtn]);
            } else {
              _actions.addAll([cancelBtn, okBtn]);
            }

            return CupertinoAlertDialog(
              title: title,
              content: _content,
              actions: _actions,
            );
          }
        });

    return _color;
  }
}
