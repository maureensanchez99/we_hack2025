import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothBleApp extends StatefulWidget {
  @override
  _BluetoothBleAppState createState() => _BluetoothBleAppState();
}

class _BluetoothBleAppState extends State<BluetoothBleApp> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late Stream<DiscoveredDevice> _scanStream;
  DiscoveredDevice? _selectedDevice;
  bool _isScanning = false;
  bool _isConnected = false;
  late Stream<ConnectionStateUpdate> _connectionStream;
  late QualifiedCharacteristic _characteristic;

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

  void _startScan() {
    setState(() {
      _isScanning = true;
    });

    _scanStream = _ble.scanForDevices(withServices: []);
    _scanStream.listen((device) {
      if (device.name == "HMSoft") {
        setState(() {
          _selectedDevice = device;
          _isScanning = false; // Stop scanning once the device is found
        });
        _connectToDevice(); // Automatically connect to the device
      }
    }).onDone(() {
      setState(() {
        _isScanning = false;
      });
      if (_selectedDevice == null) {
        _showNoDeviceFoundDialog(); // Show a dialog if no "HMSoft" device is found
      }
    });
  }

  void _showNoDeviceFoundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Device Not Found"),
          content: Text("No device named 'HMSoft' was found."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _connectToDevice() async {
    if (_selectedDevice == null) return;

    setState(() {
      _isConnected = false;
    });

    _connectionStream = _ble.connectToDevice(
      id: _selectedDevice!.id,
      connectionTimeout: const Duration(seconds: 10),
    );

    _connectionStream.listen((event) {
      if (event.connectionState == DeviceConnectionState.connected) {
        setState(() {
          _isConnected = true;
        });

        // Define the characteristic for communication (update UUIDs as needed)
        _characteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse("0000180A-0000-1000-8000-00805f9b34fb"), // Example service UUID
          characteristicId: Uuid.parse("00002A57-0000-1000-8000-00805f9b34fb"), // Example characteristic UUID
          deviceId: _selectedDevice!.id,
        );
      } else if (event.connectionState == DeviceConnectionState.disconnected) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  void _sendData(String data) async {
    if (_isConnected) {
      final bytes = data.codeUnits;
      await _ble.writeCharacteristicWithResponse(_characteristic, value: bytes);
      print("Data sent: $data");
    }
  }

  void _disconnect() async {
    if (_selectedDevice != null) {
      await _ble.clearGattCache(_selectedDevice!.id);
      setState(() {
        _isConnected = false;
        _selectedDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE: HMSoft Connection'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: _disconnect,
            ),
        ],
      ),
      body: Center(
        child: _isConnected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Connected to: ${_selectedDevice?.name ?? 'Device'}"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _sendData('a'),
                    child: Text("Send Blink"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isScanning ? null : _startScan,
                    child: Text(_isScanning ? "Scanning..." : "Scan for HMSoft"),
                  ),
                ],
              ),
      ),
    );
  }
}
