import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum DeviceConnection { wifi, mobile, ethernet, other, offline }

class DeviceBattery {
  const DeviceBattery({required this.level, required this.charging});

  final int? level;
  final bool charging;
}

abstract interface class DeviceStatusRepository {
  Future<DeviceBattery> readBattery();
  Future<DeviceConnection> readConnection();
  Stream<void> get batteryChanges;
  Stream<DeviceConnection> get connectionChanges;
}

class PlatformDeviceStatusRepository implements DeviceStatusRepository {
  PlatformDeviceStatusRepository()
    : _battery = Battery(),
      _connectivity = Connectivity();

  final Battery _battery;
  final Connectivity _connectivity;

  @override
  Future<DeviceBattery> readBattery() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    return DeviceBattery(
      level: level >= 0 && level <= 100 ? level : null,
      charging: state == BatteryState.charging,
    );
  }

  @override
  Future<DeviceConnection> readConnection() async =>
      _connection(await _connectivity.checkConnectivity());

  @override
  Stream<void> get batteryChanges => _battery.onBatteryStateChanged.map((_) {});

  @override
  Stream<DeviceConnection> get connectionChanges =>
      _connectivity.onConnectivityChanged.map(_connection);

  static DeviceConnection _connection(List<ConnectivityResult> connections) {
    if (connections.contains(ConnectivityResult.wifi)) {
      return DeviceConnection.wifi;
    }
    if (connections.contains(ConnectivityResult.mobile)) {
      return DeviceConnection.mobile;
    }
    if (connections.contains(ConnectivityResult.ethernet)) {
      return DeviceConnection.ethernet;
    }
    if (connections.isEmpty ||
        connections.every((value) => value == ConnectivityResult.none)) {
      return DeviceConnection.offline;
    }
    return DeviceConnection.other;
  }
}
