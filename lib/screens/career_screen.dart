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
  bool _isGeneratingCoverLetter = false;
  String _coverLetter = '';
  bool _isResumeUploaded = false;
  bool _showRecommendationTextBox = false;
  bool _showProfileHeadlineTextBox = false;
  bool _showCoverLetterTextBox = false;
  int _numberOfWords = 350;
  int _numberOfWordsCoverLetter = 500;
  String _roleDescription = '';
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _recommendationController =
      TextEditingController();
  final TextEditingController _profileHeadlineController =
      TextEditingController();

  final GlobalKey<FormState> _formKeyProfileHeadline = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyRecommendation = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyCoverLetter = GlobalKey<FormState>();

  @override
  void dispose() {
    _recommendationController.dispose();
    _profileHeadlineController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

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
          UploadResumeButton(uploadResume: uploadResume),
          const SizedBox(height: 20),
          RecommendationButton(
            isGeneratingRecommendation: _isGeneratingRecommendation,
            resumeText: _resumeText,
            generateRecommendation: _generateRecommendation,
          ),
          if (_isResumeUploaded) ...[
            const SizedBox(height: 16),
            AdvancedOptionsSlider(
              numberOfWords: _numberOfWords,
              updateNumberOfWords: (value) {
                setState(() {
                  _numberOfWords = value.toInt();
                });
              },
            ),
          ],
          ProfileHeadlineButton(
            resumeText: _resumeText,
            isGeneratingProfileHeadline: _isGeneratingProfileHeadline,
            generateProfileHeadline: _generateProfileHeadline,
          ),
          if (_isResumeUploaded) ...[
            const SizedBox(height: 16),
            CoverLetterAdvancedOptions(
              roleDescription: _roleDescription,
              numberOfWordsCoverLetter: _numberOfWordsCoverLetter,
              updateRoleDescription: (value) {
                setState(() {
                  _roleDescription = value;
                });
              },
              updateNumberOfWordsCoverLetter: (value) {
                setState(() {
                  _numberOfWordsCoverLetter = value.toInt();
                });
              },
            ),
          ],
          CoverLetterButton(
            isGeneratingCoverLetter: _isGeneratingCoverLetter,
            resumeText: _resumeText,
            generateCoverLetter: _generateCoverLetter,
          ),
          if (_showRecommendationTextBox) ...[
            RecommendationTextField(
              recommendation: _recommendation,
              controller: _recommendationController,
              formKeyProfileHeadline: _formKeyRecommendation,
            ),
          ],
          if (_showProfileHeadlineTextBox) ...[
            ProfileHeadlineTextField(
              profileHeadline: _profileHeadline,
              controller: _profileHeadlineController,
              formKeyProfileHeadline: _formKeyProfileHeadline,
            ),
          ],
          if (_showCoverLetterTextBox) ...[
            CoverLetterTextField(
                coverLetter: _coverLetter,
                controller: _coverLetterController,
                formKeyCoverLetter: _formKeyCoverLetter),
          ]
        ],
      ),
    );
  }
}

class UploadResumeButton extends StatelessWidget {
  final Function() uploadResume;

  const UploadResumeButton({required this.uploadResume});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.5, // Set the desired width factor
        child: ElevatedButton.icon(
          onPressed: uploadResume,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Upload Resume'),
        ),
      ),
    );
  }
}

class RecommendationButton extends StatelessWidget {
  final bool isGeneratingRecommendation;
  final String? resumeText;
  final Function() generateRecommendation;

  const RecommendationButton({
    required this.isGeneratingRecommendation,
    required this.resumeText,
    required this.generateRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isGeneratingRecommendation ||
              resumeText == null ||
              resumeText!.isEmpty
          ? null
          : generateRecommendation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGeneratingRecommendation
              ? const CircularProgressIndicator()
              : const Icon(Icons.rate_review),
          const SizedBox(width: 8),
          const Text('Write a Recommendation'),
          const Divider(),
        ],
      ),
    );
  }
}

class AdvancedOptionsSlider extends StatelessWidget {
  final int numberOfWords;
  final Function(double) updateNumberOfWords;

