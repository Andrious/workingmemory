//
import '/src/view.dart' hide ColorPicker;

import '/src/model.dart' hide Icon, Icons;

import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';

/// Notification Sounds
class PhoneSounds {
  ///
  Future<bool> initAsync() async {
    // List of Ringtones
    _notifications = await FlutterSystemRingtones.getNotificationSounds();
    return true;
  }

  final double _fontSize = 18;

  /// Notification sounds.
  List<Ringtone> get notifications => _notifications ??= [];
  List<Ringtone>? _notifications;

  /// Selected Ringtone.
  String get ringToneId => _ringToneId ?? ' ';
  String? _ringToneId;

  int _ringToneIndex = 0;

  // Stores the current Ringtone
  ScrollController? _controller;

  late BuildContext _context;

  /// Display the Notification Sounds
  Future<void> show(BuildContext _context) async {
    // Current saved Ringtone
    _ringToneId = Prefs.getString('RingTone');
    Ringtone? currentTone;
    if (_ringToneId != null && _ringToneId!.isNotEmpty) {
      currentTone =
          _notifications?.firstWhere((tone) => tone.id == _ringToneId);
    }
    if (currentTone != null) {
      _ringToneIndex = _notifications!.indexOf(currentTone);
      _controller = ScrollController(
          initialScrollOffset: 2 * _fontSize * _ringToneIndex + 1);
    }

    //
    this._context = _context;
    final leftHanded = Settings.leftSided;
    final ringtones = notifications;

    final ringTone = await showDialog<String>(
      context: _context,
      builder: (BuildContext context) {
        App.dependOnInheritedWidget(context);
        return AlertDialog(
          title: Text('NOTIFICATIONS SOUNDS'.tr),
          titlePadding: const EdgeInsets.only(left: 10, top: 20),
          contentPadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: 100.w, // % of screen width
            height: 80.h, // % of screen height
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    controller: _controller,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: ringtones.length,
                    itemBuilder: (BuildContext context, int index) {
                      final _selected = _ringToneIndex == index;
                      Widget _title = Text(
                        ringtones[index].title,
                        style: TextStyle(
                          // backgroundColor:
                          //     _ringToneIndex == index ? Colors.blue : null,
                          fontSize: _fontSize,
                        ),
                      );
                      if (_selected) {
                        _title = Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(flex: 3, child: _title),
                            Flexible(
                              child: IconButton(
                                onPressed: () {
                                  // FlutterBeep.playSysSound(
                                  //     int.parse(ringtones[index].id));
                                },
                                icon: const Icon(Icons.volume_up_sharp),
                              ),
                            ),
                          ],
                        );
                      }
                      return AlignListTile(
                        selected: _selected,
                        title: _title,
                        onTap: () {
                          _ringToneIndex = index;
                          _ringToneId = ringtones[index].id;
                          App.notifyClients();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    if (leftHanded) doneButton else cancelButton,
                    if (leftHanded) cancelButton else doneButton,
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ringTone != null) {
      await Prefs.setString('RingTone', ringTone);
    }
  }

  ///
  Widget get doneButton => App.useCupertino
      ? CupertinoButton(
          onPressed: () {
            Navigator.of(_context).pop<String>(_ringToneId);
          },
          child: Text('Done'.tr),
        )
      : ElevatedButton(
          onPressed: () {
            Navigator.of(_context).pop<String>(_ringToneId);
          },
          child: Text('Done'.tr),
        );

  ///
  Widget get cancelButton => App.useCupertino
      ? CupertinoButton(
          onPressed: () => Navigator.of(_context).pop(),
          child: Text('Cancel'.tr),
        )
      : ElevatedButton(
          onPressed: () => Navigator.of(_context).pop(),
          child: Text('Cancel'.tr),
        );
}
