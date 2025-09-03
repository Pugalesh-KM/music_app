
import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/core/network/model/response.dart';
import 'package:music_app/features/bluetooth/data/models/bluetooth_model.dart';
import 'package:music_app/features/bluetooth/domain/repositories/bluetooth_repository.dart';

class BluetoothUseCase{
  final BluetoothRepository _repository;
  BluetoothUseCase(this._repository);

  Stream<Either<AppException, List<BluetoothModel>>> scanResults() {
    return _repository.scanResults();
  }

  Future<Either<AppException, Response>> startScan() {
    return _repository.startScan();
  }

  Future<Either<AppException, Response>> stopScan() {
    return _repository.stopScan();
  }

  Future<Either<AppException, Response>> connectDevice(String deviceId) {
    return _repository.connectDevice(deviceId);
  }

  Future<Either<AppException, Response>> disconnectDevice(String deviceId) {
    return _repository.disconnectDevice(deviceId);
  }

}