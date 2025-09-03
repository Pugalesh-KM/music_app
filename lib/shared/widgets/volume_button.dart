import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeButtonWidget extends StatefulWidget {
  const VolumeButtonWidget({super.key});

  @override
  State<VolumeButtonWidget> createState() => _VolumeButtonWidgetState();
}

class _VolumeButtonWidgetState extends State<VolumeButtonWidget> {
  double _volume = 0.0;

  @override
  void initState() {
    VolumeController.instance.showSystemUI = true;
    super.initState();
    VolumeController.instance.getVolume().then(
      (v) => setState(() => _volume = v),
    );

    VolumeController.instance.addListener((newVolume) {
      setState(() => _volume = newVolume);
    });
  }

  void _increaseVolume() async {
    VolumeController.instance.showSystemUI = true;
    await VolumeController.instance.setVolume(_volume);
    VolumeController.instance.showSystemUI = false;
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (_volume == 0.0) {
      return IconButton(
        icon: const Icon(Icons.volume_off_outlined),
        onPressed: _increaseVolume,
      );
    }
    return IconButton(
      icon: const Icon(Icons.volume_up_outlined),
      onPressed: _increaseVolume,
    );
  }
}
