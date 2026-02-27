import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Reads current local database bytes.
typedef DatabaseBytesReader = Future<Uint8List> Function();

/// Writes received database bytes to local storage.
typedef DatabaseBytesWriter = Future<void> Function(Uint8List bytes);

/// Callback for peer hello handshake.
typedef PeerHelloHandler = void Function(String host, int port);

/// Callback fired after transfer completion endpoint is hit.
typedef TransferCompleteHandler = void Function();

/// Lightweight HTTP server used for peer-to-peer local database sync.
class LocalSyncServer {
  /// Creates the server with read/write callbacks and optional hooks.
  LocalSyncServer({
    required DatabaseBytesReader readDatabase,
    required DatabaseBytesWriter writeDatabase,
    PeerHelloHandler? onPeerHello,
    TransferCompleteHandler? onTransferComplete,
    int? schemaVersion,
    String? deviceName,
  }) : _readDatabase = readDatabase,
       _writeDatabase = writeDatabase,
       _onPeerHello = onPeerHello,
       _onTransferComplete = onTransferComplete,
       _schemaVersion = schemaVersion,
       _deviceName = deviceName;

  final DatabaseBytesReader _readDatabase;
  final DatabaseBytesWriter _writeDatabase;
  final PeerHelloHandler? _onPeerHello;
  final TransferCompleteHandler? _onTransferComplete;
  final int? _schemaVersion;
  String? _deviceName;
  HttpServer? _server;

  /// Whether server is currently bound and accepting requests.
  bool get isRunning => _server != null;

  /// Active bound port, or null if server is stopped.
  int? get port => _server?.port;

  /// Friendly local device name shared with peers.
  String? get deviceName => _deviceName;

  /// Updates name reported by `/info`.
  set deviceName(String name) {
    _deviceName = name;
  }

  /// Starts HTTP server on [port] (0 means ephemeral port).
  Future<void> start({int port = 0}) async {
    if (_server != null) {
      return;
    }

    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    unawaited(_handleRequests(_server!));
  }

  /// Stops server and closes active socket.
  Future<void> stop() async {
    final server = _server;
    if (server == null) {
      return;
    }
    _server = null;
    await server.close(force: true);
  }

  Future<void> _handleRequests(HttpServer server) async {
    await for (final request in server) {
      final path = request.uri.path;
      if (request.method == 'GET' && path == '/info') {
        _writeJson(request, {
          'ok': true,
          if (_deviceName != null) 'name': _deviceName,
          if (_schemaVersion != null) 'schemaVersion': _schemaVersion,
        });
        continue;
      }

      if (request.method == 'POST' && path == '/hello') {
        try {
          final body = await _collectBytes(request);
          final payload = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
          final host = payload['host'] as String?;
          final portValue = payload['port'];
          final port = portValue is num ? portValue.toInt() : null;
          if (host != null && port != null) {
            _onPeerHello?.call(host, port);
          }
          _writeJson(request, {'ok': true});
        } on Object catch (error) {
          _writeError(request, error.toString());
        }
        continue;
      }

      if (request.method == 'GET' && path == '/db') {
        try {
          final bytes = await _readDatabase();
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType(
            'application',
            'octet-stream',
          );
          request.response.add(bytes);
          await request.response.close();
        } on Object catch (error) {
          _writeError(request, error.toString());
        }
        continue;
      }

      if (request.method == 'POST' && path == '/db') {
        try {
          final bytes = await _collectBytes(request);
          await _writeDatabase(bytes);
          _writeJson(request, {'ok': true});
        } on Object catch (error) {
          _writeError(request, error.toString());
        }
        continue;
      }

      if (request.method == 'POST' && path == '/complete') {
        _onTransferComplete?.call();
        _writeJson(request, {'ok': true});
        continue;
      }

      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    }
  }

  Future<Uint8List> _collectBytes(HttpRequest request) async {
    final completer = Completer<Uint8List>();
    final contents = BytesBuilder();
    request.listen(
      contents.add,
      onDone: () => completer.complete(contents.takeBytes()),
      onError: completer.completeError,
      cancelOnError: true,
    );
    return completer.future;
  }

  void _writeJson(HttpRequest request, Map<String, Object?> payload) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(payload));
    unawaited(request.response.close());
  }

  void _writeError(HttpRequest request, String message) {
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'ok': false, 'error': message}));
    unawaited(request.response.close());
  }
}
