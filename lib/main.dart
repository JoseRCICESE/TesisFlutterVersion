import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'TRHEAD',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 23, 245, 89)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = UserProfile();
          break;
        case 1:
          page = TakePic();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
        }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.camera_alt),
                      label: Text('Selfies'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String name = Platform.operatingSystem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Entonces te llamas:"),
          Container(
            margin: EdgeInsets.all(25),
            child: TextFormField(
              initialValue: name,
              onChanged: (value) {
                setState(() {
                  name = value;
                  print(name);
                });
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Introduce tu nombre',
                labelText: 'Nombre',
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  saveToFile([["username", name], ["uuid", Uuid().v4()]]);
                },
                icon: Icon( Icons.check_circle),
                label: Text('Correcto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TakePic extends StatefulWidget {
  @override
  State<TakePic> createState() => _TakePicState();
}

class _TakePicState extends State<TakePic> {
  var image = Image.asset('assets/base_avatar.jpg');
  var happy = Image.asset('assets/fred_expressions/happy.png');
  var sad = Image.asset('assets/fred_expressions/sad.png');
  var angry = Image.asset('assets/fred_expressions/angry.png');
  var surprised = Image.asset('assets/fred_expressions/surprised.png');
  var neutral = Image.asset('assets/fred_expressions/neutral.png');

  List<String> emotions = ["feliz", "triste", "enojado", "sorprendido", "neutral"];
  final _random = Random();
  /*Future<File> saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final File rawImage = await image.copy('${directory.path}/image1.png');
    print(rawImage.path);
    return rawImage;
  }*/
  Future<void> imageUpload(source) async {
    ImagePicker picker = ImagePicker();
    XFile? file;
    if (source == "camera") {
      file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 25,
        preferredCameraDevice: CameraDevice.rear);
    } else {
      file = await picker.pickImage(source: ImageSource.gallery);
    }
    if (file == null) return;
    File rawImage = File(file.path);
    await ipfsUpload(rawImage.path);
    /*setState(() {
      image = Image.file(rawImage);
    });*/
  }

  String switchExpression() {
    var emotion = emotions[_random.nextInt(emotions.length)];
    switch (emotion) {
      case "feliz":
        setState(() {
          image = happy;
        });
        break;
      case "triste":
        setState(() {
          image = sad;
        });
        break;
      case "enojado":
        setState(() {
          image = angry;
        });
        break;
      case "sorprendido":
        setState(() {
          image = surprised;
        });
        break;
      case "neutral":
        setState(() {
          image = neutral;
        });
        break;
      default:
        throw UnimplementedError('no widget for $emotion');
    }
    return emotion;
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
//hero goes the placeholder for the picture
          SizedBox(height: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.all(20),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Fred está ${switchExpression()}...\n...intenta imitarlo',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 8,
                    color: Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(20), 
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image(image: image.image, width: 350, height: 300, fit: BoxFit.fill)),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => {
                  imageUpload("camera"),
                  switchExpression(),
                },
                label: Text('Tomar Foto'),
                icon: Icon(Icons.camera_alt),
              ),
              SizedBox(height: 10),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => {
                  imageUpload("gallery"),
                  switchExpression(),
                },
                label: Text(' Subir Foto '),
                icon: Icon(Icons.upload),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

Future<void> ipfsUpload(String filePath) async {
  var infuraProjectId = '2KiK6S75slDQfxRFU5dfP7z7TQG';
  var infuraProjectSecret = '622237ae0de6536fe6464071ffa0a100';

  var apiUrl = Uri.parse('https://ipfs.infura.io:5001/api/v0/add?pin=true');

  var request = http.MultipartRequest('POST', apiUrl);
  request.headers['Authorization'] =
      'Basic ${base64Encode(utf8.encode('$infuraProjectId:$infuraProjectSecret'))}';
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  var response = await request.send();

  if (response.statusCode == 200) {
    // File uploaded successfully
    var responseBody = await response.stream.bytesToString();
    print('IPFS Response: $responseBody');
  } else {
    // Handle error
    print('Failed to upload file to IPFS. Error: ${response.statusCode}');
  }
}

void saveToFile(List<List<String>> content) async {
  final writer = await SharedPreferences.getInstance();
  for (var i = 0; i < content.length; i++) {
    await writer.setString(content[i][0], content[i][1]);
  }
  final checking = writer.getString('uuid');
  print(checking);
}

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
  
}