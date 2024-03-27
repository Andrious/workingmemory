///
///          Created  09 Feb 2019
///          Andrious Solutions
///

/// Import the interface
import 'package:workingmemory/src/view.dart';

import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

///
class ColorPicker {
  ///
  static Future<ColorSwatch<int>?> show({
    required BuildContext context,
    Color? selectedColor,
    ColorSwatch<int?>? colorSwatch,
    ValueChanged<Color>? onColorChange,
    ValueChanged<ColorSwatch<int?>>? onChange,
    List<MaterialColor>? colors,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    bool? allowShades,
    bool? onlyShadeSelection,
    double? circleSize,
    double? spacing,
    IconData? iconSelected,
    VoidCallback? onBack,
    double? elevation,
    Widget? title,
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleTextStyle,
    EdgeInsetsGeometry? contentPadding,
    Color? backgroundColor,
    String? semanticLabel,
    EdgeInsets? insetPadding,
    Clip? clipBehavior,
    ShapeBorder? shape,
    AlignmentGeometry? alignment,
  }) {
    return showDialog<ColorSwatch<int>>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
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
          alignment: alignment,
          children: <Widget>[
            MaterialColorPicker(
              selectedColor: selectedColor ?? const Color(0xffff0000),
              onColorChange: (Color color) {
                selectedColor = color;
                if (onColorChange != null) {
                  onColorChange(color);
                }
                Navigator.pop(context, color);
              },
              onMainColorChange: (ColorSwatch<dynamic>? color) {
                selectedColor = color!;
                colorSwatch = color as ColorSwatch<int?>;
                if (onChange != null) {
                  onChange(color);
                }
                Navigator.pop(context, color);
              },
              colors: colors ?? Colors.primaries,
              allowShades: allowShades ?? false,
              shrinkWrap: shrinkWrap ?? true,
              circleSize: circleSize ?? 60,
              spacing: spacing ?? 9,
              iconSelected: iconSelected ?? Icons.check,
              onBack: onBack,
              elevation: elevation,
            ),
          ]),
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorPicker && runtimeType == other.runtimeType;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => 0;
}

///
enum DialogDemoAction {
  ///
  cancel,

  ///
  discard,

  ///
  disagree,

  ///
  agree,
}
