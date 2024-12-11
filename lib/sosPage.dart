import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:new_gycc/alertPage.dart';
import 'contact.dart'; // Import your contact model

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  _SosPageState createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  final Box<Contact> _contactBox = Hive.box<Contact>('contacts');
  List<Contact> familyContacts = [];

  @override
  void initState() {
    super.initState();
    loadFamilyContacts();
  }

  void loadFamilyContacts() {
    setState(() {
      familyContacts = _contactBox.values.toList();
    });
  }

  void addFamilyContact(String name, String phone) {
    final newContact = Contact(name: name, phone: phone);
    _contactBox.add(newContact);
    loadFamilyContacts();
  }

  void removeFamilyContact(int index) {
    _contactBox.deleteAt(index);
    loadFamilyContacts();
  }

  void showAddContactDialog() {
    String name = '';
    String phone = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Family Contact'),
          icon: const Icon(Icons.family_restroom, size: 50),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone, // Restrict to phone number input
                onChanged: (value) {
                  phone = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addFamilyContact(name, phone);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Container(
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 10),
                  Text('SOS Alert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 40), // Placeholder for alignment
          ],
        ),
      ),
    );
  }

  void sendSosAlert() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlertPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE1F0FA), // Light Blue
              Color(0xFFF7E0E3), // Light Pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, right: 16.0, left: 16.0, bottom: 16.0),
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 30),
              // Enlarged SOS Button occupying most of the upper screen
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Expanded(
                  flex: 3,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(100), // Larger padding for a bigger button
                      ),
                      onPressed: () {
                        sendSosAlert(); // Call the SOS alert function
                      },
                      child: const Text(
                        'SOS',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Family Contacts List
              Expanded(
                child: ListView.builder(
                  itemCount: familyContacts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding around each item
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12), // Rounded corners for the background and card
                        child: Dismissible(
                          key: Key(familyContacts[index].name), // Unique key for each contact
                          direction: DismissDirection.endToStart, // Swipe from right to left
                          onDismissed: (direction) {
                            // Store the contact's info before removing it
                            final removedContact = familyContacts[index];
                            // Remove the contact from the list
                            removeFamilyContact(index);
                            // Show a snackbar to confirm deletion
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${removedContact.name} removed'),
                              ),
                            );
                          },
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red, // Background color when swiping
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white), // Delete icon
                          ),
                          child: Card(
                            margin: EdgeInsets.zero, // Remove internal margin
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Match rounded corners
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0), // Padding for the card content
                              child: ListTile(
                                title: Text(familyContacts[index].name),
                                subtitle: Text(familyContacts[index].phone),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddContactDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}