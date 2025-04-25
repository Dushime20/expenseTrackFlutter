
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../controller/budgetController.dart';

class BudgetPdfGenerator {
  final BudgetController budgetCtrl = Get.find();

  Future<void> generateAndSaveBudgetReport() async {
    await budgetCtrl.fetchBudget();

    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("User Budget Report", style: pw.TextStyle(fontSize: 24)),
          ),
          pw.Table.fromTextArray(
            headers: ['Category ID', 'Amount', 'Start Date', 'End Date'],
            data: budgetCtrl.budgetList.map((budget) {
              return [
                budget['categoryId'] ?? '',
                '${budget['amount']} RWF',
                formatter.format((budget['startDate'] as Timestamp).toDate()),
                formatter.format((budget['endDate'] as Timestamp).toDate()),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/budget_report.pdf");
    await file.writeAsBytes(await pdf.save());

    Get.snackbar("Success", "Budget PDF report saved to ${file.path}");
  }
}
