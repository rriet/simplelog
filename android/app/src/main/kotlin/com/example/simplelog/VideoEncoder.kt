package com.example.simplelog

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import java.io.File
import java.nio.ByteBuffer

/**
 * H.264 video encoder backed by [MediaCodec] and [MediaMuxer].
 *
 * Accepts raw RGBA frames via [addFrame] and writes an MP4 file
 * when [finish] is called.
 */
class VideoEncoder(
    private val width: Int,
    private val height: Int,
    private val fps: Int,
    private val outputPath: String,
) {
    private var codec: MediaCodec? = null
    private var muxer: MediaMuxer? = null
    private var trackIndex = -1
    private var muxerStarted = false
    private var frameCount = 0

    fun start() {
        val format = MediaFormat.createVideoFormat(
            MediaFormat.MIMETYPE_VIDEO_AVC,
            width,
            height,
        ).apply {
            setInteger(
                MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar,
            )
            setInteger(MediaFormat.KEY_BIT_RATE, width * height * 4)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 2)
        }

        codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC).apply {
            configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            start()
        }

        val file = File(outputPath)
        file.parentFile?.mkdirs()
        muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
    }

    fun addFrame(rgba: ByteArray, timestampMs: Long) {
        val encoder = codec ?: return
        val mux = muxer ?: return

        // Dequeue an available input buffer.
        val inputIndex = encoder.dequeueInputBuffer(10_000)
        if (inputIndex < 0) return

        val inputBuffer = encoder.getInputBuffer(inputIndex) ?: return

        // Convert RGBA → NV12 (YUV420 semi-planar) and write to input buffer.
        val nv12 = rgbaToNv12(rgba, width, height)
        inputBuffer.clear()
        inputBuffer.put(nv12)

        val presentationTimeUs = timestampMs * 1000
        encoder.queueInputBuffer(
            inputIndex,
            0,
            nv12.size,
            presentationTimeUs,
            0,
        )

        // Drain available output buffers.
        drainEncoder(encoder, mux, false)
        frameCount++
    }

    fun finish() {
        val encoder = codec ?: return
        val mux = muxer ?: return

        // Signal end-of-stream.
        val inputIndex = encoder.dequeueInputBuffer(10_000)
        if (inputIndex >= 0) {
            encoder.queueInputBuffer(
                inputIndex,
                0,
                0,
                0,
                MediaCodec.BUFFER_FLAG_END_OF_STREAM,
            )
        }
        drainEncoder(encoder, mux, true)

        try {
            codec?.stop()
            codec?.release()
        } catch (_: Exception) {}

        if (muxerStarted) {
            try {
                mux.stop()
                mux.release()
            } catch (_: Exception) {}
        }

        codec = null
        muxer = null
    }

    fun cancel() {
        try {
            codec?.stop()
            codec?.release()
        } catch (_: Exception) {}
        try {
            if (muxerStarted) {
                muxer?.stop()
            }
            muxer?.release()
        } catch (_: Exception) {}
        // Delete partial output.
        try {
            File(outputPath).delete()
        } catch (_: Exception) {}

        codec = null
        muxer = null
    }

    private fun drainEncoder(
        encoder: MediaCodec,
        mux: MediaMuxer,
        endOfStream: Boolean,
    ) {
        val bufferInfo = MediaCodec.BufferInfo()
        while (true) {
            val outputIndex = encoder.dequeueOutputBuffer(bufferInfo, 10_000)
            if (outputIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
                if (!endOfStream) break
                continue
            }
            if (outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                if (!muxerStarted) {
                    trackIndex = mux.addTrack(encoder.outputFormat)
                    mux.start()
                    muxerStarted = true
                }
                continue
            }
            if (outputIndex < 0) continue

            val outputBuffer = encoder.getOutputBuffer(outputIndex) ?: continue
            if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                bufferInfo.size = 0
            }
            if (bufferInfo.size > 0 && muxerStarted) {
                outputBuffer.position(bufferInfo.offset)
                outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                mux.writeSampleData(trackIndex, outputBuffer, bufferInfo)
            }
            encoder.releaseOutputBuffer(outputIndex, false)
            if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
        }
    }

    companion object {
        /**
         * Converts RGBA byte array to NV12 (YUV420 semi-planar).
         */
        fun rgbaToNv12(rgba: ByteArray, w: Int, h: Int): ByteArray {
            val frameSize = w * h
            val nv12 = ByteArray(frameSize * 3 / 2)
            var yIndex = 0
            var uvIndex = frameSize

            for (j in 0 until h) {
                for (i in 0 until w) {
                    val srcIndex = (j * w + i) * 4
                    val r = rgba[srcIndex].toInt() and 0xFF
                    val g = rgba[srcIndex + 1].toInt() and 0xFF
                    val b = rgba[srcIndex + 2].toInt() and 0xFF

                    val y = ((66 * r + 129 * g + 25 * b + 128) shr 8) + 16
                    nv12[yIndex++] = y.coerceIn(0, 255).toByte()

                    if (j % 2 == 0 && i % 2 == 0) {
                        val u = ((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128
                        val v = ((112 * r - 94 * g - 18 * b + 128) shr 8) + 128
                        nv12[uvIndex++] = u.coerceIn(0, 255).toByte()
                        nv12[uvIndex++] = v.coerceIn(0, 255).toByte()
                    }
                }
            }
            return nv12
        }
    }
}
