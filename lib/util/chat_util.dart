import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatUtility {
  static Future<List<String>> sendMessage(String message, String apiKey) async {
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

    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: body, encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      final choices = responseBody['choices'] as List<dynamic>;
      final List<String> chatChoices = choices
          .map((choice) => choice['message']['content'] as String)
          .toList();
      return chatChoices;
    } else {
      throw Exception('Failed to communicate with the Chat GPT API');
    }
  }
}
