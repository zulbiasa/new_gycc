import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/dev_banner.png'),
            SizedBox(height: 16),
            Text(
              'Meet Our Team',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  TeamMember(
                    name: 'Zulhelmi',
                    description: 'Full Stack Developer with a passion for building scalable and efficient applications.',
                  ),
                  TeamMember(
                    name: 'Zulhusni',
                    description: 'Mobile App Developer with expertise in Flutter and a keen eye for design.',
                  ),
                  TeamMember(
                    name: 'Amira',
                    description: 'Backend Developer with a strong background in server-side programming and database management.',
                  ),
                  TeamMember(
                    name: 'Aqilah',
                    description: 'Frontend Developer with a talent for creating visually stunning and user-friendly interfaces.',
                  ),
                  TeamMember(
                    name: 'Aina',
                    description: 'Quality Assurance Engineer with a keen eye for detail and a passion for ensuring seamless user experiences.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamMember extends StatelessWidget {
  final String name;
  final String description;

  TeamMember({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}