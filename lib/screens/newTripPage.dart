import 'package:flutter/material.dart';
import 'package:uber_drivers/models/tripDetails.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails tripDetails;
  NewTripPage({required this.tripDetails});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: const Center(
          child: Text("new trip page"),
        ),
      ),
    );
  }
}
