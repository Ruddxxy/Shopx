import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String apiKey;

  ChatService({required this.apiKey});

  Future<String> getChatResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful shopping assistant for ShopX.'
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      return 'Sorry, I encountered an error. Please try again.';
    }
  }
} 