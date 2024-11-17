import 'package:flutter/material.dart';
import 'package:HIVE/pages/home_screen.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

class EventDisplayPage extends StatefulWidget {
  const EventDisplayPage({super.key});

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
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"query": "your_search_query_here"}),
      );
      print(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for (final e in data["events"]) {
          //print(e);
        }

        final events = data["events"]
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
            'Failed to load events. Status code: ${response.statusCode}');
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

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['name'] ?? 'Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${event['name'] ?? 'Unnamed Event'}'),
            Text('Type: ${event['type'] ?? 'Unknown'}'),
            Text('Genre: ${event['genre'] ?? 'N/A'}'),
            Text('Date: ${event['date'] ?? 'TBD'}'),
            Text('Time: ${event['time'] ?? 'TBD'}'),
            Text('Venue: ${event['venue'] ?? 'Unknown'}'),
            Text('Address: ${event['address'] ?? 'No address available'}'),
            Text('Location: ${event['location'] ?? 'No location data'}'),
            Text('Description: ${event['description'] ?? 'No description'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final url = event['link'];
                if (url != null && await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open the link')),
                  );
                }
              },
              child: const Text("View More"),
            ),
          ],
        ),
      ),
    );
  }
}
