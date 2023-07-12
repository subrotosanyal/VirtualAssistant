import 'package:virtual_assistant/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AssistantApp());
}

class AssistantApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistant',
      home: MainScreen(),
    );
  }
}
