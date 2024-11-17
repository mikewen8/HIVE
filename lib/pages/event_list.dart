import 'package:flutter/material.dart';
import 'package:hive/pages/home_screen.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

class EventDisplayPage extends StatefulWidget {
  final String query;

  const EventDisplayPage(
      {super.key, required this.query}); // Accept the query as a parameter

  @override
  _EventDisplayPageState createState() => _EventDisplayPageState();
}

class _EventDisplayPageState extends State<EventDisplayPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      const url =
          'http://127.0.0.1:5000/send'; // Replace with your Flask API URL
      final hail = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "query": widget.query
        }), // Use the query passed from the previous page
      );
      print(hail);
      if (hail.statusCode == 200) {
        final stuff = json.decode(hail.body);

        for (final e in stuff["events"]) {
          //print(e);
        }

        final events = stuff["events"]
            .map((e) => {
                  'name': e['Event'],
                  'description': e['description'],
                  'type': e['type'],
                  'venue': e['venue']
                })
            .toList();

        //print(events);

        setState(() {
          _events = events;
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load events. Status code: ${hail.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Events", style: TextStyle(fontSize: 24)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _events.isEmpty
                  ? const Center(child: Text("No events available"))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(
                              event['name'] ?? 'Unnamed Event',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Name: ${event['name'] ?? 'Unnamed Event'}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'Type: ${event['type']?.toString() ?? 'Unknown'}'),
                                Text(
                                    'Date: ${event['date']?.toString() ?? 'TBD'}'),
                                Text(
                                    'Venue: ${event['venue']?.toString() ?? 'Unknown'}'),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
