import 'package:virtual_assistant/screens/travel_itinerary_screen.dart';
import 'package:virtual_assistant/screens/usage_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'career_screen.dart';
import 'update_api_key_screen.dart';
import 'review_generation_screen.dart';

typedef Supplier<T> = T Function();


class MainScreen extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  MainScreen({required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    apiKeySupplier() => sharedPreferences.getString('apiKey') ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildOption(
            context,
            Icons.chat,
            'Converse',
            ChatScreen(apiKey: apiKeySupplier()),
          ),
          _buildOption(
            context,
            Icons.rate_review,
            'Review Generation',
            ReviewGenerationScreen(apiKey: apiKeySupplier()),
          ),
          _buildOption(
            context,
            Icons.holiday_village,
            'Holiday Planner',
            TravelItineraryScreen(apiKey: apiKeySupplier()),
          ),
          _buildOption(
            context,
            Icons.person,
            'Career',
            CareerScreen(apiKey: apiKeySupplier()), // Connect the LinkedInScreen widget here
          ),
          _buildOption(
            context,
            Icons.data_usage,
            'API Usage',
            UsageScreen(apiKey: apiKeySupplier()),
          ),
          _buildOption(
            context,
            Icons.settings,
            'Update API Key',
            UpdateApiKeyScreen(sharedPreferences: sharedPreferences),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context,
      IconData icon,
      String label,
      Widget screen,
      ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).primaryColor,),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

