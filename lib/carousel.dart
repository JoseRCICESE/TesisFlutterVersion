import 'package:TRHEAD/web3.utils.dart';
import 'package:TRHEAD/storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'globals.dart' as globals;

class Carousel extends StatefulWidget {
  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  List<String> imagesList = [];
  int _currentIndex = 0;
  bool _isImageValidated = false;
  List<String> _alreadyChecked = [];

  @override
  void initState() {
    Web3Utils().getRecords().then((value) {
      setState(() {
        print("${value[0]} is in the state of carousel");
        imagesList = value.map((e) => e[0].toString()).toList();

        print(imagesList);
      });
    });
    FileStorage().readFromFile("viewed").then((value) {
      setState(() {
        _alreadyChecked = value.split("\n").map((e) => e[0].toString()).toList();
        print(_alreadyChecked);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validación de imágenes'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: false,
                scrollDirection: Axis.horizontal,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                    _currentIndex = index;
                    if (_alreadyChecked.contains(imagesList[_currentIndex])) {
                      setState((){_isImageValidated = true;});
                    } else {
                      setState((){_isImageValidated = false;});
                    }
                  },
              ),
              items: imagesList
                  .map(
                    (item) => Center(
                      child: Image.network(
                        "https://tesis.infura-ipfs.io/ipfs/$item",
                        fit: BoxFit.cover,
                        width: 250,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: !_isImageValidated ? () {
                  Web3Utils().oppose([globals.uuid, imagesList[_currentIndex]])
                  .then((value) => print('$value is the result of the oppose transaction'));
                  FileStorage().writeToFile(imagesList[_currentIndex], "viewed", true);
                  setState(() {
                    _alreadyChecked.add(imagesList[_currentIndex]);
                    _isImageValidated = true;
                  });
                  Web3Utils().getOpposers([imagesList[_currentIndex]]).
                  then((value) => print('$value is the result of the getOpposers query'));
                } : null,
                label: Text('No válida'),
                icon: Icon( Icons.thumb_down),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton.icon(
                onPressed: !_isImageValidated ? () {
                  Web3Utils().support([globals.uuid, imagesList[_currentIndex]])
                  .then((value) => print('$value is the result of the support transaction'));
                  FileStorage().writeToFile(imagesList[_currentIndex], "viewed", true);
                  setState(() {
                    _alreadyChecked.add(imagesList[_currentIndex]);
                    _isImageValidated = true;
                  });
                  Web3Utils().getSupporters([imagesList[_currentIndex]]).
                  then((value) => print('$value is the result of the getSupporters query'));
                } : null,
                label: Text('Válida'),
                icon: Icon( Icons.thumb_up),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

