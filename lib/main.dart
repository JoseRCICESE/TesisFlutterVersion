import 'package:TRHEAD/carousel.dart';
import 'package:TRHEAD/storage.dart';
import 'package:TRHEAD/classified_image.dart';
import 'package:TRHEAD/web3.utils.dart';
import 'package:TRHEAD/personalized_widgets.dart';
import 'package:TRHEAD/per_stats.dart';
//import 'package:TRHEAD/pdf_view.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

void main() async {
  await dotenv.load(fileName: ".env");
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
        home: RouteSplash(fileHandler: FileStorage()),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}

// ...

class MyHomePage extends StatefulWidget {
   const MyHomePage({super.key, required this.fileHandler});

  final FileStorage fileHandler;
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
          page = UserProfile(fileHandler: FileStorage());
          break;
        case 1:
          page = TakePic(fileHandler: FileStorage());
          break;
        case 2:
          page = Carousel();
          break;
        case 3:
          page = Stats();
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
                    NavigationRailDestination(
                      icon: Icon(Icons.check_circle),
                      label: Text('Validación'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart),
                      label: Text('Estadísticas'),
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
  const UserProfile({super.key, required this.fileHandler});

  final FileStorage fileHandler;
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String username = globals.username;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(text: "Entonces te llamas:"),
            Container(
              margin: EdgeInsets.all(25),
              width: 400,
              child: TextFormField(
                initialValue: username,
                onChanged: (value) {
                  setState(() {
                    username = value;
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
                    widget.fileHandler.writeToFile(username, "profile", false);
                    globals.username = username;
                  },
                  icon: Icon( Icons.check_circle),
                  label: Text('Correcto'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TakePic extends StatefulWidget {
  const TakePic({super.key, required this.fileHandler});

  final FileStorage fileHandler;
  @override
  State<TakePic> createState() => _TakePicState();
}

class _TakePicState extends State<TakePic> {
  var image = Image.asset('assets/fred_expressions/neutral.png');
  var happy = Image.asset('assets/fred_expressions/happy.png');
  var sad = Image.asset('assets/fred_expressions/sad.png');
  var angry = Image.asset('assets/fred_expressions/angry.png');
  var surprised = Image.asset('assets/fred_expressions/surprised.png');
  var neutral = Image.asset('assets/fred_expressions/neutral.png');

  List<String> emotions = ["feliz", "triste", "enojado", "sorprendido", "neutral"];
  final _random = Random();
  String emotion = "neutral";
  List<String> empty = [];
  var response = {};

  Future<void> imageUpload(source) async {
    ImagePicker picker = ImagePicker();
    XFile? file;
    if (source == "camera") {
      file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 10,
        preferredCameraDevice: CameraDevice.rear);
    } else {
      file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 10,
        );
    }
    if (file == null) return;
    await ipfsUpload(file.path);
    var classification = saveClassification();
    Web3Utils web3 = Web3Utils();
    const snackBar = SnackBar(
      content: Text('Imagen subida correctamente'),
    );
    web3.addRecord([classification['cid'], classification['emotion'], classification['sourceUuid'], classification['name'], classification['size']])
    .then((value) {
      setState(() {
        print(value);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      });
    globals.classification = classification.toString();
    widget.fileHandler.writeToFile(globals.classification, "classifications", true);
  }

  String switchExpression() {
    emotion = emotions[_random.nextInt(emotions.length)];
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
  saveClassification () {
    var res = jsonDecode(globals.response);
    return ClassifiedImage(res['Hash'], emotion, globals.uuid, res['Name'], res['Size'], empty, empty).toJson();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: BigCard(text: 'Fred está $emotion, intenta imitarlo.'),
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
                  child: Image(image: image.image, width: 350, height: 270, fit: BoxFit.fill)),
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

Future<void> ipfsUpload(String filePath) async {
  var infuraProjectId = dotenv.env['INFURA_PROJECT_ID'] as String;
  var infuraProjectSecret = dotenv.env['INFURA_PROJECT_SECRET'] as String;

  var apiUrl = Uri.parse(dotenv.env['IPFS_ENDPOINT'] as String);

  var request = http.MultipartRequest('POST', apiUrl);
  request.headers['Authorization'] =
      'Basic ${base64Encode(utf8.encode('$infuraProjectId:$infuraProjectSecret'))}';
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  var response = await request.send();

  if (response.statusCode == 200) {
    // File uploaded successfully
    var responseBody = await response.stream.bytesToString();
    globals.response = responseBody;
    print('IPFS Response: $responseBody');
  } else {
    // Handle error
    print('Failed to upload file to IPFS. Error: ${response.statusCode}');
  }
}

class RouteSplash extends StatefulWidget {
    const RouteSplash({super.key, required this.fileHandler});
    final FileStorage fileHandler;
  @override
  _RouteSplashState createState() => _RouteSplashState();
}

class _RouteSplashState extends State<RouteSplash> {
  bool shouldProceed = false;

  _fetchPrefs() async {
    await Future.delayed(Duration(seconds: 1));// dummy code showing the wait period while getting the preferences
    setState(() {
      shouldProceed = true;//got the prefs; set to some value if needed
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPrefs();//running initialisation code; getting prefs etc.
    widget.fileHandler.readFromFile("profile").then((value) {
          setState(() {
              globals.username = value;
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 15),
          Container(
            margin: EdgeInsets.all(15),
            child: BigCard(text: "Bienvenido a TRHEAD")),
          Container(
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
                  border: Border.all(
                    width: 5,
                    color: Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(20), 
                ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "A continuación se espera que introduzca su nombre para poder identificarlo en la red.\nAl presionar el ícono de cámara en la barra lateral, se le pedirá que tome una foto de su rostro para imitar al robot FRED.\nPresionar el ícono de checkmark le permitirá clasificar imágenes subidas por otros usuarios en base a su validez para entrenar un modelo de aprendizaje de máquinas para la detección de emociones.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
                  border: Border.all(
                    width: 5,
                    color: Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(20), 
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: 
                    TextButton(
                  child: Text("Continuar implica que acepta firmar la carta de consentimiento que puede consultar presionando aquí",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PdfViewer()),
                      );
                    }
                  )
                  ),
              ),
            ]       
          ),
          Center(
            child: shouldProceed
                ? ElevatedButton(
                    onPressed: () {
                      widget.fileHandler.readFromFile("uuid").then((value) {
                        setState(() {
                            if (value == "nothing here") {
                              globals.uuid = Uuid().v4();
                              widget.fileHandler.writeToFile(globals.uuid, "uuid", false);
                            } else {
                              globals.uuid = value;
                            }
                          });
                        });
                      //move to next screen and pass the prefs if you want
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage(fileHandler: FileStorage(),)),
                      );
                    },
                    child: Text("Empecemos"),
                  )
                : CircularProgressIndicator(),//show splash screen here instead of progress indicator
          ),
        ],
      ),
    );
  }
}

class PdfViewer extends StatelessWidget {
  const PdfViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carta de consentimiento',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 23, 245, 89)),
        ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Carta  de consentimiento para uso de datos')),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final pdfController = PdfController(
    document: PdfDocument.openAsset("assets/CartaDeConsentimiento_TRHEAD.pdf"),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 600,
          margin: EdgeInsets.all(10),
          child: PdfView(
          controller: pdfController,
          ),
        ),
        FloatingActionButton(
          onPressed: () {
            //MaterialPageRoute(builder: (context) => MyHomePage(fileHandler: FileStorage(),)),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RouteSplash(fileHandler: FileStorage(),)),
            );
            //Navigator.pop(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.arrow_back),
        ),
      ]
    );
  }
}