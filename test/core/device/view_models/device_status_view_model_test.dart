import 'dart:async';

import 'package:beehome/core/device/repos/device_status_repository.dart';
import 'package:beehome/core/device/view_models/device_status_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDeviceStatusRepository implements DeviceStatusRepository {
  final batteryEvents = StreamController<void>.broadcast();
  final connectionEvents = StreamController<DeviceConnection>.broadcast();
  DeviceBattery battery = const DeviceBattery(level: 43, charging: false);
  DeviceConnection connection = DeviceConnection.wifi;
  Completer<DeviceConnection>? pendingConnection;
  bool failBattery = false;
  bool failConnection = false;
  int batteryReads = 0;

  @override
  Stream<void> get batteryChanges => batteryEvents.stream;
  @override
  Stream<DeviceConnection> get connectionChanges => connectionEvents.stream;

  @override
  Future<DeviceBattery> readBattery() async {
    ++batteryReads;
    if (failBattery) throw StateError('Reading unavailable');
    return battery;
  }

  @override
  Future<DeviceConnection> readConnection() async {
    if (failConnection) throw StateError('Reading unavailable');
    return pendingConnection?.future ?? connection;
  }

  Future<void> dispose() async {
    await batteryEvents.close();
    await connectionEvents.close();
  }
}

void main() {
  testWidgets('reads real values and polls battery percentage changes', (
    tester,
  ) async {
    final repository = FakeDeviceStatusRepository();
    final model = DeviceStatusViewModel(repository: repository);
    addTearDown(repository.dispose);
    addTearDown(model.dispose);
    model.resume();
    await tester.pump();
    expect(model.battery?.level, 43);
    expect(model.connection, DeviceConnection.wifi);
    repository.battery = const DeviceBattery(level: 42, charging: false);
    await tester.pump(const Duration(seconds: 30));
    expect(model.battery?.level, 42);
    repository.battery = const DeviceBattery(level: 42, charging: true);
    repository.batteryEvents.add(null);
    repository.connectionEvents.add(DeviceConnection.mobile);
    await tester.pump();
    expect(model.battery?.charging, isTrue);
    expect(model.connection, DeviceConnection.mobile);
    model.pause();
  });

  testWidgets('pauses background polling and refreshes when resumed', (
    tester,
  ) async {
    final repository = FakeDeviceStatusRepository();
    final model = DeviceStatusViewModel(repository: repository);
    addTearDown(repository.dispose);
    addTearDown(model.dispose);
    model.resume();
    await tester.pump();
    model.pause();
    final reads = repository.batteryReads;
    repository.battery = const DeviceBattery(level: 20, charging: false);
    repository.connection = DeviceConnection.offline;
    await tester.pump(const Duration(minutes: 2));
    expect(repository.batteryReads, reads);
    model.resume();
    await tester.pump();
    expect(model.battery?.level, 20);
    expect(model.connection, DeviceConnection.offline);
    model.pause();
  });

  testWidgets('a late connection read cannot overwrite a newer event', (
    tester,
  ) async {
    final repository = FakeDeviceStatusRepository();
    repository.pendingConnection = Completer<DeviceConnection>();
    final model = DeviceStatusViewModel(repository: repository);
    addTearDown(repository.dispose);
    addTearDown(model.dispose);
    model.resume();
    repository.connectionEvents.add(DeviceConnection.offline);
    await tester.pump();
    repository.pendingConnection!.complete(DeviceConnection.wifi);
    await tester.pump();
    expect(model.connection, DeviceConnection.offline);
    model.pause();
  });

  testWidgets('unavailable readings stay unknown and recover independently', (
    tester,
  ) async {
    final repository = FakeDeviceStatusRepository()
      ..failBattery = true
      ..failConnection = true;
    final model = DeviceStatusViewModel(repository: repository);
    addTearDown(repository.dispose);
    addTearDown(model.dispose);
    model.resume();
    await tester.pump();
    expect(model.battery, isNull);
    expect(model.connection, isNull);
    repository.failConnection = false;
    await tester.pump(const Duration(seconds: 30));
    expect(model.battery, isNull);
    expect(model.connection, DeviceConnection.wifi);
    repository.failBattery = false;
    await tester.pump(const Duration(seconds: 30));
    expect(model.battery?.level, 43);
    model.pause();
  });
}
