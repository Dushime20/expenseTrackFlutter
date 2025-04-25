// income_pdf_generator.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../controller/home_controller.dart';

class IncomePdfGenerator {
  final HomeController homeCtrl = Get.find();

  Future<void> generateAndSaveIncomeReport() async {
    await homeCtrl.fetchIncome(); // Fetch income data

    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("User Income Report", style: pw.TextStyle(fontSize: 24)),
          ),
          pw.Table.fromTextArray(
            headers: ['Description', 'Amount', 'Category ID', 'Date'],data: homeCtrl.income.map((income) {
            return [
              income.name ?? '',
              '${income.amount} RWF',
              income.categoryId ?? '',
              income.date != null
                  ? formatter.format(income.date!) // Safe null check
                  : 'N/A', // Handle null date

            ];
          }).toList(),
          ),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/income_report.pdf");
    await file.writeAsBytes(await pdf.save());

    Get.snackbar("Success", "Income PDF report saved to ${file.path}");
  }
}
