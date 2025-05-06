import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../avatar_chat_page/chat_message.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.88.100:5000/api/chat';
  final String userId;
  final String avatarId;

  ApiService({required this.userId, required this.avatarId});

  Future<String> getAvatarResponse(
    String message,
    List<ChatMessage> history,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'userId': userId,
              'avatarId': avatarId,
              'message': message,
              'history': history.map((m) => m.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 10)); // Added timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return data['response'];
        }
        return "Hmm, I got a bit confused. Could you ask me differently?";
      } else if (response.statusCode >= 500) {
        return "Our servers are feeling a bit tired. Please try again soon!";
      } else {
        return "I couldn't understand that request. Could you rephrase?";
      }
    } on http.ClientException catch (e) {
      // Handle specific HTTP client errors
      return "I'm having connection issues. Please check your network.";
    } on TimeoutException catch (_) {
      return "I'm thinking hard but it's taking longer than usual...";
    } catch (e) {
      // More specific error handling
      return "Oops! Something unexpected happened. Let's try that again.";
    }
  }

  Future<List<ChatMessage>> getChatHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/history?userId=$userId&avatarId=$avatarId'))
          .timeout(const Duration(seconds: 5)); // Added timeout

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // ignore: unnecessary_type_check
        if (data is List) {
          return data.map((json) => ChatMessage.fromJson(json)).toList();
        }
        return [];
      }
      return []; // Return empty list instead of throwing for history
    } on TimeoutException catch (_) {
      return [];
    } catch (e) {
      return [];
    }
  }
}
