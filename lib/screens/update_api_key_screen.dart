import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateApiKeyScreen extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  UpdateApiKeyScreen({required this.sharedPreferences});

  @override
  _UpdateApiKeyScreenState createState() => _UpdateApiKeyScreenState();
}

class _UpdateApiKeyScreenState extends State<UpdateApiKeyScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.sharedPreferences.getString('apiKey') ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _updateApiKey() {
    String newApiKey = _apiKeyController.text;
    widget.sharedPreferences.setString('apiKey', newApiKey);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('API Key updated successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update API Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter API Key',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your API Key',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateApiKey,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
