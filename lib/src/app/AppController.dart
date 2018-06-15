import 'dart:async';

import '../files/InstallFile.dart';

class AppController{



    static Future<String> getInstallNum(){

    return InstallFile.id();
  }


}
