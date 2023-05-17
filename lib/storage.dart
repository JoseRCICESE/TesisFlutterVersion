library file_storage;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> localFile(name) async {
  final path = await _localPath;
  return File('$path/$name');
}

Future<File> writeToFile(String data, String name, bool append) async {
  final file = await localFile(name);

  // Write the file
  try {
  if (append) {
    return file.writeAsString(data, mode: FileMode.append, flush: true);
  } else {
    return file.writeAsString(data);
  }
  } catch (e) {
    print('$e this is the error');
  }
  return file.writeAsString("there was an error");
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