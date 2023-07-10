import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import '../util/chat_util.dart';

class CareerScreen extends StatefulWidget {
  final String apiKey;

  const CareerScreen({required this.apiKey});

  @override
  _CareerScreenState createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  File? resumeFile;
  String? resumeText;
  bool _isGeneratingRecommendation = false;
  String _recommendation = '';
  bool _isGeneratingProfileHeadline = false;
  bool _isRecommendationExpanded = false;
  bool _isProfileHeadlineExpanded = false;
  String _profileHeadline = '';
  bool isResumeUploaded = false;
  bool _showTextBox = false;
  String _selectedRecommendationOption = "Generic";
  int _numberOfWords = 350;
  final TextEditingController _recommendationController =
      TextEditingController();
  final TextEditingController _profileHeadlineController =
      TextEditingController();

  @override
  void dispose() {
    _recommendationController.dispose();
    _profileHeadlineController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKeyProfileHeadline = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyRecommendation = GlobalKey<FormState>();

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _generateRecommendation() async {
    setState(() {
      _isGeneratingRecommendation = true;
      updateRecommendation('');
    });
    final message =
        "Generate a recommendation for a professional in $_numberOfWords in paragraph format (not bullet points) using the text which is extracted from their CV is: $resumeText";
    try {
      final response = await ChatUtility.sendMessage(message, widget.apiKey);
      setState(() {
        updateRecommendation(
            response.map((choice) => '${choice.toString()}').join('\n'));
      });
    } catch (exp) {
      updateRecommendation(exp.toString());
    } finally {
      setState(() {
        _isGeneratingRecommendation = false;
        _showTextBox = true;
      });
    }
  }

  void updateRecommendation(String recommendation) {
    setState(() {
      _recommendation = recommendation;
      _recommendationController.text = recommendation;
    });
  }

  void _generateProfileHeadline() async {
    setState(() {
      _isGeneratingProfileHeadline = true;
      updateProfileHeadline('');
    });

    final message =
        "Generate a profile headline for a professional using the text which is extracted from their CV is: $resumeText";
    try {
      final response = await ChatUtility.sendMessage(message, widget.apiKey);
      updateProfileHeadline(
          response.map((choice) => '${choice.toString()}').join('\n'));
    } catch (exp) {
      updateProfileHeadline(exp.toString());
    } finally {
      setState(() {
        _isGeneratingProfileHeadline = false;
        _showTextBox = true;
      });
    }
  }

  void updateProfileHeadline(String profileHeadline) {
    setState(() {
      _profileHeadline = profileHeadline;
      _profileHeadlineController.text = profileHeadline;
    });
  }

  Future<List<int>> readDocumentData(File? file) async {
    if (file != null) {
      Uint8List bytes = await file.readAsBytes();
      final ByteData data = ByteData.view(bytes.buffer);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    throw Exception('File is null');
  }

  Future<void> convertPdfToText() async {
    PdfDocument document =
        PdfDocument(inputBytes: await readDocumentData(resumeFile!));

    // Create a new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    // Extract all the text from the document.
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
        resumeFile = File(result.files.single.path!);
        isResumeUploaded = true;
      });
      await convertPdfToText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildUploadResumeButton(),
          const SizedBox(height: 20),
          _buildRecommendationButton(),
          if (isResumeUploaded) ...[
            const SizedBox(height: 16),
            _buildAdvancedOptions(),
          ],
          _buildProfileHeadlineButton(),
          if (_showTextBox) ...[
            _buildRecommendationTextField(),
            _buildProfileHeadlineTextField(),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadResumeButton() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.5, // Set the desired width factor
        child: ElevatedButton.icon(
          onPressed: () {
            uploadResume();
          },
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Upload Resume'),
        ),
      ),
    );
  }

  Widget _buildRecommendationButton() {
    return ElevatedButton(
      onPressed: _isGeneratingRecommendation ||
          resumeText == null ||
          resumeText!.isEmpty
          ? null
          : () {
        _generateRecommendation();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isGeneratingRecommendation
              ? CircularProgressIndicator()
              : Icon(Icons.rate_review),
          SizedBox(width: 8),
          Text('Write a Recommendation'),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      children: [
        const Text(
          'Advanced Options',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        // DropdownButton<String>(
        //   value: _selectedRecommendationOption,
        //   onChanged: (value) {
        //     setState(() {
        //       _selectedRecommendationOption = value!;
        //     });
        //   },
        //   items: const [
        //     DropdownMenuItem(
        //       value: "Generic",
        //       child: Text('Generic'),
        //     ),
        //     DropdownMenuItem(
        //       value: "Recommend the professional as my subordinate",
        //       child: Text('Recommend the professional as my subordinate'),
        //     ),
        //     DropdownMenuItem(
        //       value: "Recommend the professional as my manager",
        //       child: Text('Recommend the professional as my manager'),
        //     ),
        //     DropdownMenuItem(
        //       value: "We worked in two different groups",
        //       child: Text('We worked in two different groups'),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),
        Row(
          children: [
            const Text('Number of Words: '),
            Text(_numberOfWords.toString()),
          ],
        ),
        Slider(
          value: _numberOfWords.toDouble(),
          min: 100,
          max: 1000,
          divisions: 9,
          onChanged: (value) {
            setState(() {
              _numberOfWords = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeadlineButton() {
    return ElevatedButton(
      onPressed: resumeText == null || resumeText!.isEmpty
          ? null
          : () {
        _generateProfileHeadline();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isGeneratingProfileHeadline
              ? CircularProgressIndicator()
              : Icon(Icons.edit),
          SizedBox(width: 8),
          Text('Write a Headline'),
        ],
      ),
    );
  }

  Widget _buildRecommendationTextField() {
    return Form(
      key: _formKeyRecommendation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: const Text(
                'Recommendation',
                style: TextStyle(fontSize: 18),
              ),
              onExpansionChanged: (value) {
                setState(() {
                  _isRecommendationExpanded = value;
                });
              },
              children: [
                SingleChildScrollView(
                  child: TextFormField(
                    controller: _recommendationController,
                    readOnly: true,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    copyToClipboard(_recommendation);
                  },
                ),
              ],
            ),
            if (!_isRecommendationExpanded) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeadlineTextField() {
    return Form(
      key: _formKeyProfileHeadline,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: const Text(
                'Profile Headline',
                style: TextStyle(fontSize: 18),
              ),
              onExpansionChanged: (value) {
                setState(() {
                  _isProfileHeadlineExpanded = value;
                });
              },
              children: [
                SingleChildScrollView(
                  child: TextFormField(
                    controller: _profileHeadlineController,
                    readOnly: true,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    copyToClipboard(_profileHeadline);
                  },
                ),
              ],
            ),
            if (!_isProfileHeadlineExpanded) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
