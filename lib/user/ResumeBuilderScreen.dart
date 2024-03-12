import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/resume_sub.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:culinect/models/resume_model/education.dart';
//import 'package:culinect/models/resume_model/experience.dart';
import 'package:flutter/material.dart';

class ResumeBuilderScreen extends StatefulWidget {
  @override
  _ResumeBuilderScreenState createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _objectiveController = TextEditingController();
  final _skillsController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _specializationsController = TextEditingController();
  final _awardsController = TextEditingController();
  final _resumeLinkController = TextEditingController();
  final List<Experience> _experiences = [];
  final List<Education> _educations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Resume'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_objectiveController, 'Objective',
                  'Write your career objective'),
              _buildTextField(_skillsController, 'Skills',
                  'Enter your skills (comma-separated)'),
              _buildTextField(_certificationsController, 'Certifications',
                  'Enter your certifications (comma-separated)'),
              _buildTextField(_languagesController, 'Languages',
                  'Enter languages you speak (comma-separated)'),
              _buildTextField(_specializationsController, 'Specializations',
                  'Enter your specializations (comma-separated)'),
              _buildTextField(_awardsController, 'Awards',
                  'Enter your awards (comma-separated)'),
              _buildTextField(_resumeLinkController, 'Resume Link',
                  'Enter a link to your online resume'),

              // Add buttons for adding experiences and education
              ElevatedButton(
                onPressed: _addExperience,
                child: const Text('Add Experience'),
              ),
              ElevatedButton(
                onPressed: _addEducation,
                child: const Text('Add Education'),
              ),

              // Display added experiences
              const SizedBox(height: 10),
              Text(
                'Experiences',
                style: Theme.of(context).textTheme.headline6,
              ),
              ..._experiences.map((exp) => ListTile(
                    title: Text(exp.title),
                    subtitle: Text(
                        '${exp.company}, ${exp.startDate} - ${exp.endDate}'),
                  )),

              // Display added educations
              const SizedBox(height: 10),
              Text(
                'Education',
                style: Theme.of(context).textTheme.headline6,
              ),
              ..._educations.map((edu) => ListTile(
                    title: Text('${edu.school} - ${edu.degree}'),
                    subtitle: Text(
                        '${edu.fieldOfStudy}, ${edu.startDate} - ${edu.endDate}'),
                  )),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveResume,
                  child: const Text('Save Resume'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _addExperience() async {
    final title = await _showInputDialog('Experience Title');
    final company = await _showInputDialog('Company');
    final startDate = await _showDatePicker('Start Date');
    final endDate = await _showDatePicker('End Date');
    final description = await _showInputDialog('Description');

    if (title != null &&
        company != null &&
        startDate != null &&
        endDate != null &&
        description != null) {
      setState(() {
        _experiences.add(Experience(
          title: title,
          company: company,
          startDate: startDate,
          endDate: endDate,
          description: description,
        ));
      });
    }
  }

  void _addEducation() async {
    final school = await _showInputDialog('School');
    final degree = await _showInputDialog('Degree');
    final fieldOfStudy = await _showInputDialog('Field of Study');
    final startDate = await _showDatePicker('Start Date');
    final endDate = await _showDatePicker('End Date');

    if (school != null &&
        degree != null &&
        fieldOfStudy != null &&
        startDate != null &&
        endDate != null) {
      setState(() {
        _educations.add(Education(
          school: school,
          degree: degree,
          fieldOfStudy: fieldOfStudy,
          startDate: startDate,
          endDate: endDate,
        ));
      });
    }
  }

  Future<String?> _showInputDialog(String title) async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                result = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<DateTime?> _showDatePicker(String title) async {
    DateTime? selectedDate;
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        selectedDate = date;
      }
    });
    return selectedDate;
  }

  void _saveResume() async {
    final objective = _objectiveController.text;
    final skills =
        _skillsController.text.split(',').map((s) => s.trim()).toList();
    final certifications =
        _certificationsController.text.split(',').map((c) => c.trim()).toList();
    final languages =
        _languagesController.text.split(',').map((l) => l.trim()).toList();
    final specializations = _specializationsController.text
        .split(',')
        .map((s) => s.trim())
        .toList();
    final awards =
        _awardsController.text.split(',').map((a) => a.trim()).toList();
    final resumeLink = _resumeLinkController.text;

    if (objective.isEmpty || resumeLink.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objective and Resume Link are required')),
      );
      return;
    }

    final resume = Resume(
      objective: objective,
      experience: _experiences,
      education: _educations,
      skills: skills,
      certifications: certifications,
      languages: languages,
      specializations: specializations,
      awards: awards,
      resumeLink: resumeLink,
    );

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final resumeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('resume')
        .doc('currentResume');

    await resumeRef.set(resume.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resume saved successfully')),
    );

    Navigator.pop(context);
  }
}
