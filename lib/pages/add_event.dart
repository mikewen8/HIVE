import 'package:flutter/material.dart';

class EventCreator extends StatefulWidget {
  const EventCreator({super.key});

  @override
  State<EventCreator> createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Search things to do with the event search bar below",
            style: TextStyle(fontFamily: "comic-sans", fontSize: 30)),
      ),
    );
  }
}
