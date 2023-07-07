import 'package:virtual_assistant/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  runApp(AssistantApp(sharedPreferences: sharedPreferences));
}

class AssistantApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  AssistantApp({required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistant',
      home: MainScreen(sharedPreferences: sharedPreferences),
    );
  }
}
