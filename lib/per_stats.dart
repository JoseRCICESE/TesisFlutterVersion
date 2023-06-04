import 'package:TRHEAD/personalized_widgets.dart';
import 'package:TRHEAD/web3.utils.dart';
import 'package:TRHEAD/storage.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class Stats extends StatefulWidget {
  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  String uuid = "";
  String records = "";

  @override
  void initState() {
    Web3Utils().getRecords().then((value) {
      setState(() {
        records = value.toString();
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
            margin: EdgeInsets.all(25),
            child: BigCard(text: "Tu uuid es: $uuid")
            ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: _sharing,
            child: Text('Compartir'),
          ),
        ],
      ),
    );
  }
}

