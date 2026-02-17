import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:device_info_plus/device_info_plus.dart';

const String kSyncServiceType = '_simplelog._tcp';

class DiscoveredDevice {
  DiscoveredDevice({
    required this.name,
    required this.host,
    required this.port,
  });

  final String name;
  final String host;
  final int port;
}

class LocalSyncDiscovery {
  LocalSyncDiscovery({required int port}) : _port = port;

  final int _port;
  BonsoirDiscovery? _discovery;
  BonsoirBroadcast? _broadcast;
  StreamSubscription<BonsoirDiscoveryEvent>? _subscription;
  final _controller = StreamController<List<DiscoveredDevice>>.broadcast();
  final Map<String, DiscoveredDevice> _devices = {};
  String? _cachedName;

  Stream<List<DiscoveredDevice>> get devices => _controller.stream;
  Future<String> get localDeviceName async {
    _cachedName ??= await _deviceName();
    return _cachedName!;
  }

  Future<void> start() async {
    final service = BonsoirService(
      name: await localDeviceName,
      type: kSyncServiceType,
      port: _port,
      attributes: const {'app': 'simplelog'},
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.ready;
    await _broadcast!.start();

    _discovery = BonsoirDiscovery(type: kSyncServiceType);
    await _discovery!.ready;
    _subscription = _discovery!.eventStream?.listen(_handleDiscoveryEvent);
    await _discovery!.start();
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _discovery?.stop();
    await _broadcast?.stop();
    _devices.clear();
  }

  void _handleDiscoveryEvent(BonsoirDiscoveryEvent event) {
    if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound &&
        event.service != null) {
      _discovery?.serviceResolver.resolveService(event.service!);
      return;
    }

    if (event.type != BonsoirDiscoveryEventType.discoveryServiceResolved) {
      return;
    }
    final service = event.service;
    if (service == null) {
      return;
    }
    if (service is! ResolvedBonsoirService) {
      return;
    }
    final host = service.host;
    if (host == null || host.isEmpty) {
      return;
    }
    final key = '$host:${service.port}';
    _devices[key] = DiscoveredDevice(
      name: service.name,
      host: host,
      port: service.port,
    );
    _controller.add(_devices.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<String> _deviceName() async {
    final info = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final data = await info.iosInfo;
      return data.name;
    }
    if (Platform.isAndroid) {
      final data = await info.androidInfo;
      return data.model;
    }
    if (Platform.isMacOS) {
      final data = await info.macOsInfo;
      return data.computerName;
    }
    if (Platform.isWindows) {
      final data = await info.windowsInfo;
      return data.computerName;
    }
    if (Platform.isLinux) {
      final data = await info.linuxInfo;
      return data.prettyName;
    }
    return 'SimpleLog';
  }

}
