import 'package:flutter/material.dart';
import 'dart:async';

class AlertPage extends StatefulWidget {
  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  int _secondsLeft = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
          triggerSosAlert();
        }
      });
    });
  }

  void triggerSosAlert() {
    // Implement the SOS alert action here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SOS Alert Triggered!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context); // Navigate back after showing the alert
  }

  void cancelSosAlert() {
    _timer?.cancel();
    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sending SOS in $_secondsLeft seconds...',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: cancelSosAlert,
              child: Text(
                'Cancel SOS',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
