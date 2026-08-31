import AVFoundation
import Foundation

/// H.264 video encoder backed by AVAssetWriter.
///
/// Accepts raw RGBA frames via `addFrame` and writes an MP4 file
/// when `finish()` is called.
class VideoEncoder {
    private let width: Int
    private let height: Int
    private let fps: Int
    private let outputPath: String

    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var adaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var isSessionStarted = false
    private var frameCount: Int = 0

    init(width: Int, height: Int, fps: Int, outputPath: String) {
        self.width = width
        self.height = height
        self.fps = fps
        self.outputPath = outputPath
    }

    func start() throws {
        let url = URL(fileURLWithPath: outputPath)
        let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)

        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: width * height * 4,
                AVVideoMaxKeyFrameIntervalKey: fps * 2,
            ],
        ]

        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
            ],
        )

        writer.add(input)
        writer.startWriting()

        self.assetWriter = writer
        self.videoInput = input
        self.adaptor = adaptor
    }

    func addFrame(rgba: Data, timestampMs: Int) {
        guard let adaptor = adaptor,
              let input = videoInput,
              let writer = assetWriter else { return }

        if !isSessionStarted {
            let startTime = CMTime(value: CMTimeValue(timestampMs), timescale: 1000)
            writer.startSession(atSourceTime: startTime)
            isSessionStarted = true
        }

        guard let pixelBuffer = createPixelBuffer(from: rgba) else { return }

        let presentationTime = CMTime(value: CMTimeValue(timestampMs), timescale: 1000)

        // Wait until the input is ready to accept more samples.
        while !input.isReadyForMoreMediaData {
            Thread.sleep(forTimeInterval: 0.001)
        }

        adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        frameCount += 1
    }

    func finish() throws {
        guard let input = videoInput, let writer = assetWriter else { return }

        if isSessionStarted {
            input.markAsFinished()
            let group = DispatchGroup()
            group.enter()
            writer.finishWriting {
                group.leave()
            }
            group.wait()
        }

        self.assetWriter = nil
        self.videoInput = nil
        self.adaptor = nil
        isSessionStarted = false
    }

    func cancel() {
        assetWriter?.cancelWriting()
        assetWriter = nil
        videoInput = nil
        adaptor = nil
        isSessionStarted = false
        try? FileManager.default.removeItem(atPath: outputPath)
    }

    // MARK: - Private

    private func createPixelBuffer(from rgba: Data) -> CVPixelBuffer? {
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer,
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let dest = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)

        // Convert RGBA → BGRA (swap R and B channels).
        rgba.withUnsafeBytes { srcPtr in
            let src = srcPtr.bindMemory(to: UInt8.self).baseAddress!
            let dst = dest.assumingMemoryBound(to: UInt8.self)
            let rowBytes = width * 4
            for y in 0..<height {
                let srcRow = src + y * rowBytes
                let dstRow = dst + y * bytesPerRow
                for x in 0..<width {
                    let si = x * 4
                    let di = x * 4
                    dstRow[di] = srcRow[si + 2]     // B
                    dstRow[di + 1] = srcRow[si + 1] // G
                    dstRow[di + 2] = srcRow[si]     // R
                    dstRow[di + 3] = srcRow[si + 3] // A
                }
            }
        }

        return buffer
    }
}
