import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatUtility {
  static Future<List<String>> sendMessage(String message, String apiKey) async {
    bool mockIt = true;
    const apiUrl = 'https://api.openai.com/v1/chat/completions';
    final headers = {
      'content-type': 'application/json; charset=utf-8',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': message, 'name': 'Me'}
      ]
    });
    if (!mockIt) {
      final response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: body, encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        final choices = responseBody['choices'] as List<dynamic>;
        final List<String> chatChoices = choices
            .map((choice) => choice['message']['content'] as String)
            .toList();
        return chatChoices;
      } else {
        var reasonForFailure = response.reasonPhrase;
        var responseCode = response.statusCode;
        throw Exception(
            'Failed to communicate with the server because \'$reasonForFailure\' and code \'$responseCode\'');
      }
    } else {
      return getRandomStrings(100, 100);
    }
  }
  static Future<List<String>> getRandomStrings(int count, int length) async {
    List<String> randomStrings = [];

    for (int i = 0; i < count; i++) {
      String randomString = generateRandomString(length);
      randomStrings.add(randomString);
    }

    return randomStrings;
  }

  static String generateRandomString(int length) {
    final random = Random();
    const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
