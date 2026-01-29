import 'package:flutter/material.dart';

class EventsBookedScreen extends StatelessWidget {
  const EventsBookedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Booked Events',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your tickets and reservations',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
