part of 'bluetooth_cubit.dart';

abstract class BluetoothState {
  const BluetoothState();
}

class BluetoothInitial extends BluetoothState {
  const BluetoothInitial();
}

class BluetoothLoading extends BluetoothState {
  const BluetoothLoading();
}

class BluetoothError extends BluetoothState {
  final String message;
  const BluetoothError(this.message);
}

class BluetoothScanResults extends BluetoothState {
  final List<BluetoothModel> devices;
  const BluetoothScanResults(this.devices);
}

class BluetoothConnected extends BluetoothState {
  final String deviceId;
  const BluetoothConnected(this.deviceId);
}

class BluetoothDisconnected extends BluetoothState {
  final String deviceId;
  const BluetoothDisconnected(this.deviceId);
}

class BluetoothStopped extends BluetoothState {
  const BluetoothStopped();
}