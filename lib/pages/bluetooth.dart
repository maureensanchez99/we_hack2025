import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/connection_manager.dart';

class BluetoothMessenger {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  static const String _deviceName = "HMSoft";
  static const String _serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String _characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb";

  Future<void> sendMessage(String message) async {
    if (message.length != 1) {
      print("Error: Message must be a single character.");
      return;
    }

    // Request permissions before proceeding
    if (!await _requestPermissions()) {
      print("Permissions not granted. Cannot proceed.");
      return;
    }

    DiscoveredDevice? targetDevice;

    // Scan for the device
    print("Scanning for device: $_deviceName...");
    await _ble.scanForDevices(withServices: []).listen((device) {
      if (device.name == _deviceName) {
        targetDevice = device;
        print("Device found: ${device.name}");
      }
    }).asFuture();

    if (targetDevice == null) {
      print("Device $_deviceName not found.");
      return;
    }

    // Connect to the device
    print("Connecting to device: ${targetDevice!.name}...");
    final connectionStream = _ble.connectToDevice(
      id: targetDevice!.id,
      connectionTimeout: const Duration(seconds: 10),
    );

    await for (final connectionState in connectionStream) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print("Connected to ${targetDevice!.name}");

        // Define the characteristic
        final characteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse(_serviceUuid),
          characteristicId: Uuid.parse(_characteristicUuid),
          deviceId: targetDevice!.id,
        );

        // Send the message
        print("Sending message: $message");
        final bytes = message.codeUnits;
        await _ble.writeCharacteristicWithResponse(characteristic, value: bytes);
        print("Message sent!");

        // Disconnect after sending the message
        print("Disconnecting from ${targetDevice!.name}...");
        await _ble.clearGattCache(targetDevice!.id);
        print("Disconnected.");
        break;
      }
    }
  }

  Future<bool> _requestPermissions() async {
    // Request Bluetooth and location permissions
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    final statuses = await permissions.request();

    // Check if all permissions are granted
    if (statuses.values.every((status) => status.isGranted)) {
      return true;
    } else {
      // Show a dialog if permissions are denied
      _showPermissionDialog();
      return false;
    }
  }

  void _showPermissionDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text("Permissions Required"),
          content: const Text(
            "This app requires Bluetooth and location permissions to function properly. Please grant the necessary permissions.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Open app settings for the user to grant permissions
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
    });
  }
}

// Add a global navigator key to access the context for showing dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



/*ORIGINAL TESTER - FUNCTIONAL*/
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
    final connectionManager = ConnectionManager.instance;
    if (connectionManager.isConnected) {
      await connectionManager.sendMessage(data);
      print("Data sent: $data");
    } else {
      print("No device connected.");
    }
  }

  void _disconnect() async {
    final connectionManager = ConnectionManager.instance;
    await connectionManager.disconnect();
    setState(() {});
  }

  void discoverServices() async {
    if (_selectedDevice == null) {
      print("No device selected.");
      return;
    }

    final services = await _ble.discoverServices(_selectedDevice!.id);
    for (var service in services) {
      print('Service UUID: ${service.serviceId}');
      for (var characteristic in service.characteristics) {
        print('  Characteristic UUID: ${characteristic.characteristicId}');
        print('  Properties: '
            'read: ${characteristic.isReadable}, '
            'write: ${characteristic.isWritableWithResponse || characteristic.isWritableWithoutResponse}, '
            'notify: ${characteristic.isNotifiable}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionManager = ConnectionManager.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE: HMSoft Connection'),
        actions: [
          if (connectionManager.isConnected)
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: _disconnect,
            ),
        ],
      ),
      body: Center(
        child: connectionManager.isConnected
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