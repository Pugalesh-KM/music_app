import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/core/network/model/response.dart';
import 'package:music_app/features/bluetooth/data/models/bluetooth_model.dart';

abstract class BluetoothRepository{
  Stream<Either<AppException, List<BluetoothModel>>> scanResults();
  Future<Either<AppException, Response>> startScan();
  Future<Either<AppException, Response>> stopScan();
  Future<Either<AppException, Response>> connectDevice(String deviceId);
  Future<Either<AppException, Response>> disconnectDevice(String deviceId);
}