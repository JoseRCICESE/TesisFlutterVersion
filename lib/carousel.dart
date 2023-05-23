import 'package:TRHEAD/personalized_widgets.dart';
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
        print('$imagesList is the list of images to be checked');

        FileStorage().readFromFile("viewed").then((value) {
          setState(() {
          print('$value is the value of the viewed file');
          if (value != "nothing here") {
            _alreadyChecked = value.split(" ").map((e) => e.toString()).toList();
            print('$_alreadyChecked is the list of images already checked');
            for (var i = 0; i < _alreadyChecked.length; i++) {
              imagesList.remove(_alreadyChecked[i]);
            }
          print('$imagesList is the list of images to be checked after removing the already checked ones');
            }
          });
        });
      });
    });
    setState(() {
      print(imagesList);
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
          Container(
            margin: EdgeInsets.all(25),
            child: BigCard(text: "¿Es esta imagen válida?")
            ),
          SizedBox(
            height: 15,
          ),
          CarouselSlider(
              options: CarouselOptions(
                height: 400,
                enableInfiniteScroll: true,
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
                    (item) => Image.network(
                        "https://tesis.infura-ipfs.io/ipfs/$item",
                        fit: BoxFit.fill,
                      ),
                  )
                  .toList(),
            ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: !_isImageValidated ? () {
                  print('${imagesList[_currentIndex]} is the actual image');
                  Web3Utils().oppose([globals.uuid, imagesList[_currentIndex]])
                  .then((value) => print('$value is the result of the oppose transaction'));
                  FileStorage().writeToFile('${imagesList[_currentIndex]} ', "viewed", true);
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
                  FileStorage().writeToFile('${imagesList[_currentIndex]} ', "viewed", true);
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

