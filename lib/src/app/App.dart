import 'dart:async';

import 'package:connectivity/connectivity.dart';

import '../files/files.dart';
import '../files/InstallFile.dart';

class App{

  static final Connectivity _connectivity = new Connectivity();
  
  static StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static String _installNum;
  static get installNum => _installNum;

  static String _path;
  static get filesDir => _path;

  static String _connectivityStatus;
  static get connectivity => _connectivityStatus;

  static get isOnline => _connectivityStatus != 'none';

  static Set _listeners = new Set();


  
  static init(){

    /// Get the installation number
    InstallFile.id()
        .then((id){_installNum = id;})
        .catchError((e){});

    /// Determine the location to the files directory.
    Files.localPath
        .then((path){_path = path;})
        .catchError((e){});

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
            _listeners.forEach((listener){listener.onConnectivityChanged(result);});
        });

    initConnectivity()
    .then((status){_connectivityStatus = status;})
    .catchError((e){_connectivityStatus = 'none';});
  }



  dispose(){

    _connectivitySubscription.cancel();
  }


  static Future<String> initConnectivity() async {
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } catch (ex) {
      connectionStatus = 'Failed to get connectivity.';
    }
    return connectionStatus;
  }



  static addConnectivityListener(ConnectivityListener listener){
    return _listeners.add(listener);
  }



  static removeConnectivityListener(ConnectivityListener listener){
    return _listeners.remove(listener);
  }



  static clearConnectivityListener(){
    return _listeners.clear();
  }


  
  bool get inDebugger {
    var inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}



abstract class ConnectivityListener{
   onConnectivityChanged(ConnectivityResult result);
}