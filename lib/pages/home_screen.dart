import 'package:flutter/material.dart';
import 'package:hive/services/fetch.dart'; // Adjust the path based on your folder structure

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchEventList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: SizedBox(
                    width: 200, // Smaller width for the button
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the button horizontally
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Define what happens when the button is pressed
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(event['name']),
                                content:
                                    Text('Event ID: ${event['description']}'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(1000,
                                60), // Set a smaller width and larger height for the button
                          ),
                          child: Text(
                            '${event['name']} (ID: ${event['id']})',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              // Handle the icon press
                              // have a delete option here to remove from the database
                              print('More options for event ${event['id']}');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No events available',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }
        },
      ),
    );
  }
}
