import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ConnectionManager {
  ConnectionManager._privateConstructor();
  static final ConnectionManager instance = ConnectionManager._privateConstructor();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  DiscoveredDevice? _connectedDevice;
  QualifiedCharacteristic? _characteristic;

  Future<bool> connectToDevice(String deviceName) async {
    try {
      final scanStream = _ble.scanForDevices(withServices: []);
      await for (final device in scanStream) {
        if (device.name == deviceName) {
          _connectedDevice = device;
          break;
        }
      }

      if (_connectedDevice == null) return false;

      final connectionStream = _ble.connectToDevice(
        id: _connectedDevice!.id,
        connectionTimeout: const Duration(seconds: 10),
      );

      await for (final connectionState in connectionStream) {
        if (connectionState.connectionState == DeviceConnectionState.connected) {
          _characteristic = QualifiedCharacteristic(
            serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
            characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
            deviceId: _connectedDevice!.id,
          );
          return true;
        }
      }
    } catch (e) {
      print("Error connecting to device: $e");
    }
    return false;
  }

  Future<void> sendMessage(String message) async {
    if (_characteristic == null) {
      print("No connected device.");
      return;
    }
    final bytes = message.codeUnits;
    await _ble.writeCharacteristicWithResponse(_characteristic!, value: bytes);
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _ble.clearGattCache(_connectedDevice!.id);
      _connectedDevice = null;
      _characteristic = null;
    }
  }

  bool get isConnected => _connectedDevice != null;
}
