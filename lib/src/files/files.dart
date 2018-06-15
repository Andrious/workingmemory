import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';


class Files {

  static String _path;

  static Future<String> get localPath async {

    if(_path == null) {
      var directory = await getApplicationDocumentsDirectory();
      _path = directory.path;
    }
    return _path;
  }



  static Future<String> read(String fileName) async {

    var file = await get(fileName);

    return readFile(file);
  }



  static Future<String> readFile(File file) async {

    String contents;

    try {
      // Read the file
      contents = await file.readAsString();

    } catch (e) {
      // If we encounter an error
      contents = '';
    }
    return contents;
  }



  static Future<File> write(String fileName, String content) async {
    var file = await get(fileName);
    // Write the file
    return writeFile(file, content);
  }



  static Future<File> writeFile(File file, String content) async {
    // Write the file
    return file.writeAsString(content, flush: true);
  }


  
  static Future<bool> exists(String fileName) async{
    var file = await get(fileName);
    return file.exists();
  }

  static Future<File> get(String fileName) async {
    var path = await localPath;
    return File('$path/$fileName');
  }
}