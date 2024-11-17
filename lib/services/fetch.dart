import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchEvents() async {
  try {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/events'));
    if (response.statusCode == 200) {
      final events = jsonDecode(response.body)['events'];
      return events.map((e) => e['name']).join(", ");
    } else {
      throw Exception("Failed to load events");
    }
  } catch (e) {
    return "Error fetching events: $e";
  }
}

Future<List<Map<String, dynamic>>> fetchEventList() async {
  try {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/events'));

    if (response.statusCode == 200) {
      final List events = jsonDecode(response.body)['events'];
      return events
          .map((e) => {
                'name': e['Event'],
                'description': e['description'],
                'id': e['event_id']
              })
          .toList();
    } else {
      throw Exception("Failed to load events");
    }
  } catch (e) {
    throw Exception("Error fetching events: $e");
  }
}

Future<Map<String, dynamic>> fetchEventDetails(String eventId) async {
  final events = await fetchEventList();
  return events.firstWhere((event) => event['id'] == eventId, orElse: () => {});
}
