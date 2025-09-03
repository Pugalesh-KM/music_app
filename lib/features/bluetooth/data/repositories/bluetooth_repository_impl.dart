
import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/core/network/model/response.dart';
import 'package:music_app/features/bluetooth/data/datasources/bluetooth_remote_data_source.dart';
import 'package:music_app/features/bluetooth/data/models/bluetooth_model.dart';
import 'package:music_app/features/bluetooth/domain/repositories/bluetooth_repository.dart';

class BluetoothRepositoryImpl extends BluetoothRepository {
  final BluetoothRemoteDataSource _remoteDataSource;

  BluetoothRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<AppException, List<BluetoothModel>>> scanResults() {
    return _remoteDataSource.scanResults();
  }

  @override
  Future<Either<AppException, Response>> startScan() async {
    return await _remoteDataSource.startScan();
  }

  @override
  Future<Either<AppException, Response>> stopScan() async {
    return await _remoteDataSource.stopScan();
  }

  @override
  Future<Either<AppException, Response>> connectDevice(String deviceId) async {
    return await _remoteDataSource.connectDevice(deviceId);
  }

  @override
  Future<Either<AppException, Response>> disconnectDevice(String deviceId) async {
    return await _remoteDataSource.disconnectDevice(deviceId);
  }
}