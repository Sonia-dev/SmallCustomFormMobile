import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'core/app_decoration.dart';

class AirtableCreateScreen extends StatefulWidget {
  @override
  _AirtableCreateScreenState createState() => _AirtableCreateScreenState();
}

class _AirtableCreateScreenState extends State<AirtableCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _longTextController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _attachmentUrlController = TextEditingController();

  bool isLoading = false;
  bool isUploading = false;
  String errorMessage = '';
  File? _selectedImage;

  List<String> _multiSelectOptions = ['Java', 'Python', 'Flutter', 'React', 'Design', 'Testing'];
  List<String> _selectedMultiSelectOptions = [];

  String _selectedDropdownOption = 'HR';
  List<String> _dropdownOptions = ['HR', 'Engineering', 'Design', 'QA'];

  Future<void> createRecord(String imageUrl) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://api.airtable.com/v0/appBUGxMnsQXrWaoB/employee'),
      headers: {
        'Authorization': 'Bearer patpiEEEbvzq8LTGd.ea3a6e2ecf358577515b6b7fc3d9a52ea26e26ac09d5a22f30cb222038a22a69',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'typecast': true,
        'records': [
          {
            'fields': {
              'name': _nameController.text,
              'firstName': _firstNameController.text,
              'attachment': [
                {
                  'url': imageUrl,
                }
              ],
              'bio': _longTextController.text,
              'number': int.tryParse(_numberController.text),
              'skills': _selectedMultiSelectOptions,
              'department': _selectedDropdownOption,
            }
          }
        ]
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pop(context, true);  // Indicate success
    } else {
      setState(() {
        errorMessage = 'Failed to create record: ${response.reasonPhrase}';
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      final imageUrl = await uploadImageToImgur(_selectedImage!);
      if (imageUrl != null) {
        setState(() {
          _attachmentUrlController.text = imageUrl;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to upload image';
        });
      }
    }
  }

  Future<String?> uploadImageToImgur(File image) async {
    setState(() {
      isUploading = true;
    });

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {
        'Authorization': 'Client-ID 4599bafb090f73a',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image': base64Encode(await image.readAsBytes()),
      }),
    );

    setState(() {
      isUploading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data']['link'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('New Employee'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    TextField(
                      controller: _nameController,
                      decoration: AppDecoration.commonInputDecoration(
                          hintText: 'Name'
                      ),
                    ),
                    SizedBox(height: 20),

                    TextField(
                      controller: _firstNameController,
                      decoration: AppDecoration.commonInputDecoration(
                          hintText: 'First Name'
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _longTextController,
                      maxLines: 5,
                      decoration: AppDecoration.commonInputDecoration(
                          hintText: 'Bio'
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      decoration: AppDecoration.commonInputDecoration(
                          hintText: 'Number Field'
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedDropdownOption,
                      items: _dropdownOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDropdownOption = newValue!;
                        });
                      },
                      decoration: AppDecoration.commonInputDecoration(
                          hintText: 'Department'
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Skills'),
                        Wrap(
                          spacing: 10.0,
                          children: _multiSelectOptions.map((String option) {
                            return FilterChip(
                              label: Text(option),
                              selected: _selectedMultiSelectOptions.contains(option),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedMultiSelectOptions.add(option);
                                  } else {
                                    _selectedMultiSelectOptions.remove(option);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (_selectedImage != null) ...[
                      Image.file(_selectedImage!),
                      SizedBox(height: 20),
                    ],
                    ElevatedButton(
                      onPressed: pickImage,
                      child: Text('Pick Image'),
                    ),
                    SizedBox(height: 20),
                    isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          elevation: 0,
                          side: const BorderSide(width: 1, color: Colors.black12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                        ),
                        onPressed: () => createRecord(_attachmentUrlController.text),
                        child: Text('Add Profile', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    if (errorMessage.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(errorMessage, style: TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
            if (isUploading)
              Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
