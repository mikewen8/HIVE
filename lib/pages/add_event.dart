import 'package:flutter/material.dart';
import 'package:hive/services/event_logic.dart'; // Adjust the path based on your folder structure

class EventCreator extends StatefulWidget {
  const EventCreator({super.key});

  @override
  State<EventCreator> createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator> {
  TextEditingController _controller =
      TextEditingController(); // Declare controller
  String eventDescription = ""; // Variable to hold the event description

  @override
  void dispose() {
    _controller
        .dispose(); // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void handleAddEvent() async {
    eventDescription = _controller.text;
    bool isSuccess = await EventService.addEvent(
        eventDescription); // Call the addEvent method

    if (isSuccess) {
      // Show a success message or navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added successfully!")),
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add event")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _controller, // Use the controller here
              decoration: const InputDecoration(
                labelText: 'Enter event description',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // Center the button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 40), // Adjust this value to move the button higher
        child: Container(
          width: 200, // Set a custom width for the button
          height: 70, // Set a custom height for the button
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
            ),
            onPressed:
                handleAddEvent, // Use the handleAddEvent method when button is pressed
            child: const Text(
              "ADD EVENT",
              style: TextStyle(
                fontSize: 18, // Larger text
                fontWeight: FontWeight.bold, // Bold text
              ),
            ),
          ),
        ),
      ),
    );
  }
}