  const AdvancedOptionsSlider({
    required this.numberOfWords,
    required this.updateNumberOfWords,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(numberOfWords.toString()),
          ],
        ),
        Slider(
          value: numberOfWords.toDouble(),
          min: 100,
          max: 1000,
          divisions: 9,
          onChanged: updateNumberOfWords,
        ),
      ],
    );
  }
}

class ProfileHeadlineButton extends StatelessWidget {
  final String? resumeText;
  final bool isGeneratingProfileHeadline;
  final Function() generateProfileHeadline;

  const ProfileHeadlineButton({
    required this.resumeText,
    required this.isGeneratingProfileHeadline,
    required this.generateProfileHeadline,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: resumeText == null || resumeText!.isEmpty
          ? null
          : generateProfileHeadline,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGeneratingProfileHeadline
              ? const CircularProgressIndicator()
              : const Icon(Icons.edit),
          const SizedBox(width: 8),
          const Text('Write a Headline'),
          const Divider(),
        ],
      ),
    );
  }
}

class CoverLetterButton extends StatelessWidget {
  final bool isGeneratingCoverLetter;
  final String? resumeText;
  final Function() generateCoverLetter;

  const CoverLetterButton({
    required this.isGeneratingCoverLetter,
    required this.resumeText,
    required this.generateCoverLetter,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          isGeneratingCoverLetter || resumeText == null || resumeText!.isEmpty
              ? null
              : generateCoverLetter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGeneratingCoverLetter
              ? const CircularProgressIndicator()
              : const Icon(Icons.description),
          const SizedBox(width: 8),
          const Text('Write a Cover Letter'),
          const Divider(),
        ],
      ),
    );
  }
}

class CoverLetterAdvancedOptions extends StatelessWidget {
  final String roleDescription;
  final int numberOfWordsCoverLetter;
  final Function(String) updateRoleDescription;
  final Function(double) updateNumberOfWordsCoverLetter;

  const CoverLetterAdvancedOptions({
    required this.roleDescription,
    required this.numberOfWordsCoverLetter,
    required this.updateRoleDescription,
    required this.updateNumberOfWordsCoverLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'Advanced Options',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text('Role Description:'),
        TextFormField(
          initialValue: roleDescription,
          onChanged: updateRoleDescription,
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
            Text(numberOfWordsCoverLetter.toString()),
          ],
        ),
        Slider(
          value: numberOfWordsCoverLetter.toDouble(),
          min: 200,
          max: 1500,
          divisions: 13,
          onChanged: updateNumberOfWordsCoverLetter,
        ),
      ],
    );
  }
}

class RecommendationTextField extends StatelessWidget {
  final String recommendation;
  final TextEditingController controller;
  final GlobalKey<FormState> formKeyProfileHeadline;

  const RecommendationTextField(
      {required this.recommendation,
      required this.controller,
      required this.formKeyProfileHeadline});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKeyProfileHeadline,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CollapsibleTextWidget(
          header: 'Recommendation',
          text: recommendation,
          controller: controller,
        ),
      ),
    );
  }
}

class ProfileHeadlineTextField extends StatelessWidget {
  final String profileHeadline;
  final TextEditingController controller;
  final GlobalKey<FormState> formKeyProfileHeadline;

  const ProfileHeadlineTextField(
      {required this.profileHeadline,
      required this.controller,
      required this.formKeyProfileHeadline});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKeyProfileHeadline,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CollapsibleTextWidget(
          header: 'Profile Headline',
          text: profileHeadline,
          controller: controller,
        ),
      ),
    );
  }
}

class CoverLetterTextField extends StatelessWidget {
  final String coverLetter;
  final TextEditingController controller;
  final GlobalKey<FormState> formKeyCoverLetter;

  const CoverLetterTextField(
      {required this.coverLetter,
      required this.controller,
      required this.formKeyCoverLetter});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKeyCoverLetter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CollapsibleTextWidget(
          header: 'Cover Letter',
          text: coverLetter,
          controller: controller,
        ),
      ),
    );
  }
}
