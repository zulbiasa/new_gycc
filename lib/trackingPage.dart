import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ActivityTracking extends StatefulWidget {
  final String userId;

  const ActivityTracking({super.key, required this.userId});

  @override
  _ActivityTrackingState createState() => _ActivityTrackingState();
}

class _ActivityTrackingState extends State<ActivityTracking> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  late Future<List<Map<String, dynamic>>> _activityList;
  String _filter = 'all'; // Filter state: 'all', 'completed', 'incomplete'

  @override
  void initState() {
    super.initState();
    _activityList = _fetchActivities();
  }

  Future<List<Map<String, dynamic>>> _fetchActivities() async {
    try {
      final userSnapshot = await _databaseRef
          .child('User')
          .child(widget.userId)
          .child('CareLog')
          .once();

      final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      List<Map<String, dynamic>> activities = [];

      if (userData != null) {
        userData.forEach((logId, logData) {
          final data = logData as Map<dynamic, dynamic>?;

          if (data != null) {
            activities.add({
              'activity': data['activity']?.toString() ?? 'No Activity',
              'notes': data['notes']?.toString() ?? '',
              'date': data['date']?.toString() ?? '',
              'status': data['status']?.toString().toLowerCase() ?? 'incomplete',
            });
          }
        });
      }

      return activities;
    } catch (e) {
      print("Error fetching activities: $e");
      return [];
    }
  }

  void _updateFilter(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> activities) {
    if (_filter == 'completed') {
      return activities.where((activity) => activity['status'] == 'complete').toList();
    } else if (_filter == 'incomplete') {
      return activities.where((activity) => activity['status'] != 'complete').toList();
    }
    return activities; // No filter applied
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Activities'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo_banner.png',
              height: 40,
              width: 60,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('All', 'all', Colors.grey),
                const SizedBox(width: 8),
                _buildFilterButton('Completed', 'completed', Colors.green),
                const SizedBox(width: 8),
                _buildFilterButton('Incomplete', 'incomplete', Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _activityList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No activities found."));
                }

                final activities = _applyFilter(snapshot.data!);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final isCompleted = activity['status'] == 'complete';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                activity['activity'].toString().contains('Meal')
                                    ? Icons.restaurant
                                    : Icons.medication,
                                size: 40,
                                color: isCompleted ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Activity: ${activity['activity']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Notes: ${activity['notes']}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          Text(
                            'Date: ${activity['date']}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, String value, Color color) {
    return ElevatedButton(
      onPressed: () => _updateFilter(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: _filter == value ? color : color.withOpacity(0.5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}