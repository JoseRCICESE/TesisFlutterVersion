import 'package:TRHEAD/web3.utils.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Carousel extends StatefulWidget {
  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  List<String> imagesList = [];

  @override
  void initState() {
    Web3Utils().getRecords().then((value) {
      setState(() {
        print("${value[0]} is in the state of carousel");
        imagesList = value.map((e) => e[0].toString()).toList();

        print(imagesList);
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Volver'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}