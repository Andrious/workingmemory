import 'package:flutter/material.dart';
import 'src/App.dart';
import 'src/loadingscreen.dart';


void main() {

  var app = App();

  // https://stackoverflow.com/questions/44379849/display-app-theme-immediately-in-flutter-app
  runApp(FutureBuilder(
    future: app.init(),
    builder: (_, snapshot) {
      return snapshot.hasData ? app : LoadingScreen();
    },
  ));

//  runApp(MaterialApp(
//    title: 'SharedPreferences Demo',
//    home: App(),
//  ));
}