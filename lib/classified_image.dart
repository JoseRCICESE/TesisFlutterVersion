library classsified_image;

import 'dart:convert';

class ClassifiedImage {
  late String cid;
  late String emotion;
  late String sourceUuid;
  late String name;
  late String size;
  late List<String> supporters;
  late List<String> opposers;
  

  ClassifiedImage(
    this.cid,
    this.emotion,
    this.sourceUuid,
    this.name,
    this.size,
    this.supporters,
    this.opposers,
  );

  ClassifiedImage.fromJson(Map<String, dynamic> json) {
    cid = json['cid'] ?? "";
    name = json['Name'] ?? "";
    size = json['Size'] ?? "";
  }

    ClassifiedImage.complete(String emotion, String uuid) {
      emotion = emotion;
      sourceUuid = uuid;
    }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cid'] = cid;
    data['emotion'] = emotion;
    data['sourceUuid'] = sourceUuid;
    data['name'] = name;
    data['size'] = size;
    
    return data;
  } 

  List<ClassifiedImage> parseResponse(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<String, dynamic>();

  return parsed.map<ClassifiedImage>((json) => ClassifiedImage.fromJson(json)).toList();
  }

  void setSupporters (List<String> supporters) {
    supporters = supporters;
  }

  void setOpposers (List<String> opposers) {
    opposers = opposers;
  }
}