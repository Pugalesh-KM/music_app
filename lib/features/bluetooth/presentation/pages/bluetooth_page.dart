import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/bluetooth/presentation/cubit/bluetooth_cubit.dart';
import 'package:music_app/features/bluetooth/data/models/bluetooth_model.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Devices")),
      body: BlocConsumer<BluetoothCubit, BluetoothState>(
        listener: (context, state) {
          if (state is BluetoothError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is BluetoothConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Connected to ${state.deviceId}")),
            );
          } else if (state is BluetoothDisconnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Disconnected from ${state.deviceId}")),
            );
          }
        },
        builder: (context, state) {
          if (state is BluetoothLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BluetoothScanResults) {
            return _buildDeviceList(context, state.devices);
          }

          if (state is BluetoothStopped) {
            return const Center(child: Text("Scan stopped"));
          }

          return Center(
            child: ElevatedButton(
              onPressed: () =>
                  context.read<BluetoothCubit>().startScan(),
              child: const Text("Start Scan"),
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<BluetoothCubit, BluetoothState>(
        builder: (context, state) {
          if (state is BluetoothScanResults) {
            return FloatingActionButton(
              onPressed: () =>
                  context.read<BluetoothCubit>().stopScan(),
              child: const Icon(Icons.stop),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, List<BluetoothModel> devices) {
    if (devices.isEmpty) {
      return const Center(child: Text("No devices found"));
    }

    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return ListTile(
          title: Text(device.name.isNotEmpty ? device.name : "Unknown Device"),
          subtitle: Text(device.id),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.bluetooth_connected),
                onPressed: () =>
                    context.read<BluetoothCubit>().connect(device.id),
              ),
              IconButton(
                icon: const Icon(Icons.bluetooth_disabled),
                onPressed: () =>
                    context.read<BluetoothCubit>().disconnect(device.id),
              ),
            ],
          ),
        );
      },
    );
  }
}
