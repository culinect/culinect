import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/models/jobs_model/job.dart';
import 'package:flutter/material.dart';

class JobsTab extends StatelessWidget {
  final String userId;

  const JobsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('author.userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading jobs'));
        }
        final jobs = snapshot.data!.docs
            .map((doc) =>
                Job.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return ListTile(
              title: Text(job.title),
              subtitle: Text(job.company.companyName),
            );
          },
        );
      },
    );
  }
}
