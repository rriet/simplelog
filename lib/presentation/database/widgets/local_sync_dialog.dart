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
import 'package:simplelog/data/sync/local_sync_discovery.dart';
import 'package:simplelog/data/sync/local_sync_server.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/database_sync_controller_provider.dart';

const int syncPort = 54742;

class LocalSyncDialog extends ConsumerStatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _startSync();
    _loadLocalInfo();
  }

  @override
  void dispose() {
    _devicesSub?.cancel();
    _scanTimer?.cancel();
    _disconnectTimer?.cancel();
    _discovery?.stop();
    _server?.stop();
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
          setState(() {
            _connectedName = device?.host ?? host;
            _isWaiting = true;
          });
          if (_selected == null && device != null) {
            setState(() => _selected = device);
          }
          _connectedDevice = device ?? DiscoveredDevice(
            name: host,
            host: host,
            port: port,
          );
          _startDisconnectMonitor(_connectedDevice!);
        },
      );
      await _server!.start(port: syncPort);

      _discovery = LocalSyncDiscovery(port: syncPort);
      await _discovery!.start();
      final localName = await _discovery!.localDeviceName;
      _server!.setDeviceName(localName);
      if (mounted) {
        setState(() {
          _localDeviceName = localName;
        });
      }
      _devicesSub = _discovery!.devices.listen((devices) {
        if (!mounted) return;
        for (final device in devices) {
          _devices['${device.host}:${device.port}'] = device;
        }
        setState(() {});
      });

      _startFallbackScan();
    } catch (error) {
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
        _probeHost(host);
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
      includeLoopback: false,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        results.add(address.address);
      }
    }
    return results;
  }

  Future<String> _resolveHost(String host) async {
    final trimmed =
        host.endsWith('.') ? host.substring(0, host.length - 1) : host;
    try {
      final addresses = await InternetAddress.lookup(trimmed);
      final ipv4 = addresses.firstWhere(
        (addr) => addr.type == InternetAddressType.IPv4,
        orElse: () => addresses.first,
      );
      return ipv4.address;
    } catch (_) {
      return trimmed;
    }
  }

  Future<void> _probeHost(String host) async {
    final uri = Uri.parse('http://$host:$syncPort/info');
    try {
      final response =
          await http.get(uri).timeout(const Duration(milliseconds: 500));
      if (response.statusCode == HttpStatus.ok && mounted) {
        final payload = jsonDecode(response.body) as Map<String, dynamic>?;
        final name = payload?['name']?.toString() ?? host;
        setState(() {
          _devices['$host:$syncPort'] = DiscoveredDevice(
            name: name,
            host: host,
            port: syncPort,
          );
        });
      }
    } catch (_) {
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
      includeLoopback: false,
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
    if (_selected == null || _isBusy) return;
    final l10n = AppLocalizations.of(context)!;

    final schemaOk = await _ensureSchemaMatch(_selected!, l10n);
    if (!schemaOk) return;

    final confirm = await _confirmOverwrite(l10n, _selected!.name);
    if (!confirm) return;

    setState(() => _isBusy = true);
    try {
      final host = await _resolveHost(_selected!.host);
      final uri = Uri.parse('http://$host:${_selected!.port}/db');
      final bytes = await _readDatabaseBytes();
      final response = await http.post(uri, body: bytes);
      if (response.statusCode != HttpStatus.ok) {
        throw StateError('Upload failed (${response.statusCode})');
      }
      await _notifyTransferComplete(_selected!);
      if (mounted) {
        await _showSyncComplete(l10n);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _status = error.toString());
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
    final host = await _resolveHost(device.host);
    final uri = Uri.parse('http://$host:${device.port}/hello');
    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'host': selfHost, 'port': syncPort}),
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _handleDeviceTap(DiscoveredDevice device) async {
    setState(() => _selected = device);
    await _sendHelloTo(device);
    if (mounted) {
      setState(() => _connectedName = device.host);
    }
    _connectedDevice = device;
    _startDisconnectMonitor(device);
  }

  Future<String?> _localIp() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip != null && ip.isNotEmpty) return ip;
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        return address.address;
      }
    }
    return null;
  }

  Future<void> _pullFromDevice() async {
    if (_selected == null || _isBusy) return;
    final l10n = AppLocalizations.of(context)!;

    final schemaOk = await _ensureSchemaMatch(_selected!, l10n);
    if (!schemaOk) return;

    final confirm = await _confirmOverwrite(l10n, _selected!.name);
    if (!confirm) return;

    setState(() => _isBusy = true);
    try {
      final host = await _resolveHost(_selected!.host);
      final uri = Uri.parse('http://$host:${_selected!.port}/db');
      final response = await http.get(uri);
      if (response.statusCode != HttpStatus.ok) {
        throw StateError('Download failed (${response.statusCode})');
      }
      await _replaceDatabaseBytes(response.bodyBytes);
      await _notifyTransferComplete(_selected!);
      if (mounted) {
        await _showSyncComplete(l10n);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _status = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<bool> _confirmOverwrite(AppLocalizations l10n, String name) async {
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.databaseSyncSchemaMismatchTitle),
        content: Text(
          l10n.databaseSyncSchemaMismatchMessage(
            localVersion.toString(),
            remoteVersion.toString(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
    return false;
  }

  Future<int?> _fetchRemoteSchemaVersion(DiscoveredDevice device) async {
    try {
      final host = await _resolveHost(device.host);
      final uri = Uri.parse('http://$host:${device.port}/info');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 2));
      if (response.statusCode != HttpStatus.ok) {
        return null;
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>?;
      final value = payload?['schemaVersion'];
      if (value is num) {
        return value.toInt();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _showSyncComplete(AppLocalizations l10n) async {
    if (!mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    await showDialog<void>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: Text(l10n.databaseSyncSuccess),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  void _startDisconnectMonitor(DiscoveredDevice device) {
    _disconnectTimer?.cancel();
    _disconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _connectedDevice != device) return;
      try {
        final host = await _resolveHost(device.host);
        final uri = Uri.parse('http://$host:${device.port}/info');
        await http.get(uri).timeout(const Duration(seconds: 2));
      } catch (_) {
        if (mounted && _connectedDevice == device) {
          _handleDisconnected();
        }
      }
    });
  }

  void _handleDisconnected() {
    _disconnectTimer?.cancel();
    _connectedDevice = null;
    _connectedName = null;
    _isWaiting = false;
    _showDisconnectedDialog();
  }

  Future<void> _showDisconnectedDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    await showDialog<void>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: Text(l10n.databaseSyncDisconnected),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  Future<void> _notifyTransferComplete(DiscoveredDevice device) async {
    try {
      final host = await _resolveHost(device.host);
      final uri = Uri.parse('http://$host:${device.port}/complete');
      await http.post(uri).timeout(const Duration(seconds: 2));
    } catch (_) {
      // ignore
    }
  }

  void _handleTransferComplete() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _showSyncComplete(l10n);
  }

  Future<Uint8List> _readDatabaseBytes() async {
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
    ref.invalidate(databaseProvider);
  }

  Future<String> _databasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/simplelog.sqlite';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final devices = _devices.values
        .where((device) {
          final trimmedHost = device.host.endsWith('.')
              ? device.host.substring(0, device.host.length - 1)
              : device.host;
          final isSelfByName = _localDeviceName != null &&
              device.name == _localDeviceName;
          final isSelfByIp = _localIps.contains(trimmedHost);
          return !isSelfByName && !isSelfByIp;
        })
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

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
              separatorBuilder: (_, __) => const Divider(height: 1),
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
          builder: (context, constraints) {
            final useWrap = constraints.maxWidth < 340;
            if (useWrap) {
              return Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: actionButtons,
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                actionButtons[0],
                const SizedBox(width: 8),
                actionButtons[1],
                const SizedBox(width: 8),
                actionButtons[2],
              ],
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
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelAction),
            ),
          ],
        ),
      ],
    );
  }
}
