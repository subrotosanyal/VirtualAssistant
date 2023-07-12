import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import '../component/collapsable_text_widget.dart';
import '../util/chat_util.dart';

class CareerScreen extends StatefulWidget {
  final String apiKey;

  const CareerScreen({required this.apiKey});

  @override
  _CareerScreenState createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  File? resumeFile;
  String? _resumeText;
  bool _isGeneratingRecommendation = false;
  String _recommendation = '';
  bool _isGeneratingProfileHeadline = false;
  String _profileHeadline = '';
  bool _isResumeUploaded = false;
  bool _showRecommendationTextBox = false;
  bool _showProfileHeadlineTextBox = false;
  int _numberOfWords = 350;
  bool _isGeneratingCoverLetter = false;
  String _coverLetter = '';
  bool _showCoverLetterTextBox = false;
  String _roleDescription = '';
  int _numberOfWordsCoverLetter = 500;
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _recommendationController =
      TextEditingController();
  final TextEditingController _profileHeadlineController =
      TextEditingController();

  @override
  void dispose() {
    _recommendationController.dispose();
    _profileHeadlineController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKeyProfileHeadline = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyRecommendation = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyCoverLetter = GlobalKey<FormState>();

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _generateRecommendation() async {
    setState(() {
      _isGeneratingRecommendation = true;
      updateRecommendation('');
    });
    final message =
        "Generate a recommendation for a professional in $_numberOfWords words in paragraph format (not bullet points) using the text which is extracted from their CV is: $_resumeText";
    try {
      final response = await ChatUtility.sendMessage(message, widget.apiKey);
      setState(() {
        updateRecommendation(
            response.map((choice) => choice.toString()).join('\n'));
      });
    } catch (exp) {
      updateRecommendation(exp.toString());
    } finally {
      setState(() {
        _isGeneratingRecommendation = false;
        _showRecommendationTextBox = true;
        _showProfileHeadlineTextBox = false;
        _showCoverLetterTextBox = false;
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
        "Generate a profile headline for a professional using the text which is extracted from their CV is: $_resumeText";
    try {
      final response = await ChatUtility.sendMessage(message, widget.apiKey);
      updateProfileHeadline(
          response.map((choice) => choice.toString()).join('\n'));
    } catch (exp) {
      updateProfileHeadline(exp.toString());
    } finally {
      setState(() {
        _isGeneratingProfileHeadline = false;
        _showProfileHeadlineTextBox = true;
        _showRecommendationTextBox = false;
        _showCoverLetterTextBox = false;
      });
    }
  }

  void updateProfileHeadline(String profileHeadline) {
    setState(() {
      _profileHeadline = profileHeadline;
      _profileHeadlineController.text = profileHeadline;
    });
  }

  void _generateCoverLetter() async {
    setState(() {
      _isGeneratingCoverLetter = true;
      updateCoverLetter('');
    });

    final message =
        "The CV for the person applying for the job is: \n$_resumeText \n\n\n Generate a cover letter for the candidate mentioned in CV in $_numberOfWordsCoverLetter words with the role description: \n$_roleDescription";
    try {
      final response = await ChatUtility.sendMessage(message, widget.apiKey);
      updateCoverLetter(response.map((choice) => choice.toString()).join('\n'));
    } catch (exp) {
      updateCoverLetter(exp.toString());
    } finally {
      setState(() {
        _isGeneratingCoverLetter = false;
        _showCoverLetterTextBox = true;
        _showProfileHeadlineTextBox = false;
        _showRecommendationTextBox = false;
      });
    }
  }

  void updateCoverLetter(String coverLetter) {
    setState(() {
      _coverLetter = coverLetter;
      _coverLetterController.text = coverLetter;
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
      _resumeText = text;
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
        _isResumeUploaded = true;
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
          if (_isResumeUploaded) ...[
            const SizedBox(height: 16),
            _buildAdvancedOptions(),
          ],
          _buildCoverLetterButton(),
          if (_isResumeUploaded) ...[
            const SizedBox(height: 16),
            _buildAdvancedOptionsForCoverLetter(),
          ],
          _buildProfileHeadlineButton(),
          if (_showRecommendationTextBox) ...[
            _buildRecommendationTextField(),
          ],
          if (_showProfileHeadlineTextBox) ...[
            _buildProfileHeadlineTextField(),
          ],
          if (_showCoverLetterTextBox) ...[
            _buildCoverLetterTextField(),
          ]
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
              _resumeText == null ||
              _resumeText!.isEmpty
          ? null
          : () {
              _generateRecommendation();
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isGeneratingRecommendation
              ? const CircularProgressIndicator()
              : const Icon(Icons.rate_review),
          const SizedBox(width: 8),
          const Text('Write a Recommendation'),
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
      onPressed: _resumeText == null || _resumeText!.isEmpty
          ? null
          : () {
              _generateProfileHeadline();
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isGeneratingProfileHeadline
              ? const CircularProgressIndicator()
              : const Icon(Icons.edit),
          const SizedBox(width: 8),
          const Text('Write a Headline'),
        ],
      ),
    );
  }

  Widget _buildCoverLetterButton() {
    return ElevatedButton(
      onPressed:
          _isGeneratingCoverLetter || _resumeText == null || _resumeText!.isEmpty
              ? null
              : () {
                  _generateCoverLetter();
                },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isGeneratingCoverLetter
              ? const CircularProgressIndicator()
              : const Icon(Icons.description),
          const SizedBox(width: 8),
          const Text('Write a Cover Letter'),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsForCoverLetter() {
    return Column(
      children: [
        // Existing code...

        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text(
            'Cover Letter Advanced Options',
            style: TextStyle(fontSize: 18),
          ),
          children: [
            const SizedBox(height: 8),
            const Text('Role Description:'),
            TextFormField(
              initialValue: _roleDescription,
              onChanged: (value) {
                setState(() {
                  _roleDescription = value;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a role description';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Number of Words: '),
                Text(_numberOfWordsCoverLetter.toString()),
              ],
            ),
            Slider(
              value: _numberOfWordsCoverLetter.toDouble(),
              min: 200,
              max: 1500,
              divisions: 13,
              onChanged: (value) {
                setState(() {
                  _numberOfWordsCoverLetter = value.toInt();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverLetterTextField() {
    return Form(
      key: _formKeyCoverLetter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CollapsibleTextWidget(
          header: 'Cover Letter',
          text: _coverLetter,
          controller: _coverLetterController,
        ),
      ),
    );
  }

  Widget _buildRecommendationTextField() {
    return Form(
      key: _formKeyRecommendation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CollapsibleTextWidget(
          header: 'Recommendation',
          text: _recommendation,
          controller: _recommendationController,
        ),
      ),
    );
  }

  Widget _buildProfileHeadlineTextField() {
    return Form(
      key: _formKeyProfileHeadline,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CollapsibleTextWidget(
          header: 'Profile Headline',
          text: _profileHeadline,
          controller: _profileHeadlineController,
        ),
      ),
    );
  }
}
