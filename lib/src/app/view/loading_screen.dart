import 'package:flutter/material.dart';

///
/// This is just a basic `Scaffold` with a centered `CircularProgressIndicator`
/// class right in the middle of the screen.
///
/// It's copied from the `flutter_gallery` example project in flutter/flutter
///
class LoadingScreen extends StatefulWidget {
  const LoadingScreen(Key key) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..forward();
    _animation = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.9, curve: Curves.fastOutSlowIn),
        reverseCurve: Curves.fastOutSlowIn)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _controller.forward();
        } else if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget child) {
                  return const Center(child: CircularProgressIndicator());
                })));
  }
}
