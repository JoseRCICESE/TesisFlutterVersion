library classsified_image;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ClassifiedImage {
  late String cid;
  late String emotion;
  late String sourceUuid;
  

  ClassifiedImage(
     this.cid,
     this.emotion,
    this.sourceUuid,
  
  );

  ClassifiedImage.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    emotion = json['emotion'];
    sourceUuid = json['sourceUuid'];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cid'] = cid;
    data['emotion'] = emotion;
    data['sourceUuid'] = sourceUuid;
    
    return data;
  }

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

Future<int> readFromFile() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return int.parse(contents);
  } catch (e) {
    // If encountering an error, return 0
    return 0;
  }
}
  
}