import 'package:flutter/material.dart';

class MedicalPage extends StatefulWidget {
  @override
  _MedicalPageState createState() => _MedicalPageState();
}

class _MedicalPageState extends State<MedicalPage> {
  String selectedFilter = 'All Records';

  // Dummy medical records
  final List<Map<String, String>> medicalRecords = [
    {
      'date': 'October 24 2024',
      'specialty': 'Dentist',
      'icon': 'medical_services',
      'time': '9.00 am',
      'place': 'Klinik Kesihatan Kuala Lumpur',
      'year': '2024'
    },
    {
      'date': 'July 18 2024',
      'specialty': 'ENT Doctor',
      'icon': 'hearing',
      'time': '8.00 am',
      'place': 'Hospital Kuala Lumpur',
      'year': '2024'
    },
    {
      'date': 'April 8 2023',
      'specialty': 'Allergy',
      'icon': 'spa',
      'time': '2.00 pm',
      'place': 'Klinik Kesihatan Kuala Lumpur',
      'year': '2023'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtered records based on selected filter
    final filteredRecords = selectedFilter == 'All Records'
        ? medicalRecords
        : medicalRecords
        .where((record) => record['year'] == selectedFilter)
        .toList();

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined , color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'GoldenYearsCareConnect',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services, color: Colors.blue, size: 28),
                SizedBox(width: 8),
                Text(
                  'Medical History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Year Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                    label: 'All Records',
                    isSelected: selectedFilter == 'All Records',
                    onTap: () => setState(() => selectedFilter = 'All Records'),
                  ),
                  FilterButton(
                    label: '2024',
                    isSelected: selectedFilter == '2024',
                    onTap: () => setState(() => selectedFilter = '2024'),
                  ),
                  FilterButton(
                    label: '2023',
                    isSelected: selectedFilter == '2023',
                    onTap: () => setState(() => selectedFilter = '2023'),
                  ),
                  FilterButton(
                    label: '2022',
                    isSelected: selectedFilter == '2022',
                    onTap: () => setState(() => selectedFilter = '2022'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Medical Records List
            Expanded(
              child: ListView.builder(
                itemCount: filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = filteredRecords[index];
                  return MedicalRecordCard(
                    date: record['date']!,
                    specialty: record['specialty']!,
                    icon: record['icon'] == 'medical_services'
                        ? Icons.medical_services
                        : record['icon'] == 'hearing'
                        ? Icons.hearing
                        : Icons.spa,
                    time: record['time']!,
                    place: record['place']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isSelected ? Colors.blue : Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          backgroundColor: isSelected ? Colors.blue[100] : Colors.transparent,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class MedicalRecordCard extends StatelessWidget {
  final String date;
  final String specialty;
  final IconData icon;
  final String time;
  final String place;

  MedicalRecordCard({
    required this.date,
    required this.specialty,
    required this.icon,
    required this.time,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures full-width alignment
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[300], // Fill color for the header
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      specialty,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[50], // Fill color for the body
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Schedule at : $time'),
                SizedBox(height: 8),
                Text('Place at : $place'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

