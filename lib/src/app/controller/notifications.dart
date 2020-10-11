import 'dart:async';
import 'dart:math' show Random;
import 'dart:typed_data' show Int64List;
import 'dart:ui';

import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

/// IMPORTANT: running the following code on its own won't work as there is setup required for each platform head project.
/// Please download the complete example app from the GitHub repository where all the setup has been done

class FlutterNotifications {
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
      await showDialog(
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

      String title;

      if (data.length > 1) {
        title = data[0];
      } else {
        title = null;
      }

      final String content = data[data.length-1];

      await showDialog(
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
      _notificationAppLaunchDetails = value;
    });

    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
      _didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    });

    final initializationSettings = InitializationSettings(
         android: initializationSettingsAndroid,  iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      _selectNotificationSubject.add(payload);
    });
  }
  static FlutterNotifications _this;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  BehaviorSubject<ReceivedNotification> _didReceiveLocalNotificationSubject;
  BehaviorSubject<String> _selectNotificationSubject;
  NotificationAppLaunchDetails _notificationAppLaunchDetails;

  /// Supply a initAsync() function for the user.
  /// Initialize the plugin by requesting permissions.
  Future<bool> initAsync() => requestPermissions();

  /// Initialize the plugin by requesting permissions. (iOS only)
  Future<bool> requestPermissions() => _flutterLocalNotificationsPlugin
      ?.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: false,
        badge: true,
        sound: true,
      );

  /// Indicates if the app was launched via notification
  bool get didNotificationLaunchApp =>
      _notificationAppLaunchDetails?.didNotificationLaunchApp;

  /// The payload of the notification that launched the app
  String get payload => _notificationAppLaunchDetails?.payload;

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<int> set(DateTime dateTime, String title, String body) async {
    //
    if (dateTime == null ||
        DateTime.now().isAfter(dateTime) ||
        title == null ||
        title.isEmpty ||
        body == null ||
        body.isEmpty) {
      return -1;
    }

    final vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
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
        IOSNotificationDetails(sound: 'slow_spring_board.aiff');

    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    final id = Random().nextInt(999);

    final String date = DateFormat('EEEE, MMM dd  h:mm a').format(dateTime);

    final String payload = '$title\n$date';

    await _flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      dateTime,
      platformChannelSpecifics,
      payload: payload,
    );

    return id;
  }

  /// Cancel a specific notification.
  Future<void> cancel(int id) async {
    if (id != null && id > -1) {
      await _flutterLocalNotificationsPlugin.cancel(id);
    }
    return;
  }

  @mustCallSuper
  void dispose() {
    _didReceiveLocalNotificationSubject.close();
    _selectNotificationSubject.close();
  }
}

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
  final int id;
  final String title;
  final String body;
  final String payload;
}

class SecondScreen extends StatefulWidget {
  const SecondScreen(this.payload, {Key key}) : super(key: key);
  final String payload;
  @override
  State<StatefulWidget> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  String _payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen with payload: ${_payload ?? ''}'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
