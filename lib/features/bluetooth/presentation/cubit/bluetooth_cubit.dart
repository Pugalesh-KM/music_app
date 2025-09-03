import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/bluetooth/data/models/bluetooth_model.dart';
import 'package:music_app/features/bluetooth/domain/usecases/bluetooth_use_case.dart';
part 'bluetooth_state.dart';

class BluetoothCubit extends Cubit<BluetoothState>{
  final BluetoothUseCase _useCase;

  BluetoothCubit(this._useCase) : super(BluetoothInitial());

  Future<void> startScan() async {
    emit(BluetoothLoading());
    final result = await _useCase.startScan();
    result.fold(
          (failure) => emit(BluetoothError(failure.message)),
          (_) => _listenScanResults(),
    );
  }

  Future<void> stopScan() async {
    final result = await _useCase.stopScan();
    result.fold(
          (failure) => emit(BluetoothError(failure.message)),
          (_) => emit(BluetoothStopped()),
    );
  }

  Future<void> connect(String deviceId) async {
    emit(BluetoothLoading());
    final result = await _useCase.connectDevice(deviceId);
    result.fold(
          (failure) => emit(BluetoothError(failure.message)),
          (_) => emit(BluetoothConnected(deviceId)),
    );
  }

  Future<void> disconnect(String deviceId) async {
    emit(BluetoothLoading());
    final result = await _useCase.disconnectDevice(deviceId);
    result.fold(
          (failure) => emit(BluetoothError(failure.message)),
          (_) => emit(BluetoothDisconnected(deviceId)),
    );
  }

  void _listenScanResults() {
    _useCase.scanResults().listen((either) {
      either.fold(
            (failure) => emit(BluetoothError(failure.message)),
            (devices) => emit(BluetoothScanResults(devices)),
      );
    });
  }
}