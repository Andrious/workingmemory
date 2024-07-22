import '/src/view.dart';

///
class DateTimeItem extends StatelessWidget {
  ///
  // ignore: use_key_in_widget_constructors
  const DateTimeItem({
    super.key,
    required this.dateTime,
    required this.onChanged,
  });

  ///
  final DateTime dateTime;

  ///
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => App.useCupertino
      ? DTiOS(key: key, dateTime: dateTime, onChanged: onChanged)
      : DTAndroid(key: key, dateTime: dateTime, onChanged: onChanged);
}
