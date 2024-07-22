///
/// Copyright (C) 2021 Andrious Solutions
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  04 Nov 2021

import '/src/view.dart';

///
/// This is just a basic `Scaffold` with a centered `CircularProgressIndicator`
/// class right in the middle of the screen.
///
/// It's copied from the `flutter_gallery` example project in flutter/flutter
///
class LoadingScreen extends StatefulWidget {
  ///
  const LoadingScreen(Key key) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
        appBar: AppBar(title: Text('Loading...'.tr)),
        body: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) =>
              const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

///
class WorkingSpinnerIndicator extends StatefulWidget {
  ///
  WorkingSpinnerIndicator({super.key, this.spinning});

  ///
  final bool? spinning;

  final List<_WorkingSpinIndicator?> _state = [];

  ///
  void start() => spin(true);

  ///
  void stop() => spin(false);

  ///
  // ignore: avoid_positional_boolean_parameters
  void spin([bool? work]) {
    if (_state.isNotEmpty) {
      _state[0]?._spin(work);
    }
  }

  ///
  bool get working => _state.isNotEmpty && _state[0]!.spinning;
  set working(bool? work) => spin(work);

  @override
  State<StatefulWidget> createState() => _WorkingSpinIndicator();
}

class _WorkingSpinIndicator extends State<WorkingSpinnerIndicator> {
  //
  bool spinning = false;

  void _spin([bool? work]) {
    if (work != null) {
      spinning = work;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    spinning = widget.spinning ?? false;
    widget._state.add(this);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget._state.clear();
    widget._state.add(this);
  }

  @override
  void dispose() {
    widget._state.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _widget;
    if (spinning) {
      _widget = App.useMaterial
          ? const Center(child: CircularProgressIndicator())
          : const Center(child: CupertinoActivityIndicator());
    } else {
      _widget = const SizedBox();
    }
    return _widget;
  }
}

///
class ScreenCircularProgressIndicator extends StatelessWidget {
  ///
  const ScreenCircularProgressIndicator({super.key});

  ///
  static final spinner = WorkingSpinnerIndicator();

  ///
  static void start() => spinner.start();

  ///
  static void stop() => spinner.stop();

  ///
  // ignore: avoid_positional_boolean_parameters
  static void spin([bool? work]) => spinner.spin(work);

  @override
  Widget build(BuildContext context) => spinner;
}
