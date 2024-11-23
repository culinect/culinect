import 'package:flutter/material.dart';

class AdsWidget extends StatelessWidget {
  const AdsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text(
              'Sponsored',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Number of ads to display
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.ad_units, color: Colors.blue),
                  title: Text('Ad Title $index'),
                  subtitle: Text('Ad description goes here.'),
                  onTap: () {
                    // Handle ad click logic
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
