import 'package:workingmemory/src/view.dart';

///
class TodoPage extends StatefulWidget {
  ///
  const TodoPage({Key? key, this.todo, this.onPressed}) : super(key: key);

  ///
  final Map<String, dynamic>? todo;

  ///
  final VoidCallback? onPressed;

  @override
  // ignore: no_logic_in_create_state
  State createState() => App.useMaterial ? TodoAndroid() : TodoiOS();
}
