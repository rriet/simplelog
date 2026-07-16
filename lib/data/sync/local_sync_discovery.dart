import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// mDNS/Bonjour service type used for SimpleLog local sync discovery.
const String kSyncServiceType = '_simplelog._tcp';

/// Device discovered on local network and available for sync.
class DiscoveredDevice {
  /// Creates a discovered device entry.
  DiscoveredDevice({
    required this.name,
    required this.host,
    required this.port,
  });

  /// Human-readable device name.
  final String name;

  /// IP/host announced by Bonjour.
  final String host;

  /// HTTP port exposed by peer sync server.
  final int port;
}

/// Handles Bonjour broadcast and peer discovery for local sync.
class LocalSyncDiscovery {
  /// Creates discovery service bound to local server [port].
  LocalSyncDiscovery({required int port}) : _port = port;

  final int _port;
  BonsoirDiscovery? _discovery;
  BonsoirBroadcast? _broadcast;
  StreamSubscription<BonsoirDiscoveryEvent>? _subscription;
  final _controller = StreamController<List<DiscoveredDevice>>.broadcast();
  final Map<String, DiscoveredDevice> _devices = {};
  String? _cachedName;

  /// Stream of discovered peers sorted by display name.
  Stream<List<DiscoveredDevice>> get devices => _controller.stream;

  /// Returns and caches local device display name.
  Future<String> get localDeviceName async {
    _cachedName ??= await _deviceName();
    return _cachedName!;
  }

  /// Starts broadcasting this device and scanning for peers.
  Future<void> start() async {
    final serviceName = _sanitizeServiceName(await localDeviceName);
    final service = BonsoirService(
      name: serviceName,
      type: kSyncServiceType,
      port: _port,
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();

    _discovery = BonsoirDiscovery(type: kSyncServiceType);
    await _discovery!.initialize();
    _subscription = _discovery!.eventStream?.listen(_handleDiscoveryEvent);
    await _discovery!.start();
  }

  /// Stops broadcasting/discovery and clears in-memory peer cache.
  Future<void> stop() async {
    await _subscription?.cancel();
    await _discovery?.stop();
    await _broadcast?.stop();
    _devices.clear();
  }

  void _handleDiscoveryEvent(BonsoirDiscoveryEvent event) {
    if (event is BonsoirDiscoveryServiceLostEvent) {
      final lostName = event.service.name;
      _devices.removeWhere((_, value) => value.name == lostName);
      _controller.add(
        _devices.values.toList()..sort((a, b) => a.name.compareTo(b.name)),
      );
      return;
    }

    if (event is BonsoirDiscoveryServiceFoundEvent) {
      final resolving = _discovery?.serviceResolver.resolveService(
        event.service,
      );
      if (resolving is Future<void>) {
        unawaited(resolving);
      }
      return;
    }

    if (event is BonsoirDiscoveryServiceResolvedEvent) {
      _upsertResolvedService(event.service);
      return;
    }
    if (event is BonsoirDiscoveryServiceUpdatedEvent) {
      _upsertResolvedService(event.service);
      return;
    }
  }

  void _upsertResolvedService(BonsoirService service) {
    final host = service.hostAddress ?? service.hostname;
    if (host == null || host.isEmpty) {
      return;
    }
    final key = '$host:${service.port}';
    _devices[key] = DiscoveredDevice(
      name: service.name,
      host: host,
      port: service.port,
    );
    _controller.add(
      _devices.values.toList()..sort((a, b) => a.name.compareTo(b.name)),
    );
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

  String _sanitizeServiceName(String raw) {
    final normalized = raw
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final fallback = normalized.isEmpty ? 'SimpleLog' : normalized;
    final clipped = fallback.length > 63 ? fallback.substring(0, 63) : fallback;
    return clipped;
  }
}
