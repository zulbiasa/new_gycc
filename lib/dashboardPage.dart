import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profilePage.dart';

class DashboardPage extends StatelessWidget {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String id;

  DashboardPage({required this.id});

  Future<String> _getUserName(String userId) async {
    final userSnapshot = await _databaseRef.child('User').child(userId).child('name').once();
    return userSnapshot.snapshot.value as String;
  }

  Future<String> _getProfileImageUrl(String userId) async {
    try {
      final ref = _storage.ref().child('$userId.png');
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching profile image URL: $e");
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
            future: _getProfileImageUrl(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  backgroundImage: AssetImage('assets/user_profile.png'),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return CircleAvatar(
                  backgroundImage: AssetImage('assets/user_profile.png'),
                );
              }

              final profileImageUrl = snapshot.data!;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        id: id,
                        profileImageUrl: profileImageUrl,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getUserName(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                          'assets/elderly_couple.png', // Updated path
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
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.notifications,
                        label: "SOS Alert",
                        color: Colors.blue,
                        iconSize: 70,
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.medication,
                        label: "Medicine Reminders",
                        color: Colors.blue,
                        iconSize: 70,
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.location_on,
                        label: "Activities Tracking",
                        color: Colors.blue,
                        iconSize: 70,
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.mood,
                        label: "Mood",
                        color: Colors.blue,
                        iconSize: 70,
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
      {required IconData icon, required String label, required Color color, required double iconSize}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () {
        // Define navigation or action here
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
