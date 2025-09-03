import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {

  Future<void> init() async {
    await _checkPermissions();
  }

  /// Check and request required permissions
  Future<void> _checkPermissions() async {
    // Android 12+ requires bluetoothScan + bluetoothConnect
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (scanStatus.isDenied || connectStatus.isDenied || locationStatus.isDenied) {
      throw Exception("Bluetooth permissions denied");
    }
  }

  /// Get current adapter state (on/off, unauthorized, etc.)
  Stream<fb.BluetoothAdapterState> get adapterState =>
      fb.FlutterBluePlus.adapterState;

  /// Start scanning for nearby devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 5)}) async {
    await _checkPermissions();
    await fb.FlutterBluePlus.startScan(timeout: timeout);
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await fb.FlutterBluePlus.stopScan();
  }

  /// Stream scan results
  Stream<List<fb.ScanResult>> get scanResults => fb.FlutterBluePlus.scanResults;

  /// Connect to a device
  Future<void> connect(fb.BluetoothDevice device,
      {bool autoConnect = false}) async {
    await _checkPermissions();
    await device.connect(autoConnect: autoConnect);
  }

  /// Disconnect from a device
  Future<void> disconnect(fb.BluetoothDevice device) async {
    await device.disconnect();
  }

  /// Listen to device connection state
  Stream<fb.BluetoothConnectionState> connectionState(
      fb.BluetoothDevice device) {
    return device.connectionState;
  }

  /// Discover services of a device (e.g., audio, battery, etc.)
  Future<List<fb.BluetoothService>> discoverServices(
      fb.BluetoothDevice device) async {
    await _checkPermissions();
    return await device.discoverServices();
  }

  /// Read from a characteristic
  Future<List<int>> readCharacteristic(
      fb.BluetoothCharacteristic characteristic) async {
    return await characteristic.read();
  }

  /// Write to a characteristic
  Future<void> writeCharacteristic(
      fb.BluetoothCharacteristic characteristic,
      List<int> value, {
        bool withoutResponse = false,
      }) async {
    await characteristic.write(value, withoutResponse: withoutResponse);
  }

  /// Subscribe to notifications for a characteristic
  Stream<List<int>> subscribeToCharacteristic(
      fb.BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);
    return characteristic.onValueReceived;
  }
}
