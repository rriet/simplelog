# Video Export for Animated Flight Map — Implementation Plan

## Goal
Add a button to the animated flight-map screen that exports the current animation (routes, plane marker, camera motion) as a shareable MP4 file, with deterministic, tile-complete frames — independent of real-time playback jank or network tile-loading delays.

## Context for the agent
- Existing animation engine: single `AnimationController` (0→1) drives `_FlightTimeline`, which maps controller value to active flight + local progress via `entryAt(value)`.
- `_buildPolylines()` / `_buildMarkers()` already render correctly for any given controller value — this is the key building block. Export reuses this exact rendering logic; it does not reimplement it.
- Map: `flutter_map` 8.2.2, OSM raster tiles via `TileLayer`.
- Camera: manual mode = single `fitCamera()`; automatic mode = lerped center/zoom from a look-ahead/look-behind window, currently computed per real-time tick.
- `ffmpeg_kit_flutter` is discontinued/unmaintained — do not add it as a dependency. Use native encoders (MediaCodec/AVAssetWriter) via a maintained wrapper package instead.

## Package decisions
- `flutter_map_tile_caching` (FMTC) — persistent on-disk tile cache + region-based bulk download, keyed by route bounding box.
- `flutter_widget_recorder` — RepaintBoundary-based widget capture → native MP4 encode (H.264), no ffmpeg dependency. Evaluate whether it exposes a lower-level "append frame + timestamp" API for frame-stepped/headless capture; if it only supports real-time recording of a live widget, fall back to a custom platform channel using raw RGBA frames (see Phase 4 fallback).
- Do not add `ffmpeg_kit_flutter` or any of its forks.

## Phase 1 — Tile pre-caching
1. Add `flutter_map_tile_caching`, initialize an FMTC store on app start.
2. Point the existing `TileLayer` at the FMTC-backed tile provider instead of the raw network provider, so normal playback also benefits from caching.
3. Write `Future<void> precacheRouteTiles(FlightRoute route, {required List<double> zoomLevels})`:
   - Compute the union bounding box of all route polylines.
   - For automatic camera mode, also include the bounding boxes of every look-ahead/look-behind window used across the animation (not just the full route extent — zoomed-in windows need their own tile coverage at higher zoom).
   - Call FMTC's `downloadRegion` for that bbox across the needed zoom range.
   - Rate-limit requests (small delay between batches) to stay within OSM's usage policy; make the tile provider/user agent configurable so a different provider (MapTiler/Stadia) can be swapped in later without code changes elsewhere.
4. Add a progress callback surfaced to the UI ("Preparing map data… 40%").

## Phase 2 — Headless capture harness
1. Build a hidden export widget: a second `FlutterMap` instance (not the visible one) wrapped in `RepaintBoundary` with a `GlobalKey`, composited off-screen via `Opacity(0)` (not `Offstage` — `Offstage` skips painting, so `toImage()` would return blank frames) or positioned outside the viewport.
2. This widget takes an explicit `progressValue` (0→1) as a parameter instead of listening to the live `AnimationController` — reuse `entryAt()`, `_buildPolylines()`, `_buildMarkers()` unchanged, just fed a manually-set value per frame.
3. For automatic camera mode, replace the real-time lerp with direct computation of the camera target for a given frame index (same math as `_onAnimTick`, no interpolation/wall-clock dependency).

## Phase 3 — Frame-stepped capture loop
1. Given desired `fps` (default 30) and `duration`, compute `totalFrames`.
2. Loop `i` in `0..totalFrames`:
   - Set `progressValue = i / totalFrames`, `setState`.
   - `await SchedulerBinding.instance.endOfFrame`.
   - Capture: `boundary.toImage(pixelRatio: exportPixelRatio)` → `toByteData(format: ui.ImageByteFormat.rawRgba)`.
   - Hand raw RGBA + timestamp to the encoder (streaming — do not hold all frames in memory).
   - Update export progress UI.
3. Because Phase 1 pre-cached every tile the loop will touch, no tile-load waiting/detection logic is needed inside this loop.

## Phase 4 — Encoding
- Primary: use `flutter_widget_recorder`'s frame-append API if available.
- Fallback: small platform channel per platform:
  - Android: `MediaCodec` (H.264 encoder) + `MediaMuxer`, fed raw RGBA buffers converted to YUV420 as required by the encoder.
  - iOS: `AVAssetWriter` + `AVAssetWriterInputPixelBufferAdaptor`.
- Output: MP4 written to a temp path, returned to Dart side.

## Phase 5 — UI
1. Add an export button next to play/reset in the `AppBar`. Make it a Save disk icon.
2. Tapping it:
   - Show file save location prompt with option for user to change file name/loaction
   - Shows a modal progress screen ("Preparing tiles… / Rendering frames… / Encoding…") — the export loop blocks the UI isolate, so this should be a dedicated non-interactive screen, not a background indicator.
3. Expose export settings the user might want: duration/fps (reuse existing duration picker), resolution/pixelRatio.

## Phase 6 — Testing checklist
- [ ] Automatic-mode export across a route that crosses multiple zoom levels — verify no blank/partial tiles in any frame.
- [ ] Manual-mode export — verify camera stays static at the single `fitCamera()` position as expected.
- [ ] Long routes (many flights) — verify memory stays flat during the frame loop (no frame accumulation).
- [ ] Low-end device — confirm UI doesn't hard-freeze without any progress feedback during export.
- [ ] Verify exported MP4 opens correctly on both iOS and Android share targets.

## Explicitly out of scope (raise separately if needed)
- Audio/music muxing into the exported video (none of the widget-recording packages handle this; would need a separate audio-track mux step or a native screen-recorder-based approach instead).
- Web platform support (FMTC and the native-encoder packages are iOS/Android focused).