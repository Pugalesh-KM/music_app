import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/core/network/model/response.dart';
import 'package:music_app/core/services/bluetooth_service.dart';
import 'package:music_app/features/bluetooth/data/models/bluetooth_model.dart';

abstract class BluetoothRemoteDataSource{
  Stream<Either<AppException, List<BluetoothModel>>> scanResults();
  Future<Either<AppException, Response>> startScan();
  Future<Either<AppException, Response>> stopScan();
  Future<Either<AppException, Response>> connectDevice(String deviceId);
  Future<Either<AppException, Response>> disconnectDevice(String deviceId);
}

class BluetoothRemoteDataSourceImpl extends BluetoothRemoteDataSource {
  final BluetoothService _bluetoothService;
  BluetoothRemoteDataSourceImpl(this._bluetoothService);

  @override
  Stream<Either<AppException, List<BluetoothModel>>> scanResults() async* {
    try {
      yield* _bluetoothService.scanResults.map(
            (results) => Right(
          results
              .map(
                (r) => BluetoothModel(
              id: r.device.remoteId.str,
              name: r.device.platformName.isNotEmpty
                  ? r.device.platformName
                  : "Unknown",
            ),
          )
              .toList(),
        ),
      );
    } catch (e) {
      yield Left(
        AppException(
          message: "Failed to fetch scan results",
          statusCode: -1,
          identifier: "${e.toString()}\nBluetoothRemoteDataSourceImpl.scanResults",
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Response>> startScan() async {
    try {
      await _bluetoothService.startScan();
      return Either.right(Response(statusMessage: "Scan started successfully", statusCode: 200));
    } catch (e) {
      return Left(
        AppException(
          message: "Failed to start scan",
          statusCode: -1,
          identifier: "${e.toString()}\nBluetoothRemoteDataSourceImpl.startScan",
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Response>> stopScan() async {
    try {
      await _bluetoothService.stopScan();
      return Either.right(Response(statusMessage: "Scan stopped successfully", statusCode: 200));
    } catch (e) {
      return Left(
        AppException(
          message: "Failed to stop scan",
          statusCode: -1,
          identifier: "${e.toString()}\nBluetoothRemoteDataSourceImpl.stopScan",
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Response>> connectDevice(String deviceId) async {
    try {
      final device = fb.BluetoothDevice.fromId(deviceId);
      await _bluetoothService.connect(device);
      return Either.right(Response(statusMessage: "Connected to $deviceId",statusCode: 200));
    } catch (e) {
      return Left(
        AppException(
          message: "Failed to connect to device",
          statusCode: -1,
          identifier:
          "${e.toString()}\nBluetoothRemoteDataSourceImpl.connectDevice",
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Response>> disconnectDevice(String deviceId) async {
    try {
      final device = fb.BluetoothDevice.fromId(deviceId);
      await _bluetoothService.disconnect(device);
      return Either.right(Response(statusMessage: "Disconnected from $deviceId",statusCode: 200));
    } catch (e) {
      return Left(
        AppException(
          message: "Failed to disconnect from device",
          statusCode: -1,
          identifier:
          "${e.toString()}\nBluetoothRemoteDataSourceImpl.disconnectDevice",
        ),
      );
    }
  }
}