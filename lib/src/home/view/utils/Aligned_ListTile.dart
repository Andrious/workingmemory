import 'package:workingmemory/src/model.dart';

import 'package:workingmemory/src/view.dart';

///
///
///
class AListTile extends StatefulWidget {
  ///
  const AListTile({
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

  @override
  State<StatefulWidget> createState() => _AListTileState();
}

class _AListTileState extends State<AListTile> {
  @override
  Widget build(BuildContext context) {
    Widget? leading;
    Widget? trailing;
    final _leftHanded = Settings.isLeftHanded();

    if (_leftHanded) {
      leading = widget.box;
    } else {
      trailing = widget.box;
    }
    return ListTile(
      leading: leading,
      title: Align(
        alignment: _leftHanded ? Alignment.center : Alignment.centerLeft,
        child: widget.title ?? const Text(''),
      ),
      subtitle: Align(
        alignment: _leftHanded ? Alignment.centerRight : Alignment.centerLeft,
        child: widget.subtitle ?? const Text(''),
      ),
      trailing: trailing,
      onTap: widget.onTap,
      selected: widget.selected ?? false,
      autofocus: widget.autofocus ?? false,
    );
  }
}
