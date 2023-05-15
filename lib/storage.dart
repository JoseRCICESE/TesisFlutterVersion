library file_storage;
import 'dart:ffi';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> localFile(name) async {
  final path = await _localPath;
  print('$path get local file');
  return File('$path/$name');
}

Future<File> writeToFile(String data, String name, bool append) async {
  final file = await localFile(name);
  print('${file.path}write to file');

  // Write the file
  if (append) {
    return file.writeAsString(data, mode: FileMode.append, flush: true, encoding: Encoding.getByName("UTF-8"));
  } else {
    return file.writeAsString(data);
  }
}

void saveFile(File file, name) async {
  final newFile = await localFile(name);
  print('$newFile write to file');

  // Save the file
  file.copy(newFile.path);
}

Future<String> readFromFile(name) async {
  try {
    final file = await localFile(name);

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "nothing here";
  }
}
  
}

class Encoding {
  static getByName(String s) {}
}