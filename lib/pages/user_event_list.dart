import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventListPage extends StatefulWidget {
  final String apiBase;
  final String accessToken;

  const EventListPage({
    super.key,
    required this.apiBase,
    required this.accessToken,
  });

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<dynamic> _events = [];
  String message = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${widget.apiBase}/get_user_events');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _events = responseData['events'];
          message = '';
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          message = responseData['error'] ?? 'Failed to fetch events';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Failed to connect to the server';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final url = Uri.parse('${widget.apiBase}/delete_event');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'event_id': eventId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          message = responseData['message'];
          _events.removeWhere((event) => event['event_id'] == eventId);
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          message = responseData['error'] ?? 'Failed to delete event';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Failed to connect to the server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _events.isEmpty
                ? Center(
                    child: Text(
                      message.isNotEmpty ? message : 'No events to display',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: message.contains('Failed') ||
                                      message.contains('error')
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: ListTile(
                                title: Text(
                                  event['name'] ?? 'Unnamed Event',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date: ${event['date'] ?? 'TBD'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Venue: ${event['venue'] ?? 'Unknown'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await _deleteEvent(event['event_id']);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}