import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothClassicApp extends StatefulWidget {
  @override
  _BluetoothClassicAppState createState() => _BluetoothClassicAppState();
}

class _BluetoothClassicAppState extends State<BluetoothClassicApp> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  BluetoothDevice? selectedDevice;
  bool isConnecting = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    bluetooth.requestEnable(); // Turn on Bluetooth if it's off
  }

  void scanAndConnect() async {
    setState(() {
      isConnecting = true;
    });

    // ✅ Request runtime permission
    if (await Permission.bluetoothConnect.request().isGranted) {
      final bondedDevices = await bluetooth.getBondedDevices();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Select Bluetooth Device"),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView(
              children: bondedDevices.map((device) {
                return ListTile(
                  title: Text(device.name ?? "Unknown"),
                  subtitle: Text(device.address),
                  onTap: () {
                    Navigator.pop(context);
                    connectToDevice(device);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      );
    } else {
      setState(() {
        isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bluetooth permission denied")),
      );
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      final newConnection =
          await BluetoothConnection.toAddress(device.address);
      setState(() {
        selectedDevice = device;
        connection = newConnection;
        isConnected = true;
        isConnecting = false;
      });
      print('Connected to the device');
    } catch (e) {
      print('Cannot connect, exception occurred: $e');
      setState(() {
        isConnected = false;
        isConnecting = false;
      });
    }
  }

  void sendData(String data) async {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(data.codeUnits));
      await connection!.output.allSent;
    }
  }

  void disconnect() async {
    await connection?.close();
    setState(() {
      isConnected = false;
      connection = null;
      selectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classic Bluetooth: LED Control'),
        actions: [
          if (isConnected)
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: disconnect,
            ),
        ],
      ),
      body: Center(
        child: isConnected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Connected to: ${selectedDevice?.name ?? 'Device'}"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => sendData('a'),
                    child: Text("Send Blink"),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: isConnecting ? null : scanAndConnect,
                child: Text(isConnecting ? "Scanning..." : "Scan & Connect"),
              ),
      ),
    );
  }
}
