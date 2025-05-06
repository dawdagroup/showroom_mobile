import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/dynamic_widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../providers/session_provider.dart';
import '../../services/api_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final String documentType;
  final String documentNumber;
  final int printerTypeId;
  final int layoutId;
  final String showroomId;

  const PdfViewerScreen({super.key, required this.documentType, required this.documentNumber, required this.printerTypeId, required this.layoutId, required this.showroomId,});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;
  
  String? localPath;
  bool isLoading = true;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadPdf();
  }

  Future<void> _savePdfOld() async {
    if (localPath == null) {
      dynamicMaster.displayError(context, "Error", "No PDF to save");
      return;
    }

    try {
      // Check and request storage permission
      if (await _requestStoragePermission()) {
        final File originalFile = File(localPath!);
        final directory = await getExternalStorageDirectory();
        final downloadsDir = Directory('${directory?.path}/Download');
        
        // Create directory if it doesn't exist
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final String fileName = '${widget.documentType}_${widget.documentNumber}.pdf';
        final String newPath = '${downloadsDir.path}/$fileName';

        print('Saving PDF to: $newPath');
        
        // Copy file to downloads directory
        await originalFile.copy(newPath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads/$fileName'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      dynamicMaster.displayError(context, "Save Error", e.toString());
    }
  }

  Future<bool> _requestStoragePermissionOld() async {
    // Check if the permission is already granted
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
    return true; // For iOS or other platforms, assume permission is granted
  }

  Future<void> loadPdf() async {
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return;
      }

      final Map<String, dynamic> queryParameters = {
        'documentType': widget.documentType,
        'documentNumber': widget.documentNumber,
        'printer_type_id': widget.printerTypeId.toString(),
        'layout_id': widget.layoutId.toString(),
        'showroom_id': widget.showroomId,
      };

      final response = await apiService.getPrintPreview(token, queryParameters);
      
      if(response["status"] == "success") {
        print(response);
        setState(() {
          localPath = response["file"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["message"];
          isLoading = false;
        });
      }

    } catch (e) {
      setState(() {
        errorMessage = 'Error loading PDF: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _savePdfOld1() async {
    if (localPath == null) {
      dynamicMaster.displayError(context, "Error", "No PDF to save");
      return;
    }

    try {
      // Request storage permission (Android only)
      if (!await _requestStoragePermission()) return;

      // Get platform-specific Downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        dynamicMaster.displayError(context, "Error", "Cannot access Downloads directory");
        return;
      }

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${widget.documentType}_${widget.documentNumber}_$timestamp.pdf';
      final File originalFile = File(localPath!);
      final String newPath = '${downloadsDir.path}/$fileName';

      print('Saving PDF to: $newPath');

      // Validate original file
      if (!await originalFile.exists()) {
        dynamicMaster.displayError(context, "Error", "PDF file not found");
        return;
      }

      // Copy file with error handling
      await originalFile.copy(newPath).then((savedFile) async {
        // Verify file was saved
        if (await savedFile.exists()) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved to Downloads/$fileName'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      dynamicMaster.displayError(
        context, 
        "Save Error", 
        e is FileSystemException 
          ? "Failed to save file: ${e.message}" 
          : e.toString()
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        dynamicMaster.displayError(
          context,
          "Permission Required",
          status.isPermanentlyDenied
            ? "Please enable storage permissions in system settings"
            : "Storage permission is required to save PDFs"
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _savePdf() async {
    if (localPath == null) {
      dynamicMaster.displayError(context, "Error", "No PDF to save");
      return;
    }

    try {
      final File file = File(localPath!);
      if (!await file.exists()) {
        dynamicMaster.displayError(context, "Error", "PDF file not found");
        return;
      }

      final fileName = '${widget.documentType}_${widget.documentNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (Platform.isAndroid) {
        const channel = MethodChannel('com.example.showroom_manager/pdf_saver');
        final result = await channel.invokeMethod('savePdf', {
          'sourcePath': localPath,
          'fileName': fileName,
        });

        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved to Downloads/$fileName')),
          );
        } else {
          dynamicMaster.displayError(context, "Save Failed", "Failed to save PDF");
        }
      } else if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        final savedFile = await file.copy('${dir.path}/$fileName');
        await Share.shareXFiles([XFile(savedFile.path)]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Save Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePdf,
        tooltip: 'Save PDF',
        child: const Icon(Icons.save),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : PDFView(
                  filePath: localPath,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                  onError: (error) {
                    print('PDF Error: $error');
                  },
                  onPageError: (page, error) {
                    print('Error on page $page: $error');
                  },
                ),
    );
  }
}