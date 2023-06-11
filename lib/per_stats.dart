import 'package:TRHEAD/web3.utils.dart';
import 'package:TRHEAD/storage.dart';
import 'package:TRHEAD/classified_image.dart';
import 'package:TRHEAD/user_stats.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class Stats extends StatefulWidget {
  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  String uuid = "";
  String records = "";
  List<ClassifiedImage> imagesList = [];
  List<String> empty = [];
  List<UserStats> users = [];
  List<String> uuids = [];
  bool showAllStats = true;

  @override
  void initState() {
    Web3Utils().getRecords().then((value) {
      setState(() {
        records = value.toString();
        imagesList = value.map((e) => ClassifiedImage(e[0].toString(), e[1].toString(), e[2].toString(), e[3].toString(), e[4].toString(), empty, empty)).toList();
        for (var element in imagesList) {
          Web3Utils().getSupporters([element.cid]).then((value) {
            setState(() {
              element.supporters = value.toString().split(",");
            });
          });
          Web3Utils().getOpposers([element.cid]).then((value) {
            setState(() {
              element.opposers = value.toString().split(",");
            });
          });
          uuids.add(element.sourceUuid);
        }
        uuids = uuids.toSet().toList();
        for (var element in uuids) {
          users.add(UserStats(element, 0, 0));
        }
        for (var user in users) {
          for (var element in imagesList) {
              if (element.sourceUuid == user.sourceUuid) {
                user.increaseTotalImages();
                if (element.supporters.contains(user.sourceUuid) || element.opposers.contains(user.sourceUuid)) {
                  user.increaseTotalClassified();
                }
              }
            }
        }
      });
    });
    FileStorage().readFromFile("uuid").then((value) {
      setState(() {
      if (value != "nothing here") {
        uuid = value;
        }
      });
    });
    super.initState();
  }

  void _sharing () {
    Share.share('Mi uuid es: $uuid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas personales'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: Text("Tu uuid es: $uuid"),
            ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
            onPressed: _sharing,
            child: Text('Compartir'),
          ),
          SizedBox(
            height: 25,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Mostrar todas las estadísticas"),
              Switch(
                value: showAllStats,
                onChanged: (value) {
                  setState(() {
                    showAllStats = value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ],
          ),

          Visibility(
            visible: !showAllStats,
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(5),
                height: 550,
                child: ListView.separated(        // To add separation line between the ListView 
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.green,
                  ),
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index){
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(users[index].sourceUuid),
                      subtitle: Text("Ha subido ${users[index].totalImages.toString()} y ha clasificado ${users[index].totalClassified.toString()} imágenes"),
                    );
                  },
                      ),
              ),
            ),
          ),
          Visibility(
            visible: showAllStats,
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(5),
                height: 550,
                child: ListView.separated(        // To add separation line between the ListView 
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.green,
                  ),
                    itemCount: imagesList.length,
                    itemBuilder: (BuildContext context, int index){
                    return ListTile(
                      leading: Icon(Icons.image),
                      title: Text(imagesList[index].name),
                      subtitle: Text("${imagesList[index].supporters.length.toString()} a favor, ${imagesList[index].opposers.length.toString()} en contra"),
                    );
                  },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

