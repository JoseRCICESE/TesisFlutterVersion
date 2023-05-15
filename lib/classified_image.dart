library classsified_image;

import 'dart:convert';

class ClassifiedImage {
  late String cid;
  late String emotion;
  late String sourceUuid;
  late String name;
  late String size;
  

  ClassifiedImage(
    this.cid,
    this.emotion,
    this.sourceUuid,
    this.name,
    this.size,
  
  );

  ClassifiedImage.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    emotion = json['emotion'];
    sourceUuid = json['sourceUuid'];
    name = json['Name'];
    size = json['Size'];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cid'] = cid;
    data['emotion'] = emotion;
    data['sourceUuid'] = sourceUuid;
    data['name'] = name;
    
    return data;
  } 

  List<ClassifiedImage> parseResponse(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<ClassifiedImage>((json) => ClassifiedImage.fromJson(json)).toList();
  }
}