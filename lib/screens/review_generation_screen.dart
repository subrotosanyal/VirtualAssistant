import 'package:flutter/material.dart';
import 'package:virtual_assistant/util/chat_util.dart';
import 'package:share/share.dart';


class ReviewGenerationScreen extends StatefulWidget {
  final String apiKey;

  ReviewGenerationScreen({required this.apiKey});

  @override
  _ReviewGenerationScreenState createState() => _ReviewGenerationScreenState();
}

class _ReviewGenerationScreenState extends State<ReviewGenerationScreen> {
  final TextEditingController _sentimentController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _serviceNameController = TextEditingController();
  String _review = '';
  bool _isGeneratingReview = false;

  @override
  void dispose() {
    _sentimentController.dispose();
    _serviceTypeController.dispose();
    _serviceNameController.dispose();
    super.dispose();
  }

  void _generateReview() async {
    setState(() {
      _isGeneratingReview = true;
      _review = '';
    });
    final sentiment = _sentimentController.text;
    final serviceType = _serviceTypeController.text;
    final serviceName = _serviceNameController.text;

    final message = "Generate review for $serviceType: $serviceName with sentiment $sentiment";
    final response = await ChatUtility.sendMessage(message, widget.apiKey);

    setState(() {
      _isGeneratingReview = false;
      _review = response.map((choice) => choice.toString()).join('\n');
    });
  }

  void _shareReview() {
    Share.share(_review);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Review'),
      ),
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _sentimentController,
                decoration: const InputDecoration(
                  labelText: 'Sentiment (happy, unhappy, positive, negative, disappointed)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Service Type (hotels, restaurants, public toilets, airports)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _serviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generateReview,
                child: _isGeneratingReview
                    ? CircularProgressIndicator()
                    : const Text('Generate Review'),
              ),
              const SizedBox(height: 16),
              if (_review.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Review:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_review),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _shareReview,
                      child: const Text('Share Review'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
