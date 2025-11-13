package com.example.showroom_manager

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintManager
import android.content.Context
import android.os.ParcelFileDescriptor
import android.print.PageRange
import android.print.PrintDocumentInfo
import android.os.CancellationSignal
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val PDF_SAVER_CHANNEL = "com.example.showroom_manager/pdf_saver"
    private val PRINT_CHANNEL = "com.example.showroom_manager/print"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // PDF Saver Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, 
            PDF_SAVER_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "savePdf" -> {
                    val sourcePath = call.argument<String>("sourcePath")
                    val fileName = call.argument<String>("fileName")
                    if (sourcePath != null && fileName != null) {
                        savePdfToDownloads(sourcePath, fileName, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing parameters", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        // Print Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, 
            PRINT_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "printPdf" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        printPdf(filePath, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing filePath parameter", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun printPdf(filePath: String, result: MethodChannel.Result) {
        try {
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "PDF file not found", null)
                return
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                val printManager = getSystemService(Context.PRINT_SERVICE) as PrintManager
                val printAdapter = PdfPrintDocumentAdapter(file)
                val printAttributes = PrintAttributes.Builder()
                    .setMediaSize(PrintAttributes.MediaSize.ISO_A4)
                    .setResolution(PrintAttributes.Resolution("pdf", "pdf", 600, 600))
                    .setMinMargins(PrintAttributes.Margins.NO_MARGINS)
                    .build()
                
                printManager.print("PDF Document", printAdapter, printAttributes)
                result.success("Print dialog opened")
            } else {
                result.error("UNSUPPORTED", "Printing not supported on this version", null)
            }
        } catch (e: Exception) {
            result.error("PRINT_ERROR", e.message, null)
        }
    }

    private class PdfPrintDocumentAdapter(private val file: File) : PrintDocumentAdapter() {
        override fun onLayout(
            oldAttributes: PrintAttributes?,
            newAttributes: PrintAttributes,
            cancellationSignal: CancellationSignal?,
            callback: LayoutResultCallback,
            extras: android.os.Bundle?
        ) {
            if (cancellationSignal?.isCanceled == true) {
                callback.onLayoutCancelled()
                return
            }

            val info = PrintDocumentInfo.Builder(file.name)
                .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
                .build()

            callback.onLayoutFinished(info, true)
        }

        override fun onWrite(
            pages: Array<out PageRange>?,
            destination: ParcelFileDescriptor,
            cancellationSignal: CancellationSignal?,
            callback: WriteResultCallback
        ) {
            try {
                FileInputStream(file).use { input ->
                    FileOutputStream(destination.fileDescriptor).use { output ->
                        input.copyTo(output)
                    }
                }
                callback.onWriteFinished(arrayOf(PageRange.ALL_PAGES))
            } catch (e: Exception) {
                callback.onWriteFailed(e.message)
            }
        }
    }

    private fun savePdfToDownloads(
        sourcePath: String,
        fileName: String,
        result: MethodChannel.Result
    ) {
        try {
            val context = this.applicationContext
            val sourceFile = File(sourcePath)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // For Android 10+ (API 29+)
                val contentValues = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                    put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }

                val resolver = context.contentResolver
                val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)

                uri?.let {
                    resolver.openOutputStream(uri).use { outputStream ->
                        FileInputStream(sourceFile).use { inputStream ->
                            inputStream.copyTo(outputStream!!)
                        }
                    }
                    contentValues.clear()
                    contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
                    resolver.update(uri, contentValues, null, null)
                    result.success("success")
                } ?: run {
                    result.error("INSERT_FAILED", "Failed to create entry", null)
                }
            } else {
                // For Android 9 and below
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val destFile = File(downloadsDir, fileName)
                sourceFile.copyTo(destFile, overwrite = true)
                result.success("success")
            }
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.message, null)
        }
    }
}