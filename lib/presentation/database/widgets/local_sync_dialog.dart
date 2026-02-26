import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/sync/local_sync_discovery.dart';
import 'package:simplelog/data/sync/local_sync_server.dart';
import 'package:simplelog/presentation/reports/providers/reports_preferences_provider.dart';
import 'package:simplelog/presentation/shared/widgets/app_message_dialog.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/database_sync_controller_provider.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';

/// TCP port used for local peer‑to‑peer sync.
const int syncPort = 54742;

/// Dialog that discovers peers and sends/receives database snapshots over LAN.
class LocalSyncDialog extends ConsumerStatefulWidget {
  /// Public API documentation.
  const LocalSyncDialog({super.key});

  @override
  ConsumerState<LocalSyncDialog> createState() => _LocalSyncDialogState();
}

class _LocalSyncDialogState extends ConsumerState<LocalSyncDialog> {
  LocalSyncServer? _server;
  LocalSyncDiscovery? _discovery;
  Timer? _scanTimer;
  Timer? _disconnectTimer;
  StreamSubscription<List<DiscoveredDevice>>? _devicesSub;
  final Map<String, DiscoveredDevice> _devices = {};
  DiscoveredDevice? _selected;
  String? _connectedName;
  DiscoveredDevice? _connectedDevice;
  bool _isBusy = false;
  String? _status;
  String? _localDeviceName;
  Set<String> _localIps = {};
  bool _isWaiting = false;
  int? _schemaVersion;
  int _disconnectFailures = 0;
  bool _disconnectProbeInFlight = false;
  final Map<String, String> _resolvedHostCache = {};

  @override
  void initState() {
    super.initState();
    unawaited(_startSync());
    unawaited(_loadLocalInfo());
  }

  @override
  void dispose() {
    unawaited(_devicesSub?.cancel());
    _scanTimer?.cancel();
    _disconnectTimer?.cancel();
    unawaited(_discovery?.stop());
    unawaited(_server?.stop());
    super.dispose();
  }

