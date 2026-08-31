import 'package:flutter/services.dart';

/// Communicates with the native video encoder via a method channel.
///
/// The native side (Android: MediaCodec + MediaMuxer, iOS: AVAssetWriter)
/// receives raw RGBA frames and encodes them into an H.264 MP4 file.
class VideoEncoderService {
  VideoEncoderService._();

  static const _channel = MethodChannel('simplelog/video_encoder');

  /// Initialises the native encoder with the given dimensions and frame rate.
  /// [outputPath] is the full path where the MP4 will be written.
  static Future<void> initialize({
    required int width,
    required int height,
    required int fps,
    required String outputPath,
  }) async {
    await _channel.invokeMethod<void>('initialize', {
      'width': width,
      'height': height,
      'fps': fps,
      'outputPath': outputPath,
    });
  }

  /// Appends a single RGBA frame with the given presentation timestamp
  /// in milliseconds.
  static Future<void> addFrame({
    required Uint8List rgba,
    required int timestampMs,
  }) async {
    await _channel.invokeMethod<void>('addFrame', {
      'rgba': rgba,
      'timestampMs': timestampMs,
    });
  }

  /// Finalises the encoding and returns the path to the written MP4 file.
  static Future<String> finalize() async {
    final result = await _channel.invokeMethod<String>('finalize');
    return result ?? '';
  }

  /// Cancels an in-progress encode.
  static Future<void> cancel() async {
    await _channel.invokeMethod<void>('cancel');
  }
}
