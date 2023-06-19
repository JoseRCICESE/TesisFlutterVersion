import 'package:TRHEAD/web3.utils.dart';
import 'package:TRHEAD/storage.dart';
import 'package:TRHEAD/classified_image.dart';
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

  @override
  void initState() {
    Web3Utils().getRecords().then((value) {
      setState(() {
        records = value.toString();
        imagesList = value.map((e) => ClassifiedImage(e[0].toString(), e[1].toString(), e[2].toString(), e[3].toString(), e[4].toString(), empty, empty)).toList();
        print(imagesList[0].cid);
        for (var element in imagesList) {
          Web3Utils().getSupporters([element.cid]).then((value) {
            setState(() {
              print("$value is the supporters value");
              element.supporters = value.toString().split(",");
              print("${element.supporters} is the supporters list in the image");
            });
          });
          Web3Utils().getOpposers([element.cid]).then((value) {
            setState(() {
              print("$value is the opposers value");
              element.opposers = value.toString().split(",");
              print("${element.opposers} is the opposers list in the image");
            });
          });
        }
      });
    });
    FileStorage().readFromFile("uuid").then((value) {
      setState(() {
      print('$value is the uuid that was read from file');
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
          SingleChildScrollView(
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
        ],
      ),
    );
  }
}