  Future<void> _startSync() async {
    setState(() {
      _isBusy = true;
      _status = null;
    });

    try {
      final controller = ref.read(databaseSyncControllerProvider.notifier);
      _schemaVersion = controller.schemaVersion();
      _server = LocalSyncServer(
        readDatabase: _readDatabaseBytes,
        writeDatabase: _replaceDatabaseBytes,
        onTransferComplete: _handleTransferComplete,
        schemaVersion: _schemaVersion,
        onPeerHello: (host, port) {
          if (!mounted) return;
          final key = '$host:$port';
          final device = _devices[key];
          final candidate =
              _selected ??
              device ??
              DiscoveredDevice(
                name: host,
                host: host,
                port: port,
              );
          setState(() {
            _connectedName = device?.name ?? candidate.name;
            _isWaiting = true;
          });
          if (_selected == null && device != null) {
            setState(() => _selected = device);
          }
          _connectedDevice = candidate;
          _startDisconnectMonitor(candidate);
        },
      );
      await _server!.start(port: syncPort);

      _discovery = LocalSyncDiscovery(port: syncPort);
      await _discovery!.start();
      final localName = await _discovery!.localDeviceName;
      _server!.deviceName = localName;
      if (mounted) {
        setState(() {
          _localDeviceName = localName;
        });
      }
      _devicesSub = _discovery!.devices.listen((devices) {
        unawaited(_mergeDiscoveredDevices(devices));
      });

      await _startFallbackScan();
    } on Object catch (error) {
      setState(() => _status = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _startFallbackScan() async {
    final prefix = await _localPrefix();
    if (prefix == null) return;

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      for (var i = 1; i <= 254; i++) {
        final host = '$prefix$i';
        if (_devices.containsKey('$host:$syncPort')) continue;
        unawaited(_probeHost(host));
      }
    });
  }

  Future<void> _loadLocalInfo() async {
    final name = await _discovery?.localDeviceName ?? 'SimpleLog';
    final ips = await _localIpAddresses();
    if (!mounted) return;
    setState(() {
      _localDeviceName = name;
      _localIps = ips.toSet();
    });
  }

  Future<List<String>> _localIpAddresses() async {
    final info = NetworkInfo();
    final wifiIp = await info.getWifiIP();
    final results = <String>[];
    if (wifiIp != null && wifiIp.isNotEmpty) {
      results.add(wifiIp);
    }
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        results.add(address.address);
      }
    }
    return results;
  }

  Future<String> _resolveHost(String host) async {
    final trimmed = host.endsWith('.')
        ? host.substring(0, host.length - 1)
        : host;
    final literalAddress = InternetAddress.tryParse(trimmed);
    if (literalAddress != null) {
      return literalAddress.address;
    }
    try {
      final addresses = await InternetAddress.lookup(trimmed);
      final ipv4 = addresses.firstWhere(
        (addr) => addr.type == InternetAddressType.IPv4,
        orElse: () => addresses.first,
      );
      return ipv4.address;
    } on Object catch (_) {
      return trimmed;
    }
  }

  Future<String> _resolveHostCached(String host) async {
    final cached = _resolvedHostCache[host];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final resolved = await _resolveHost(host);
    _resolvedHostCache[host] = resolved;
    return resolved;
  }

  Future<void> _mergeDiscoveredDevices(List<DiscoveredDevice> devices) async {
    if (!mounted) return;
    final next = Map<String, DiscoveredDevice>.from(_devices);
    for (final device in devices) {
      final resolvedHost = await _resolveHostCached(device.host);
      if (_isSelfDevice(device, resolvedHost: resolvedHost)) {
        continue;
      }
      final key = '$resolvedHost:${device.port}';
      final existing = next[key];
      final sameNameKey = next.entries
          .where((entry) {
            return entry.value.port == device.port &&
                entry.value.name.toLowerCase() == device.name.toLowerCase();
          })
          .map((entry) => entry.key)
          .firstOrNull;
      if (sameNameKey != null && sameNameKey != key) {
        final existingByName = next[sameNameKey]!;
        final keepExisting =
            _isIpv4Literal(existingByName.host) &&
            !_isIpv4Literal(resolvedHost);
        if (keepExisting) {
          continue;
        }
        next.remove(sameNameKey);
      }
      if (existing == null || existing.host.endsWith('.local')) {
        next[key] = DiscoveredDevice(
          name: device.name,
          host: resolvedHost,
          port: device.port,
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _devices
        ..clear()
        ..addAll(next);
    });
  }

  bool _isSelfDevice(DiscoveredDevice device, {String? resolvedHost}) {
    final trimmedHost = device.host.endsWith('.')
        ? device.host.substring(0, device.host.length - 1)
        : device.host;
    final host = resolvedHost ?? trimmedHost;
    final normalizedLocalName = _normalizedServiceName(_localDeviceName ?? '');
    final isSelfByName =
        _localDeviceName != null &&
        (device.name == _localDeviceName ||
            device.name == normalizedLocalName);
    final isSelfByIp =
        _localIps.contains(trimmedHost) || _localIps.contains(host);
    return isSelfByName || isSelfByIp;
  }

  bool _isIpv4Literal(String host) =>
      RegExp(r'^\d{1,3}(?:\.\d{1,3}){3}$').hasMatch(host);

  String _normalizedServiceName(String raw) {
    final normalized = raw
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) {
      return 'SimpleLog';
    }
    return normalized.length > 63 ? normalized.substring(0, 63) : normalized;
  }

  Future<void> _probeHost(String host) async {
    final uri = Uri.parse('http://$host:$syncPort/info');
    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(milliseconds: 500));
      if (response.statusCode == HttpStatus.ok && mounted) {
        final payload = jsonDecode(response.body) as Map<String, dynamic>?;
        final name = payload?['name']?.toString() ?? host;
        await _mergeDiscoveredDevices([
          DiscoveredDevice(
            name: name,
            host: host,
            port: syncPort,
          ),
        ]);
      }
    } on Object catch (_) {
      // ignore
    }
  }

  Future<String?> _localPrefix() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip != null && ip.isNotEmpty) {
      final parts = ip.split('.');
      if (parts.length >= 3) {
        return '${parts[0]}.${parts[1]}.${parts[2]}.';
      }
    }
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final value = address.address;
        if (value.isNotEmpty) {
          final parts = value.split('.');
          if (parts.length >= 3) {
            return '${parts[0]}.${parts[1]}.${parts[2]}.';
          }
        }
      }
    }
    return null;
  }

  Future<void> _sendToDevice() async {
    _selected ??= _connectedDevice;
    if (_selected == null || _isBusy) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final target = _selected!;

    final reachable = await _probeDeviceReachability(target);
    if (!mounted) return;
    if (!reachable) {
      setState(() {
        _status =
            'Device ${target.name} is no longer reachable. '
            'Reopen Local Sync on that device and reconnect.';
        _isWaiting = false;
        _connectedDevice = null;
        _connectedName = null;
      });
      return;
    }

    final schemaOk = await _ensureSchemaMatch(target, l10n);
    if (!mounted) return;
    if (!schemaOk) return;

    final confirm = await _confirmOverwrite(l10n, target.name);
    if (!mounted) return;
    if (!confirm) return;

    setState(() {
      _isBusy = true;
      _status = 'Transferring database...';
    });
    try {
      final bytes = await _readDatabaseBytes();
      final response = await _postToDevice(
        target,
        '/db',
        body: bytes,
        timeout: const Duration(minutes: 2),
      );
      if (response.statusCode != HttpStatus.ok) {
        throw StateError('Upload failed (${response.statusCode})');
      }
      await _notifyTransferComplete(target);
      if (mounted) {
        setState(() => _status = null);
        await _showSyncComplete(l10n);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _status = _friendlySyncError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _sendHelloTo(DiscoveredDevice device) async {
    final selfHost = await _localIp();
    if (selfHost == null) return;
    try {
      await _postToDevice(
        device,
        '/hello',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'host': selfHost, 'port': syncPort}),
      );
    } on Object catch (_) {
      // ignore
    }
  }

  Future<void> _handleDeviceTap(DiscoveredDevice device) async {
    setState(() {
      _selected = device;
      _status = null;
    });
    final reachable = await _probeDeviceReachability(device);
    if (!mounted) return;
    if (!reachable) {
      setState(() {
        _status =
            'Cannot verify ${device.host}:${device.port} yet. '
            'You can still try Pull/Send. Keep Local Sync open on the other '
            'device and use the same Wi-Fi.';
      });
    }
    await _sendHelloTo(device);
    if (!mounted) return;
    setState(() {
      _connectedName = device.name;
      _isWaiting = true;
    });
    _connectedDevice = device;
    _startDisconnectMonitor(device);
  }

  Future<bool> _probeDeviceReachability(DiscoveredDevice device) async {
    try {
      final response = await _getFromDevice(device, '/info');
      return response.statusCode == HttpStatus.ok;
    } on Object catch (_) {
      return false;
    }
  }

  Future<String?> _localIp() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip != null && ip.isNotEmpty) return ip;
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        return address.address;
      }
    }
    return null;
  }

  Future<void> _pullFromDevice() async {
    _selected ??= _connectedDevice;
    if (_selected == null || _isBusy) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final target = _selected!;

    final reachable = await _probeDeviceReachability(target);
    if (!mounted) return;
    if (!reachable) {
      setState(() {
        _status =
            'Device ${target.name} is no longer reachable. '
            'Reopen Local Sync on that device and reconnect.';
        _isWaiting = false;
        _connectedDevice = null;
        _connectedName = null;
      });
      return;
    }

    final schemaOk = await _ensureSchemaMatch(target, l10n);
    if (!mounted) return;
    if (!schemaOk) return;

    final localName =
        _localDeviceName ?? await _discovery?.localDeviceName ?? 'SimpleLog';
    final confirm = await _confirmOverwrite(l10n, localName);
    if (!mounted) return;
    if (!confirm) return;

    setState(() {
      _isBusy = true;
      _status = 'Transferring database...';
    });
    try {
      final response = await _getFromDevice(
        target,
        '/db',
        timeout: const Duration(minutes: 2),
      );
      if (response.statusCode != HttpStatus.ok) {
        throw StateError('Download failed (${response.statusCode})');
      }
      await _replaceDatabaseBytes(response.bodyBytes);
      await _notifyTransferComplete(target);
      if (mounted) {
        setState(() => _status = null);
        await _showSyncComplete(l10n);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _status = _friendlySyncError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<bool> _confirmOverwrite(AppLocalizations l10n, String name) async {
    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.databaseSyncConfirmTitle),
        content: Text(l10n.databaseSyncConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.databaseSyncConfirmAction),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<bool> _ensureSchemaMatch(
    DiscoveredDevice device,
    AppLocalizations l10n,
  ) async {
    final localVersion = _schemaVersion;
    if (localVersion == null) {
      return true;
    }
    final remoteVersion = await _fetchRemoteSchemaVersion(device);
    if (remoteVersion == null) {
      return true;
    }
    if (remoteVersion == localVersion) {
      return true;
    }
    if (!mounted) {
      return false;
    }
    await showAppMessageDialog(
      context,
      title: l10n.databaseSyncSchemaMismatchTitle,
      message: l10n.databaseSyncSchemaMismatchMessage(
        localVersion.toString(),
        remoteVersion.toString(),
      ),
      okLabel: l10n.okAction,
    );
    return false;
  }

  Future<int?> _fetchRemoteSchemaVersion(DiscoveredDevice device) async {
    try {
      final response = await _getFromDevice(device, '/info');
      if (response.statusCode != HttpStatus.ok) {
        return null;
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>?;
      final value = payload?['schemaVersion'];
      if (value is num) {
        return value.toInt();
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> _showSyncComplete(AppLocalizations l10n) async {
    if (!mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    await showAppMessageDialog(
      navigator.context,
      title: l10n.databaseSyncSuccess,
      okLabel: l10n.okAction,
    );
  }

  void _startDisconnectMonitor(DiscoveredDevice device) {
    _disconnectTimer?.cancel();
    _disconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _connectedDevice != device || _isBusy) return;
      if (_disconnectProbeInFlight) return;
      _disconnectProbeInFlight = true;
      try {
        await _getFromDevice(
          device,
          '/info',
          timeout: const Duration(seconds: 2),
        );
        _disconnectFailures = 0;
      } on Object catch (_) {
        _disconnectFailures += 1;
        if (mounted && _connectedDevice == device && _disconnectFailures >= 3) {
          _handleDisconnected();
        }
      } finally {
        _disconnectProbeInFlight = false;
      }
    });
  }

  void _handleDisconnected() {
    if (!mounted) return;
    _disconnectTimer?.cancel();
    _connectedDevice = null;
    _connectedName = null;
    _isWaiting = false;
    unawaited(_showDisconnectedDialog());
  }

  Future<void> _showDisconnectedDialog() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    await showAppMessageDialog(
      navigator.context,
      title: l10n.databaseSyncDisconnected,
      okLabel: l10n.okAction,
    );
  }

  Future<void> _notifyTransferComplete(DiscoveredDevice device) async {
    try {
      await _postToDevice(device, '/complete');
    } on Object catch (_) {
      // ignore
    }
  }

  Future<http.Response> _getFromDevice(
    DiscoveredDevice device,
    String path, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    Object? lastError;
    for (final host in await _hostCandidates(device)) {
      final uri = Uri.parse('http://$host:${device.port}$path');
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          return await http.get(uri).timeout(timeout);
        } on Object catch (error) {
          lastError = error;
        }
      }
    }
    throw StateError(lastError?.toString() ?? 'Unable to reach ${device.host}');
  }

  Future<http.Response> _postToDevice(
    DiscoveredDevice device,
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    Object? lastError;
    for (final host in await _hostCandidates(device)) {
      final uri = Uri.parse('http://$host:${device.port}$path');
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          return await http
              .post(uri, body: body, headers: headers)
              .timeout(timeout);
        } on Object catch (error) {
          lastError = error;
        }
      }
    }
    throw StateError(lastError?.toString() ?? 'Unable to reach ${device.host}');
  }

  Future<List<String>> _hostCandidates(DiscoveredDevice device) async {
    final raw = device.host.endsWith('.')
        ? device.host.substring(0, device.host.length - 1)
        : device.host;
    final resolved = await _resolveHost(raw);
    if (resolved == raw) {
      return [raw];
    }
    return [raw, resolved];
  }

  String _friendlySyncError(Object error) {
    final text = error.toString();
    if (text.contains('Connection refused')) {
      return 'Connection refused by the other device. '
          'Keep Local Sync open on both devices and try reconnecting.';
    }
    if (text.contains('timed out') || text.contains('TimeoutException')) {
      return 'Connection timed out. Verify both devices are on the same Wi-Fi.';
    }
    return text;
  }

  void _handleTransferComplete() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    unawaited(_showSyncComplete(l10n));
  }

  Future<Uint8List> _readDatabaseBytes() async {
    // Flush WAL changes into the main sqlite file before reading bytes.
    final db = ref.read(databaseProvider);
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final path = await _databasePath();
    final file = File(path);
    return file.readAsBytes();
  }

  Future<void> _replaceDatabaseBytes(Uint8List bytes) async {
    final db = ref.read(databaseProvider);
    await db.close();
    final path = await _databasePath();
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    ref
      ..invalidate(databaseProvider)
      ..invalidate(flightFactoringSettingsProvider)
      ..invalidate(reportPilotInfoProvider);
  }

  Future<String> _databasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final currentPath = '${dir.path}/$appDatabaseFileName.sqlite';
    final legacyPath = '${dir.path}/simplelog.sqlite';
    if (File(currentPath).existsSync()) {
      return currentPath;
    }
    if (File(legacyPath).existsSync()) {
      return legacyPath;
    }
    return currentPath;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final devices = _devices.values.where((device) {
      final trimmedHost = device.host.endsWith('.')
          ? device.host.substring(0, device.host.length - 1)
          : device.host;
      final isSelfByName =
          _localDeviceName != null && device.name == _localDeviceName;
      final isSelfByIp = _localIps.contains(trimmedHost);
      return !isSelfByName && !isSelfByIp;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));

    return Dialog(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          final width = maxWidth.clamp(0, 520);
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: width.toDouble(),
                child: _isWaiting
                    ? _buildWaitingView(context, l10n)
                    : _buildDiscoveryView(context, l10n, devices),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscoveryView(
    BuildContext context,
    AppLocalizations l10n,
    List<DiscoveredDevice> devices,
  ) {
    final actionButtons = [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(l10n.cancelAction),
      ),
      OutlinedButton(
        onPressed: (_selected == null || _isBusy) ? null : _pullFromDevice,
        child: Text(l10n.databaseSyncPullAction),
      ),
      FilledButton(
        onPressed: (_selected == null || _isBusy) ? null : _sendToDevice,
        child: Text(l10n.databaseSyncSendAction),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.databaseSyncFoundTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_isBusy) const LinearProgressIndicator(),
        if (devices.isEmpty)
          Text(l10n.databaseSyncSearching)
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: devices.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final device = devices[index];
                final selected = _selected == device;
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text('${device.host}:${device.port}'),
                  selected: selected,
                  onTap: () => _handleDeviceTap(device),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, _) {
            return Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: actionButtons,
            );
          },
        ),
        if (_status != null) ...[
          const SizedBox(height: 8),
          Text(_status!),
        ],
      ],
    );
  }

  Widget _buildWaitingView(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.databaseSyncConnected(_connectedName ?? '-'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(l10n.databaseSyncWaiting),
        if (_isBusy) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: (_connectedDevice == null || _isBusy)
                  ? null
                  : _pullFromDevice,
              child: Text(l10n.databaseSyncPullAction),
            ),
            FilledButton(
              onPressed: (_connectedDevice == null || _isBusy)
                  ? null
                  : _sendToDevice,
              child: Text(l10n.databaseSyncSendAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelAction),
            ),
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: 8),
          Text(_status!),
        ],
      ],
    );
  }
}
