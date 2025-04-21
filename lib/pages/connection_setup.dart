import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/connection_manager.dart';
import 'welcome_page.dart';

class ConnectionSetupPage extends StatefulWidget {
  @override
  _ConnectionSetupPageState createState() => _ConnectionSetupPageState();
}

class _ConnectionSetupPageState extends State<ConnectionSetupPage> {
  bool _isScanning = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = "Scanning for devices...";
    });

    final connectionManager = ConnectionManager.instance;
    final success = await connectionManager.connectToDevice("HMSoft");

    setState(() {
      _isScanning = false;
      _statusMessage = success
          ? "Connected to HMSoft!"
          : "Failed to connect to HMSoft. Please try again.";
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connection Setup"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_statusMessage != null) Text(_statusMessage!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              child: Text(_isScanning ? "Scanning..." : "Connect to HMSoft"),
            ),
          ],
        ),
      ),
    );
  }
}
