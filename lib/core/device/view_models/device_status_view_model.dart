import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repos/device_status_repository.dart';

class DeviceStatusViewModel extends ChangeNotifier {
  DeviceStatusViewModel({required DeviceStatusRepository repository})
    : _repository = repository;

  final DeviceStatusRepository _repository;
  DeviceBattery? battery;
  DeviceConnection? connection;
  StreamSubscription<void>? _batterySubscription;
  StreamSubscription<DeviceConnection>? _connectionSubscription;
  Timer? _timer;
  bool _active = false;
  int _generation = 0;
  int _connectionRevision = 0;
  int _batteryRevision = 0;

  void resume() {
    if (_active) return;
    _active = true;
    final generation = ++_generation;
    _batterySubscription = _repository.batteryChanges.listen(
      (_) => unawaited(_refreshBattery()),
      onError: (Object _) {
        if (!_current(generation)) return;
        ++_batteryRevision;
        battery = null;
        notifyListeners();
      },
    );
    _connectionSubscription = _repository.connectionChanges.listen(
      (value) {
        if (!_current(generation)) return;
        ++_connectionRevision;
        connection = value;
        notifyListeners();
      },
      onError: (Object _) {
        if (!_current(generation)) return;
        ++_connectionRevision;
        connection = null;
        notifyListeners();
      },
    );
    unawaited(_refreshBattery());
    unawaited(_refreshConnection());
    // Battery plugins report charging events, not every percentage change.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(_refreshBattery());
      unawaited(_refreshConnection());
    });
  }

  bool _current(int generation) => _active && generation == _generation;

  Future<void> _refreshBattery() async {
    final generation = _generation;
    final revision = ++_batteryRevision;
    DeviceBattery? value;
    try {
      value = await _repository.readBattery();
    } catch (_) {
      // Unsupported platforms and unavailable readings remain unknown.
    }
    if (!_current(generation) || revision != _batteryRevision) return;
    battery = value;
    notifyListeners();
  }

  Future<void> _refreshConnection() async {
    final generation = _generation;
    final revision = ++_connectionRevision;
    DeviceConnection? value;
    try {
      value = await _repository.readConnection();
    } catch (_) {
      // Do not substitute a successful Wi-Fi connection for a failed reading.
    }
    if (!_current(generation) || revision != _connectionRevision) return;
    connection = value;
    notifyListeners();
  }

  void pause() {
    _active = false;
    ++_generation;
    _timer?.cancel();
    _timer = null;
    unawaited(_batterySubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    _batterySubscription = null;
    _connectionSubscription = null;
  }

  @override
  void dispose() {
    pause();
    super.dispose();
  }
}
