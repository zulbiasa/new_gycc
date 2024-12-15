import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'aboutPage.dart';

class ProfilePage extends StatefulWidget {
  final String id; // User ID
  final String profileImageUrl;

  ProfilePage({required this.id, required this.profileImageUrl});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  File? _profileImage;
  bool _isLoading = false; // Loading indicator state

  // Variables to hold user data
  String userName = "Loading...";
  String blood = "N/A";
  String height = "N/A";
  String weight = "N/A";
  String age = "N/A";
  String subscriptionPlan = "N/A";
  String status = "N/A";
  double _fontSize = 16; // Default font size

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firebase
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      final userSnapshot = await _databaseRef.child('User').child(widget.id).once();
      final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>;
      final userSnapshot2 = await _databaseRef.child('User').child(widget.id).child('MedicalHistory').once();
      final userData2 = userSnapshot2.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        userName = userData['name'] ?? "";
        blood = userData2['blood'] ?? "";
        height = userData2['height'] ?? "";
        weight = userData2['weight'] ?? "";
        age = userData['age'] ?? "";
        subscriptionPlan = userData['subscriptionPlan'] ?? "";
        status = userData['status'] ?? "";
      });
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Enforce 1:1 aspect ratio
        );

        if (croppedFile != null) {
          setState(() {
            _profileImage = File(croppedFile.path);
          });

          final storageRef = FirebaseStorage.instance.ref();
          final profileImageRef = storageRef.child('${widget.id}');
          await profileImageRef.putFile(_profileImage!);
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo_banner.png', // Replace with your logo path
              height: 16,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2ea4db),
                        Color(0xFF0f3ba3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      SizedBox(height: 16),
                      _buildInfoCards(),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _buildAboutUsSection(context),
                _buildFontSizeSlider(),
              ],
            ),
          ),
          if (_isLoading)
            Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.3), // Semi-transparent background
                ),
                Center(
                  child: ClipOval(
                    child: Container(
                      width: 50, // Custom width
                      height: 50, // Custom height
                      color: Colors.white, // White circular background
                      child: CircularProgressIndicator(), // Loading indicator
                    ),
                  ),
                ),
              ]
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _viewCurrentPhoto(); // Show dialog to view the current photo
            },
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : widget.profileImageUrl.isNotEmpty
                  ? NetworkImage(widget.profileImageUrl)
                  : AssetImage('assets/profile.jpg') as ImageProvider,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewCurrentPhoto() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow closing dialog by tapping outside
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.7), // Dark background with reduced opacity
          body: Center(
            child: Stack(
              children: [
                Center(
                  child: _profileImage != null
                      ? Image.file(_profileImage!, fit: BoxFit.contain)
                      : widget.profileImageUrl.isNotEmpty
                      ? Image.network(widget.profileImageUrl, fit: BoxFit.contain)
                      : Image.asset('assets/profile.jpg', fit: BoxFit.contain),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      _pickImage(); // Allow image editing
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard('Blood', blood, Icons.bloodtype),
            _buildInfoCard('Height', height, Icons.height),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard('Weight', weight, Icons.monitor_weight),
            _buildInfoCard('Age', age, Icons.people),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard('Subscription Plan', subscriptionPlan, Icons.card_membership),
            _buildInfoCard(
              'Status',
              status,
              Icons.check_circle,
              status == 'Active' ? Colors.green : Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, [Color? iconColor]) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: _fontSize),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // Add this line
                    overflow: TextOverflow.ellipsis, // Add this line
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutUsSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "About Us",
              style: TextStyle(color: Colors.white, fontSize: _fontSize + 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      children: [
        Text("Adjust Font Size", style: TextStyle(fontSize: _fontSize)),
        Slider(
          value: _fontSize,
          min: 12,
          max: 24,
          divisions: 6,
          label: "${_fontSize.toStringAsFixed(0)}",
          onChanged: (value) {
            setState(() {
              _fontSize = value;
            });
          },
        ),
      ],
    );
  }
}
