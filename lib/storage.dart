library file_storage;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  print('${path}get local file');
  return File('$path/classifiedImages.txt');
}

Future<File> writeToFile(String classif) async {
  final file = await _localFile;
  print('${file.path}write to file');

  // Write the file
  return file.writeAsString(classif);
}

Future<String> readFromFile() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "nothing here";
  }
}
  
}