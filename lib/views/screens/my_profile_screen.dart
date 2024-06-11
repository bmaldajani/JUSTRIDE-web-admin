import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        final adminDoc =
            await FirebaseFirestore.instance.collection('admins').doc(userId).get();

        if (adminDoc.exists) {
          setState(() {
            _formData.username = adminDoc.get('username') ?? '';
            _formData.email = adminDoc.get('email') ?? '';
            _formData.profilePictureUrl = adminDoc.get('profilePictureUrl') ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          print("Admin document does not exist.");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Error fetching admin data: $e");
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print("User is not logged in.");
    }
  }

  Future<void> _saveAdminData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('admins').doc(userId).update({
          'username': _formData.username,
          'email': _formData.email,
          'profilePictureUrl': _formData.profilePictureUrl,
        });
        print("Admin data saved successfully.");
      } catch (e) {
        print("Error saving admin data: $e");
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePickerWeb.getImageAsFile();

    if (pickedFile != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final file = File(pickedFile?.relativePath ?? '');
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures').child('$userId.jpg');

      try {
        // Perform image upload
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);

        if (snapshot.state == TaskState.success) {
          final downloadUrl = await storageRef.getDownloadURL();
          print("Download URL: $downloadUrl");

          setState(() {
            _formData.profilePictureUrl = downloadUrl;
          });

          if (userId != null) {
            await FirebaseFirestore.instance.collection('admins').doc(userId).update({
              'profilePictureUrl': downloadUrl,
            });
            print("Admin data saved successfully.");
          }
        } else {
          print("Image upload failed.");
        }
      } catch (e) {
        print("Error uploading image: $e");
      }
    } else {
      print("No image picked.");
    }
  }

  void _doSave(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final lang = Lang.of(context);

      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: lang.recordSavedSuccessfully,
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {},
      );

      dialog.show();

      _saveAdminData();

      setState(() {
        _isEditing = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _fetchAdminData();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.myProfile,
                    style: themeData.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _isEditing ? _buildEditForm() : _buildProfileDetails(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildProfilePicture(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileDetails() {
    final labelStyle = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    );

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text('Username:', style: labelStyle),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_formData.username)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text('Email:', style: labelStyle),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_formData.email)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'username',
                initialValue: _formData.username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _formData.username = value ?? '';
                },
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'email',
                initialValue: _formData.email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _formData.email = value ?? '';
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: GestureDetector(
        onTap: _pickAndUploadImage,
        child: CircleAvatar(
          radius: 80,
          backgroundImage: _formData.profilePictureUrl.isNotEmpty
              ? NetworkImage(_formData.profilePictureUrl)
              : null,
          child: _formData.profilePictureUrl.isEmpty
              ? Icon(Icons.camera_alt, size: 80)
              : null,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEditing)
            ElevatedButton.icon(
              onPressed: _cancelEdit,
              icon: Icon(Icons.cancel),
              label: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              if (_isEditing) {
                _doSave(context);
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
            label: Text(_isEditing ? 'Save' : 'Edit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              backgroundColor: _isEditing ? Colors.blue : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormData {
  String username = '';
  String email = '';
  String profilePictureUrl = '';
}
