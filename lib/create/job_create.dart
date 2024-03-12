import 'package:flutter/material.dart';
import 'package:culinect/auth/models/app_user.dart';
import 'package:culinect/models/jobs_model/job.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

// Conditional imports
import 'package:culinect/core/handlers/Company_profile/company_upload_image_io.dart'
if (dart.library.io) 'package:culinect/core/handlers/Company_profile/company_upload_image_io.dart';
import 'package:culinect/core/handlers/Company_profile/company_upload_image_html.dart'
if (dart.library.html) 'package:culinect/core/handlers/Company_profile/company_upload_image_html.dart';
import '../imports.dart';
import '../core/handlers/Company_profile/company_upload_image.dart';

final CompanyImageUploader imageUploader =
kIsWeb ? CompanyImageUploaderHtml() : CompanyImageUploaderIo();

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  _CreateJobScreenState createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  int _currentStep = 0;
  final int _upperBound = 3; // Total number of steps minus 1
  Uint8List? _imageBytes;
  late String? imagePath;
  late Job _job;
  final _applicationDeadlineController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  Future<List<String>> _getCompanySuggestions(String query) async {
    final places = FlutterGooglePlacesSdk(GOOGLE_PLACES_API_KEY);
    final response = await places.findAutocompletePredictions(
      query,
      placeTypesFilter: [PlaceTypeFilter.ESTABLISHMENT],
    );

    List<AutocompletePrediction> predictions = response.predictions;
    if (predictions.isNotEmpty) {
      List<String> companySuggestions = predictions.map((prediction) {
        String mainText = prediction.primaryText;
        return mainText;
      }).toList();

      return companySuggestions;
    } else {
      if (kDebugMode) {
        print('No autocomplete predictions found');
      }
      return [];
    }
  }

  Future<List<String>> _getLocationSuggestions(String query) async {
    final places = FlutterGooglePlacesSdk(GOOGLE_PLACES_API_KEY);
    final response = await places.findAutocompletePredictions(
      query,
      placeTypesFilter: [PlaceTypeFilter.REGIONS],
    );

    List<AutocompletePrediction> predictions = response.predictions;
    if (predictions.isNotEmpty) {
      List<String> formattedSuggestions = predictions.map((prediction) {
        String mainText = prediction.primaryText;
        String secondaryText = prediction.secondaryText;
        String cityStateCountry = '$mainText, $secondaryText';
        return cityStateCountry;
      }).toList();

      return formattedSuggestions;
    } else {
      if (kDebugMode) {
        print('No autocomplete predictions found');
      }
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _job = Job(
      jobId: '',
      authorBasicInfo: UserBasicInfo(
        uid: '',
        fullName: '',
        email: '',
        phoneNumber: '',
        profilePicture: '',
        profileLink: '',
        role: '',
      ),
      title: '',
      description: '',
      requirements: '',
      company: Company(companyId: '', companyName: '', companyLogoUrl: ''),
      location: '',
      salary: 0,
      postedDate: DateTime.now(),
      applicationMethod: '',
      email: '',
      careerPageUrl: '',
      jobType: '',
      applicationDeadline: DateTime.now(),
      skillsRequired: '',
      applicantsCount: 0,
      remoteWorkOption: false,
    );
    _applicationDeadlineController.text = _job.applicationDeadline.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Job'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            IconStepper(
              icons: const [
                Icon(Icons.work),
                Icon(Icons.business),
                Icon(Icons.info_outline_rounded),
                Icon(Icons.preview_sharp),
              ],
              activeStep: _currentStep,
              activeStepColor: Colors.teal,
              enableStepTapping: false,
              onStepReached: (index) {
                if (index > _currentStep &&
                    !_formKey.currentState!.validate()) {
                  return; // Do not allow advancing if validation fails
                }
                setState(() {
                  _currentStep = index;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(_currentStep),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentStep != 0 ? _previousButton() : Container(),
                _currentStep != _upperBound ? _nextButton() : _submitButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildJobDetailsForm();
      case 1:
        return _buildCompanyDetailsForm();
      case 2:
        return _buildAdditionalDetailsForm();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildJobDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Details',
            style: Theme.of(context).textTheme.headline5!.copyWith(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Job Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter job title';
              }
              return null;
            },
            onChanged: (value) => setState(() => _job.title = value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Job Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter job description';
              }
              return null;
            },
            onChanged: (value) => setState(() => _job.description = value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Job Requirements',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter job requirements';
              }
              return null;
            },
            onChanged: (value) => setState(() => _job.requirements = value),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Details',
            style: Theme.of(context).textTheme.headline5!.copyWith(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Upload Company Logo',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                imagePath = image.path;
                _imageBytes = await image.readAsBytes();
                final imageUrl = await imageUploader.uploadImageToFirebase(
                  image.path,
                );
                setState(() {
                  _job.company.companyLogoUrl = imageUrl;
                });
              }
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : null,
              child: _imageBytes == null
                  ? const Icon(Icons.camera_alt, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TypeAheadFormField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(),
              ),
            ),
            suggestionsCallback: _getCompanySuggestions,
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              _companyNameController.text = suggestion;
              setState(() {
                _job.company.companyName = suggestion;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter company name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TypeAheadFormField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Company Location',
                border: OutlineInputBorder(),
              ),
            ),
            suggestionsCallback: _getLocationSuggestions,
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              _locationController.text = suggestion;
              setState(() {
                _job.location = suggestion;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter company location';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Details',
            style: Theme.of(context).textTheme.headline5!.copyWith(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Application Method',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter application method';
              }
              return null;
            },
            onChanged: (value) => setState(() => _job.applicationMethod = value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Contact Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact email';
              }
              return null;
            },
            onChanged: (value) => setState(() => _job.email = value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Career Page URL',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _job.careerPageUrl = value),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Submit',
          style: Theme.of(context).textTheme.headline5!.copyWith(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: _imageBytes != null
              ? CircleAvatar(
            backgroundImage: MemoryImage(_imageBytes!),
          )
              : null,
          title: Text('Company: ${_job.company.companyName}'),
          subtitle: Text('Location: ${_job.location}'),
        ),
        const SizedBox(height: 20),
        Text(
          'Job Title: ${_job.title}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const SizedBox(height: 10),
        Text(
          'Description: ${_job.description}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const SizedBox(height: 10),
        Text(
          'Requirements: ${_job.requirements}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const SizedBox(height: 10),
        Text(
          'Application Method: ${_job.applicationMethod}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const SizedBox(height: 10),
        Text(
          'Email: ${_job.email}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const SizedBox(height: 10),
        Text(
          'Career Page: ${_job.careerPageUrl}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }

  Widget _nextButton() {
    return ElevatedButton(
      onPressed: () {
        if (_currentStep < _upperBound) {
          if (_currentStep == 1 && _imageBytes == null) {
            // Check if image is selected in the second step
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please upload company logo')),
            );
            return;
          }
          if (!_formKey.currentState!.validate()) {
            // Validate the form before proceeding to the next step
            return;
          }
          setState(() {
            _currentStep++;
          });
        }
      },
      child: const Text('Next'),
    );
  }

  Widget _previousButton() {
    return ElevatedButton(
      onPressed: () {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
        }
      },
      child: const Text('Previous'),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            // Upload image to Firebase Storage if image exists
            if (_imageBytes != null) {
              String imageUrl = await imageUploader.uploadImageToFirebase(imagePath!);
              _job.company.companyLogoUrl = imageUrl;
            }
            // Save job data to Firestore
            await saveJobDataToFirestore(_job);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job posted successfully')),
            );
          } catch (e) {
            if (kDebugMode) {
              print("Error during job submission: $e");
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to post job')),
            );
          }
        }
      },
      child: const Text('Submit'),
    );
  }

  Future<void> saveJobDataToFirestore(Job job) async {
    try {
      await FirebaseFirestore.instance.collection('jobs').add(job.toMap());
      // Optionally, you can handle success here
    } catch (e) {
      if (kDebugMode) {
        print("Error saving job data to Firestore: $e");
      }
      throw Exception("Error saving job data: $e");
    }
  }

  @override
  void dispose() {
    _applicationDeadlineController.dispose();
    _locationController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }
}
