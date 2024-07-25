import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/resume_sub.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:culinect/models/resume_model/education.dart';
//import 'package:culinect/models/resume_model/experience.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ResumeViewScreen extends StatefulWidget {
  const ResumeViewScreen({super.key});

  @override
  _ResumeViewScreenState createState() => _ResumeViewScreenState();
}

class _ResumeViewScreenState extends State<ResumeViewScreen> {
  late Future<Resume> _resumeFuture;

  @override
  void initState() {
    super.initState();
    _resumeFuture = _fetchResume();
  }

  Future<Resume> _fetchResume() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final resumeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('resume')
        .doc('currentResume');

    final snapshot = await resumeRef.get();
    return Resume.fromMap(snapshot.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _generatePDF,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePDF,
          ),
        ],
      ),
      body: FutureBuilder<Resume>(
        future: _resumeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final resume = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(resume),
                const SizedBox(height: 20),
                _buildSectionTitle('Objective'),
                Text(resume.objective),
                const SizedBox(height: 20),
                _buildSectionTitle('Skills'),
                Text(resume.skills.join(', ')),
                const SizedBox(height: 20),
                _buildSectionTitle('Certifications'),
                Text(resume.certifications.join(', ')),
                const SizedBox(height: 20),
                _buildSectionTitle('Languages'),
                Text(resume.languages.join(', ')),
                const SizedBox(height: 20),
                _buildSectionTitle('Specializations'),
                Text(resume.specializations.join(', ')),
                const SizedBox(height: 20),
                _buildSectionTitle('Awards'),
                Text(resume.awards.join(', ')),
                const SizedBox(height: 20),
                _buildSectionTitle('Experience'),
                ...resume.experience.map((exp) => _buildExperience(exp)),
                const SizedBox(height: 20),
                _buildSectionTitle('Education'),
                ...resume.education.map((edu) => _buildEducation(edu)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Resume resume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resume',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Name: ${FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          'Email: ${FirebaseAuth.instance.currentUser!.email ?? 'Unknown'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          'Resume Link: ${resume.resumeLink}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildExperience(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${exp.title} at ${exp.company}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '${exp.startDate.toLocal().toString().split(' ')[0]} - ${exp.endDate.toLocal().toString().split(' ')[0]}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          exp.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEducation(Education edu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${edu.degree} in ${edu.fieldOfStudy} from ${edu.school}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '${edu.startDate.toLocal().toString().split(' ')[0]} - ${edu.endDate.toLocal().toString().split(' ')[0]}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final resume = await _fetchResume();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Resume',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Name: ${FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown'}',
                style: pw.TextStyle(
                  fontSize: 18,
                ),
              ),
              pw.Text(
                'Email: ${FirebaseAuth.instance.currentUser!.email ?? 'Unknown'}',
                style: pw.TextStyle(
                  fontSize: 18,
                ),
              ),
              pw.Text(
                'Resume Link: ${resume.resumeLink}',
                style: pw.TextStyle(
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildPDFSection('Objective', resume.objective, pdf),
              _buildPDFSection('Skills', resume.skills.join(', '), pdf),
              _buildPDFSection(
                  'Certifications', resume.certifications.join(', '), pdf),
              _buildPDFSection('Languages', resume.languages.join(', '), pdf),
              _buildPDFSection(
                  'Specializations', resume.specializations.join(', '), pdf),
              _buildPDFSection('Awards', resume.awards.join(', '), pdf),
              _buildPDFSection('Experience',
                  _buildPDFExperiences(resume.experience) as String, pdf),
              _buildPDFSection('Education',
                  _buildPDFEducations(resume.education) as String, pdf),
            ],
          );
        },
      ),
    );

    final outputFile = await _savePDFToFile(pdf);
    final xFile = XFile(outputFile.path); // Create XFile object
    Share.shareXFiles([xFile], text: 'Here is my resume!'); // Share XFile
  }

  Future<File> _savePDFToFile(pw.Document pdf) async {
    final outputFile =
        File('${(await getTemporaryDirectory()).path}/resume.pdf');
    await outputFile.writeAsBytes(await pdf.save());
    return outputFile;
  }

  void _sharePDF() async {
    await _generatePDF();
  }

  pw.Widget _buildPDFSection(String title, String content, pw.Document pdf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(content),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildPDFExperiences(List<Experience> experiences) {
    return pw.Column(
      children: experiences.map((exp) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${exp.title} at ${exp.company}'),
            pw.Text(
              '${exp.startDate.toLocal().toString().split(' ')[0]} - ${exp.endDate.toLocal().toString().split(' ')[0]}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(exp.description),
            pw.SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _buildPDFEducations(List<Education> educations) {
    return pw.Column(
      children: educations.map((edu) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${edu.degree} in ${edu.fieldOfStudy} from ${edu.school}'),
            pw.Text(
              '${edu.startDate.toLocal().toString().split(' ')[0]} - ${edu.endDate.toLocal().toString().split(' ')[0]}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
}
