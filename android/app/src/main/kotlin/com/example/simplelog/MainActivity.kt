package com.example.simplelog

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    companion object {
        private const val fileSaveChannelName = "simplelog/android_file_save"
        private const val saveFileRequestCode = 41021
        private var pendingSaveResult: MethodChannel.Result? = null
        private var pendingSourcePath: String? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            fileSaveChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveFileFromPath" -> handleSaveFileFromPath(call, result)
                "openSavedUri" -> handleOpenSavedUri(call, result)
                else -> result.notImplemented()
            }
        }
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    private fun handleSaveFileFromPath(call: MethodCall, result: MethodChannel.Result) {
        if (pendingSaveResult != null) {
            result.error(
                "save_in_progress",
                "A save operation is already in progress.",
                null
            )
            return
        }

        val sourcePath = call.argument<String>("sourcePath")
        if (sourcePath.isNullOrBlank()) {
            result.error("invalid_args", "sourcePath is required.", null)
            return
        }

        val fileName = call.argument<String>("fileName").orEmpty().ifBlank {
            "SimpleLog-Report.pdf"
        }
        val mimeType = call.argument<String>("mimeType").orEmpty().ifBlank {
            "application/octet-stream"
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }

        pendingSourcePath = sourcePath
        pendingSaveResult = result
        try {
            startActivityForResult(intent, saveFileRequestCode)
        } catch (error: Throwable) {
            pendingSourcePath = null
            pendingSaveResult = null
            result.error("launch_failed", error.message, null)
        }
    }

    private fun handleOpenSavedUri(call: MethodCall, result: MethodChannel.Result) {
        val rawUri = call.argument<String>("uri")
        if (rawUri.isNullOrBlank()) {
            result.error("invalid_args", "uri is required.", null)
            return
        }
        val mimeType = call.argument<String>("mimeType").orEmpty().ifBlank {
            "application/pdf"
        }
        val uri = Uri.parse(rawUri)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            startActivity(intent)
            result.success(true)
        } catch (error: Throwable) {
            result.success(false)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == saveFileRequestCode) {
            handleSaveFileResult(resultCode, data)
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun handleSaveFileResult(resultCode: Int, data: Intent?) {
        val result = pendingSaveResult
        val sourcePath = pendingSourcePath
        pendingSaveResult = null
        pendingSourcePath = null

        if (result == null) {
            return
        }

        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }

        val destinationUri: Uri = data?.data ?: run {
            result.success(null)
            return
        }

        if (sourcePath.isNullOrEmpty()) {
            result.error("missing_source_path", "Source path is missing.", null)
            return
        }

        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) {
            result.error("source_file_missing", "Source file does not exist.", null)
            return
        }

        saveFileInBackground(
            result = result,
            sourceFile = sourceFile,
            destinationUri = destinationUri
        )
    }

    private fun saveFileInBackground(
        result: MethodChannel.Result,
        sourceFile: File,
        destinationUri: Uri
    ) {
        Thread {
            try {
                contentResolver.openOutputStream(destinationUri)?.use { output ->
                    sourceFile.inputStream().use { input ->
                        input.copyTo(output)
                    }
                    output.flush()
                } ?: run {
                    respondWithError(
                        result = result,
                        code = "output_stream_unavailable",
                        message = "Could not open destination output stream."
                    )
                    return@Thread
                }
                respondWithSuccess(result, destinationUri.toString())
            } catch (error: IOException) {
                respondWithError(result, "write_failed", error.message ?: "Save failed.")
            } catch (error: Throwable) {
                respondWithError(result, "write_failed", error.message ?: "Save failed.")
            }
        }.start()
    }

    private fun respondWithSuccess(result: MethodChannel.Result, value: String?) {
        runOnUiThread {
            result.success(value)
        }
    }

    private fun respondWithError(
        result: MethodChannel.Result,
        code: String,
        message: String
    ) {
        runOnUiThread {
            result.error(code, message, null)
        }
    }
}
