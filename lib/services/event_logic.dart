// lib/service/event_add.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {
  static const String api =
      'http://127.0.0.1:5000/send'; // Replace with your API endpoint

  static Future<bool> addEvent(String query) async {
    try {
      final send = await http.post(
        Uri.parse(api),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': query, // Assuming your API accepts a 'description' key
        }),
      );

      if (send.statusCode == 200) {
        // Successfully added event
        return true;
      } else {
        // Handle error
        return false;
      }
    } catch (e) {
      print('Error adding event: $e');
      return false;
    }
  }
}
