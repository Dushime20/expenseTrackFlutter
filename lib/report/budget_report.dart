import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../controller/budgetController.dart';

class BudgetPdfGenerator {
  final BudgetController budgetCtrl = Get.find();

  void _log(String title, String message, {bool isError = false}) {
    print("${isError ? 'ERROR' : 'INFO'} - $title: $message");
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red.withOpacity(0.8) : Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: isError ? 5 : 3),
    );
  }

  Future<void> generateAndSaveBudgetReport() async {
    try {
      print("Starting PDF generation...");
      await budgetCtrl.fetchBudget();

      final pdf = await _createPdfDocument();
      final bytes = await pdf.save();

      if (Platform.isAndroid) {
        // Request permissions based on Android version
        if (await _requestStoragePermission()) {
          bool saved = await _saveToDownloads(bytes);
          if (!saved) throw Exception("Failed to save PDF to Downloads");
        } else {
          _log("Permission Denied", "Storage permission is required to save the PDF.", isError: true);
        }
      } else {
        _log("Unsupported Platform", "This PDF generation is intended for Android only.", isError: true);
      }
    } catch (e) {
      _log("Error", "Failed to generate PDF: ${e.toString()}", isError: true);
    }
  }

  Future<pw.Document> _createPdfDocument() async {
    final fontData = await rootBundle.load("assets/font/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("User Monthly Budget Report", style: pw.TextStyle(font: ttf, fontSize: 24)),
          ),
          pw.Table.fromTextArray(
            headers: [ 'Amount', 'Start Date', 'End Date'],
            data: budgetCtrl.budgetList.map((budget) {
              return [

                '${budget['amount']} RWF',
                formatter.format((budget['startDate'] as Timestamp).toDate()),
                formatter.format((budget['endDate'] as Timestamp).toDate()),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(font: ttf),
          ),
        ],
      ),
    );

    return pdf;
  }

  Future<bool> _saveToDownloads(List<int> bytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "budget_report_$timestamp.pdf";
      final directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        _log("Error", "Download directory does not exist", isError: true);
        return false;
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      _log("Success", "PDF saved to Downloads: ${file.path}");
      return true;
    } catch (e) {
      _log("Error", "Failed to save to Downloads: ${e.toString()}", isError: true);
      return false;
    }
  }

  Future<bool> _requestStoragePermission() async {
    // Check if permissions are granted or need requesting
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // For Android 10+ (API 29) and below
    if (await Permission.storage.isGranted) {
      return true;
    }

    // For Android 11+ (API 30), request the special permission
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }

    // If permission is not granted, show an error
    _log("Permission Denied", "Storage permission is required to save the PDF.", isError: true);
    return false;
  }
}
