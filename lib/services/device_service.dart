import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<DeviceDescriptor> getDeviceDescriptor() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return DeviceDescriptor(
        platform: 'android',
        model: androidInfo.model,
        version: androidInfo.version.release,
      );
    }

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return DeviceDescriptor(
        platform: 'ios',
        model: iosInfo.model,
        version: iosInfo.systemVersion,
      );
    }

    if (Platform.isWindows) {
      final windowsInfo = await _deviceInfoPlugin.windowsInfo;
      return DeviceDescriptor(
        platform: 'windows',
        model: windowsInfo.computerName,
        version: windowsInfo.displayVersion,
      );
    }

    if (Platform.isMacOS) {
      final macInfo = await _deviceInfoPlugin.macOsInfo;
      return DeviceDescriptor(
        platform: 'macos',
        model: macInfo.model,
        version: macInfo.osRelease,
      );
    }

    if (Platform.isLinux) {
      final linuxInfo = await _deviceInfoPlugin.linuxInfo;
      return DeviceDescriptor(
        platform: 'linux',
        model: linuxInfo.name,
        version: '${linuxInfo.version}',
      );
    }

    return const DeviceDescriptor(
      platform: 'unknown',
      model: 'unknown',
      version: 'unknown',
    );
  }
}

class DeviceDescriptor {
  const DeviceDescriptor({
    required this.platform,
    required this.model,
    required this.version,
  });

  final String platform;
  final String model;
  final String version;
}
