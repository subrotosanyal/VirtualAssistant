import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

class CareerScreen extends StatefulWidget {
  @override
  _CareerScreenState createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  File? resumeFile;
  String? resumeText;

  Future<List<int>> readDocumentData(File? file) async {
    if (file != null) {
      Uint8List bytes = file.readAsBytesSync();
      final ByteData data = ByteData.view(bytes.buffer);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    throw Exception('File is null');
  }

  Future<void> convertPdfToText() async {
    PdfDocument document =
        PdfDocument(inputBytes: await readDocumentData(resumeFile));

    //Create a new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the document.
    String text = extractor.extractText();
    setState(() {
      resumeText = text;
    });
  }

  Future<void> uploadResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDF files to be selected
    );

    if (result != null) {
      setState(() {
        resumeFile = File(result.files.single.path.toString());
      });
      return await convertPdfToText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Career Page'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              uploadResume();
            },
            child: Text('Upload Resume'),
          ),
          if (resumeText != null)
            Column(
              children: [
                // Widget for Recommendation Icon
                // ...

                // Widget for Headline Icon
                // ...

                // Widget for Profile Summary Icon
                // ...
              ],
            ),
        ],
      ),
    );
  }
}
