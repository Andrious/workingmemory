import 'dart:async';
import 'dart:math' show Random;
import 'dart:typed_data' show Int64List;
import 'dart:ui';

import 'package:intl/intl.dart' show DateFormat;
import 'package:timezone/timezone.dart' as tz;

import '/src/controller.dart';

import '/src/view.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

///
class FlutterNotifications {
  ///
  factory FlutterNotifications(BuildContext context) =>
      _this ??= FlutterNotifications._(context);

  /// Private Constructor
  FlutterNotifications._(BuildContext context) {
    // needed if you intend to initialize in the `main` function
    WidgetsFlutterBinding.ensureInitialized();

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    _didReceiveLocalNotificationSubject =
        BehaviorSubject<ReceivedNotification>();

    _didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        SecondScreen(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });

    _selectNotificationSubject = BehaviorSubject<String>();

    _selectNotificationSubject.stream.listen((String payload) async {
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
      // );

      final List<String> data = payload.split('\n');

      String? title;

      if (data.length > 1) {
        title = data[0];
      } else {
        title = null;
      }

      final String content = data[data.length - 1];

      await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: title == null ? null : Text(title),
            content: Text(content),
          );
        },
      );
    });

    _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((value) {
      if (value != null) {
        _notificationAppLaunchDetails = value;
      }
    });

    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final initializationSettingsIOS = DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        _didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title ?? '',
            body: body ?? '',
            payload: payload ?? '',
          ),
        );
      },
    );

    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: (String payload) async {
      //   _selectNotificationSubject.add(payload);
      // },
    );
  }
  static FlutterNotifications? _this;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late BehaviorSubject<ReceivedNotification>
      _didReceiveLocalNotificationSubject;
  late BehaviorSubject<String> _selectNotificationSubject;
  late NotificationAppLaunchDetails _notificationAppLaunchDetails;

  /// Supply a initAsync() function for the user.
  /// Initialize the plugin by requesting permissions.
  Future<bool?>? initAsync() => requestPermissions();

  /// Initialize the plugin by requesting permissions. (iOS only)
  Future<bool?>? requestPermissions() => _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        badge: true,
        sound: true,
      );

  /// Indicates if the app was launched via notification
  bool get didNotificationLaunchApp =>
      _notificationAppLaunchDetails.didNotificationLaunchApp;

  // /// The payload of the notification that launched the app
  // String get payload => _notificationAppLaunchDetails.payload;

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<int> set(
    BuildContext context,
    DateTime? dateTime,
    String? timeZone,
    String? title,
    String? body, {
    bool? ignorePastDue,
    bool? saveTimeZone,
    bool? androidAllowWhileIdle,
    UILocalNotificationDateInterpretation?
        uiLocalNotificationDateInterpretation,
  }) async {
    //
    if (dateTime == null ||
        title == null ||
        title.isEmpty ||
        body == null ||
        body.isEmpty) {
      return -1;
    }

    // If true, simply return in failure;
    ignorePastDue ??= false;

    if (DateTime.now().isAfter(dateTime)) {
      if (!ignorePastDue) {
        final now = DateTime.now();
        final message =
            '\n\n${'That time has past:'.tr}\n$dateTime\n\n${'Current time:'.tr}\n$now';
        await MsgBox(context: context).show(
          title: message,
          msg: 'Please correct time.'.tr,
        );
      }
      return -1;
    }

    final vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id', 'your other channel name',
        channelDescription: 'your other channel description',
        icon: 'secondary_icon',
        sound: const RawResourceAndroidNotificationSound('slow_spring_board'),
        largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(sound: 'slow_spring_board.aiff');

    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    int id = Random().nextInt(999);

    final String date = DateFormat('EEEE, MMM dd  h:mm a').format(dateTime);

    final String payload = '$title\n$date';

    androidAllowWhileIdle ??= true;

    uiLocalNotificationDateInterpretation ??=
        UILocalNotificationDateInterpretation.wallClockTime;

    final location =
        await _getLocation(context, timeZone, saveTimeZone: saveTimeZone);

    final scheduledDate = tz.TZDateTime.from(dateTime, location);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: androidAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            uiLocalNotificationDateInterpretation,
      );
    } catch (ex) {
      id = -1;
      App.catchError(ex);
    }
    return id;
  }

  Future<tz.Location> _getLocation(BuildContext context, String? userTimeZone,
      {bool? saveTimeZone}) async {
    // Prompt the user to pick a Timezone if the device's and this one don't match.
    saveTimeZone ??= false;

    // Retrieve the app's last used timezone.
    if (userTimeZone == null || userTimeZone.isEmpty) {
      userTimeZone = Prefs.getString('timezone');
    }

    final timeZone = TimeZone();

    // The device's timezone.
    String timeZoneName = await timeZone.getTimeZoneName();

    // Merely use the device's timezone.
    if (userTimeZone.isEmpty) {
      //
      await Prefs.setString('timezone', timeZoneName);
    } else if (userTimeZone != timeZoneName) {
      //
      var stay = saveTimeZone;

      if (!stay) {
        final message =
            "${"We're in a new timezone.".tr}\n\n${'We are now in the timezone:'.tr}\n$timeZoneName\n\n${'Shall we stay in the timezone?:'.tr}\n$userTimeZone";
        stay = await showBox(
          context: context,
          text: message,
          button01: Option(text: 'Stay', result: true),
          button02: Option(text: 'New', result: false),
        );
      }
      // Stay with your previously used timezone.
      if (stay) {
        timeZoneName = userTimeZone;
      } else {
        await Prefs.setString('timezone', timeZoneName);
      }
    }
    return timeZone.getLocation(timeZoneName);
  }

  /// Cancel a specific notification.
  Future<void> cancel(int? id) async {
    if (id != null && id > -1) {
      await _flutterLocalNotificationsPlugin.cancel(id);
    }
    return;
  }

  ///
  @mustCallSuper
  void dispose() {
    _didReceiveLocalNotificationSubject.close();
    _selectNotificationSubject.close();
  }
}

///
class ReceivedNotification {
  ///
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  ///
  final int id;

  ///
  final String title;

  ///
  final String body;

  ///
  final String payload;
}

///
class SecondScreen extends StatefulWidget {
  ///
  const SecondScreen(this.payload, {Key? key}) : super(key: key);

  ///
  final String payload;
  @override
  State<StatefulWidget> createState() => _SecondScreenState();
}

///
class _SecondScreenState extends State<SecondScreen> {
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  late String _payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen with payload: $_payload'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
