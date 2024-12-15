import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:new_gycc/medicalPage.dart';
import 'package:new_gycc/sosPage.dart';
import 'package:new_gycc/trackingPage.dart';
import 'profilePage.dart';

class DashboardPage extends StatefulWidget {
  final String id;

  DashboardPage({required this.id});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> _getUserName(String userId) async {
    final userSnapshot = await _databaseRef.child('User').child(userId).child('name').once();
    return userSnapshot.snapshot.value as String;
  }

  Future<String> _getProfileImageUrl(String userId) async {
    try {
      final ref = _storage.ref().child('$userId');
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile image URL: $e");
      }
      return 'assets/user_profile.png'; // Fallback to a default image
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "HOME",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/logo_banner.png', // Updated path and icon
            height: 100,
            width: 100,
          ),
        ),
        actions: [
          FutureBuilder<String>(
            future: _getProfileImageUrl(widget.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator or placeholder while waiting
                return Image.asset('assets/user_profile.png',width: 45);
              }

              if (snapshot.hasError) {
                // Show default image if there's an error fetching the URL
                return Image.asset('assets/user_profile.png',width: 45);
              }

              final profileImageUrl = snapshot.data!;
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        id: widget.id,
                        profileImageUrl: profileImageUrl,
                      ),
                    ),
                  );
                  setState(() {}); // Refresh the Dashboard to fetch the latest data
                },
                child: ClipOval(
                  child: Container(
                    width: 50,
                    child: Image.network(
                      profileImageUrl,
                      errorBuilder: (context, error, stackTrace) => Image.asset('assets/user_profile.png', width: 45,),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getUserName(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.3), // Semi-transparent background
                ),
                Center(
                  child: ClipOval(
                    child: Container(
                      width: 45, // Custom width
                      height: 45, // Custom height
                      color: Colors.white, // White circular background
                      child: CircularProgressIndicator(), // Loading indicator
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userName = snapshot.data ?? 'User';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/elderly_couple.png',
                          height: 140,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hi, $userName",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Hope you are doing well !!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildDashboardButton(
                        context,
                        icon: Icons.favorite,
                        label: "Health",
                        color: Colors.blue,
                        iconSize: 70,
                        builder: MedicalPage(),
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.notifications,
                        label: "SOS Alert",
                        color: Colors.blue,
                        iconSize: 70,
                        builder: SosPage(),
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.medication,
                        label: "Medicine Reminders",
                        color: Colors.blue,
                        iconSize: 70,
                        builder: MedicalPage(),
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.location_on,
                        label: "Activities Tracking",
                        color: Colors.blue,
                        iconSize: 70,
                        builder: ActivityTracking(userId: widget.id),
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.mood,
                        label: "Mood",
                        color: Colors.blue,
                        iconSize: 70,
                        builder: MedicalPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon, required String label, required Color color, required double iconSize, required builder}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => builder));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
