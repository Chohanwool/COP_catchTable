
import 'package:catch_table/models/registration.dart';
import 'package:flutter/material.dart';

class WaitingListScreen extends StatelessWidget {
  const WaitingListScreen({super.key, required this.registrationList});

  final List<Registration> registrationList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting List'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: registrationList.length,
        itemBuilder: (context, index) {
          final registration = registrationList[index];
          final waitingNumber = index + 1;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  '$waitingNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'Phone: ${registration.formattedPhoneNumber}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('Group Size: ${registration.groupSize}'),
              trailing: const Icon(Icons.person_outline),
            ),
          );
        },
      ),
    );
  }
}
