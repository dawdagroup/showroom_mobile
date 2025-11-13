import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../components/dynamic_widgets.dart';

class PdfViewerFromBytesScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;
  final String? complaintNo;

  const PdfViewerFromBytesScreen({
    super.key, 
    required this.pdfBytes, 
    required this.title,
    this.complaintNo,
  });

  @override
  _PdfViewerFromBytesScreenState createState() => _PdfViewerFromBytesScreenState();
}

class _PdfViewerFromBytesScreenState extends State<PdfViewerFromBytesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DynamicMaster dynamicMaster = DynamicMaster();
  
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int? pages = 0;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _createTempFile();
  }

  Future<void> _createTempFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/temp_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(widget.pdfBytes);
      
      setState(() {
        localPath = tempFile.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error creating temp file: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _savePdf() async {
    if (localPath == null) {
      dynamicMaster.displayError(context, "Error", "No PDF to save");
      return;
    }

    try {
      if (await _requestStoragePermission()) {
        final directory = await getExternalStorageDirectory();
        final downloadsDir = Directory('${directory?.path}/Download');
        
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final String fileName = widget.complaintNo != null 
            ? 'complaint_${widget.complaintNo}_${DateTime.now().millisecondsSinceEpoch}.pdf'
            : 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final String newPath = '${downloadsDir.path}/$fileName';

        final File tempFile = File(localPath!);
        await tempFile.copy(newPath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads/$fileName'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      dynamicMaster.displayError(context, "Save Error", e.toString());
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        dynamicMaster.displayError(context, "Permission Denied", "Storage permission is required to save the PDF.");
        return false;
      } else if (status.isPermanentlyDenied) {
        dynamicMaster.displayError(context, "Permission Denied", "Please enable storage permission in app settings.");
        return false;
      }
    }
    return true;
  }

  Future<void> _sharePdf() async {
    if (localPath == null) {
      dynamicMaster.displayError(context, "Error", "No PDF to share");
      return;
    }

    try {
      final XFile file = XFile(localPath!);
      await Share.shareXFiles([file], text: widget.title);
    } catch (e) {
      dynamicMaster.displayError(context, "Share Error", e.toString());
    }
  }

  Future<void> _printPdf() async {
    if (localPath == null) {
      dynamicMaster.displayError(context, "Error", "No PDF to print");
      return;
    }

    try {
      if (Platform.isAndroid) {
        await _printPdfAndroid();
      } else if (Platform.isIOS) {
        await _printPdfIOS();
      } else {
        // For other platforms, offer to share the file
        await _sharePdf();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please use the share option to print on this platform'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Print Error", e.toString());
    }
  }

  Future<void> _printPdfAndroid() async {
    try {
      const platform = MethodChannel('com.example.showroom_manager/print');
      await platform.invokeMethod('printPdf', {'filePath': localPath});
    } catch (e) {
      // Fallback to share if platform channel fails
      await _sharePdf();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening system print dialog...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _printPdfIOS() async {
    try {
      const platform = MethodChannel('com.example.showroom_manager/print');
      await platform.invokeMethod('printPdf', {'filePath': localPath});
    } catch (e) {
      // Fallback to share if platform channel fails
      await _sharePdf();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening system print dialog...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showPrintDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Print Document'),
          content: const Text('Do you want to print this document?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _printPdf();
              },
              child: const Text('Print'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (!isLoading && localPath != null) ...[
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _showPrintDialog,
              tooltip: 'Print PDF',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _savePdf,
              tooltip: 'Download PDF',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePdf,
              tooltip: 'Share PDF',
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading PDF...'),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading PDF',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    PDFView(
                      filePath: localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: 0,
                      fitPolicy: FitPolicy.BOTH,
                      preventLinkNavigation: false,
                      onRender: (_pages) {
                        setState(() {
                          pages = _pages;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = '$error';
                        });
                      },
                    ),
                    if (!isReady)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
      bottomNavigationBar: !isLoading && localPath != null && isReady
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pages != null ? 'Total pages: $pages' : 'Loading...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _showPrintDialog,
                        icon: const Icon(Icons.print),
                        label: const Text('Print'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _savePdf,
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _sharePdf,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    // Clean up temp file
    if (localPath != null) {
      try {
        File(localPath!).delete();
      } catch (e) {
        // Ignore deletion errors
      }
    }
    super.dispose();
  }
}