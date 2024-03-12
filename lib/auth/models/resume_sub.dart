import 'package:cloud_firestore/cloud_firestore.dart';

class Resume {
  final String objective;
  final List<Experience> experience;
  final List<Education> education;
  final List<String> skills;
  final List<String> certifications;
  final List<String> languages;
  final List<String> specializations;
  final List<String> awards;
  final String resumeLink; // Added resumeLink for sharing the resume

  Resume({
    required this.objective,
    required this.experience,
    required this.education,
    required this.skills,
    required this.certifications,
    required this.languages,
    required this.specializations,
    required this.awards,
    required this.resumeLink,
  });

  factory Resume.fromMap(Map<String, dynamic> data) {
    var expList = data['experience'] as List;
    List<Experience> expTempList = expList.map((i) => Experience.fromMap(i)).toList();

    var eduList = data['education'] as List;
    List<Education> eduTempList = eduList.map((i) => Education.fromMap(i)).toList();

    return Resume(
      objective: data['objective'],
      experience: expTempList,
      education: eduTempList,
      skills: List<String>.from(data['skills'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      specializations: List<String>.from(data['specializations'] ?? []),
      awards: List<String>.from(data['awards'] ?? []),
      resumeLink: data['resumeLink'] ?? '', // Retrieve resumeLink
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'objective': objective,
      'experiences': experience.map((exp) => exp.toMap()).toList(),
      'educations': education.map((edu) => edu.toMap()).toList(),
      'skills': skills,
      'certifications': certifications,
      'languages': languages,
      'specializations': specializations,
      'awards': awards,
      'resumeLink': resumeLink, // Save resumeLink
    };
  }
}

class Experience {
  final String title;
  final String company;
  final DateTime startDate;
  final DateTime endDate;
  final String description;

  Experience({
    required this.title,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory Experience.fromMap(Map<String, dynamic> data) {
    return Experience(
      title: data['title'],
      company: data['company'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'description': description,
    };
  }
}

class Education {
  final String school;
  final String degree;
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime endDate;

  Education({
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
  });

  factory Education.fromMap(Map<String, dynamic> data) {
    return Education(
      school: data['school'],
      degree: data['degree'],
      fieldOfStudy: data['fieldOfStudy'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}