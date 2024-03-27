import 'package:workingmemory/src/model.dart';

import 'package:workingmemory/src/view.dart';

///
///
///
class AlignListTile extends StatelessWidget {
  //} StatefulWidget {
  ///
  const AlignListTile({
    super.key,
    this.title,
    this.subtitle,
    this.box,
    this.onTap,
    this.selected,
    this.autofocus,
  });

  ///
  final Widget? title;

  ///
  final Widget? subtitle;

  ///
  final Widget? box;

  /// Called when the user taps this list tile.
  final GestureTapCallback? onTap;

  /// Selected or not
  final bool? selected;

  /// The color for the tile's [Material] when it has the input focus.
  final bool? autofocus;

//   @override
//   State<StatefulWidget> createState() => _AListTileState();
// }
//
// class _AListTileState extends State<AListTile> {
  @override
  Widget build(BuildContext context) {
    Widget? leading;
    Widget? trailing;
    final _leftHanded = Settings.leftSided;

    if (_leftHanded) {
      leading = box; //widget.box;
    } else {
      trailing = box; //widget.box;
    }
    return ListTile(
      leading: leading,
      title: Align(
        alignment: _leftHanded ? Alignment.center : Alignment.centerLeft,
        child: title ?? const Text(''), // widget.title ?? const Text(''),
      ),
      subtitle: subtitle == null // widget.subtitle == null
          ? null
          : Align(
              alignment:
                  _leftHanded ? Alignment.centerRight : Alignment.centerLeft,
              child: subtitle, //widget.subtitle,
            ),
      trailing: trailing,
      onTap: onTap, // widget.onTap,
      selected: selected ?? false, // widget.selected ?? false,
      autofocus: autofocus ?? false, // widget.autofocus ?? false,
    );
  }
}
