import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventCreator extends StatefulWidget {
  const EventCreator({super.key});

  @override
  State<EventCreator> createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator> {
  final TextEditingController _controller = TextEditingController();
  String eventDescription = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleAddEvent(String accessToken) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:5000/add_event'); // Backend route
    final eventData = {
      'event_id': 'event123', // Replace with your event ID logic
      'name': eventDescription,
      'type': 'Music', // Example event type
      'genre': 'Pop', // Example genre
      'venue': 'Theater A',
      'address': '123 Main St, City',
      'date': '2024-12-01',
      'time': '18:00',
      'location': '123.456, -78.901', // Example location
      'link': 'http://example.com/event', // Example link
      'description': 'This is a sample event description.'
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        // Navigate to EventDisplayPage after adding the event
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDisplayPage(query: eventDescription),
          ),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Replace with the actual access token passed to this widget or obtained globally
    const accessToken = 'your_access_token';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Search things to do with the event search bar below",
          style: TextStyle(fontFamily: "comic-sans", fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter event description',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: SizedBox(
          width: 200,
          height: 70,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    eventDescription = _controller.text;
                    await handleAddEvent(accessToken);
                  },
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    "ADD EVENT",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}