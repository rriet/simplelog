import 'package:flutter_map/flutter_map.dart';

/// Shared lightweight tile cache configuration for flutter_map.
MapCachingProvider appMapCachingProvider() {
  return BuiltInMapCachingProvider.getOrCreateInstance(
    maxCacheSize: 750 * 1024 * 1024,
  );
}
