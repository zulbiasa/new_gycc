import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  final String id; // User ID
  final String profileImageUrl;

  ProfilePage({required this.id, required this.profileImageUrl});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

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
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.profileImageUrl.isNotEmpty
                ? NetworkImage(widget.profileImageUrl)
                : AssetImage('assets/profile.jpg') as ImageProvider,
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
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
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
            Column(
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
                ),
              ],
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
          MaterialPageRoute(builder: (context) => AboutUsPage()),
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

// About Us Page
class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Us")),
      body: Center(child: Text("About Us content goes here!")),
    );
  }
}
