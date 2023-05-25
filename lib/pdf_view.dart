import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:TRHEAD/main.dart';

void main() => runApp(const PdfViewer());

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
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );*/
            Navigator.pop(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.arrow_back),
        ),
      ]
    );
  }
}