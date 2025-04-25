// expense_pdf_generator.dart
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;


import '../controller/home_controller.dart';

class ExpensePdfGenerator {
  final HomeController homeCtrl = Get.find();

  Future<void> generateAndSaveExpenseReport() async {
    await homeCtrl.fetchExpense(); // Fetch expense data from the controller

    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd'); // Format the DateTime

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("User Expense Report", style: pw.TextStyle(fontSize: 24)),
          ),
          pw.Table.fromTextArray(
            headers: ['ID', 'Description', 'Amount', 'Category ID', 'Date'],
            data: homeCtrl.expense.map((expense) {
              return [
                expense.name ?? '',
                '${expense.amount} RWF',
                expense.categoryId ?? '',
                expense.date != null
                    ? formatter.format(expense.date!) // Safe null check
                    : 'N/A', // Handle null date

              ];
            }).toList(),
          ),
        ],
      ),
    );

    // Saving the PDF document
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/expense_report.pdf");
    await file.writeAsBytes(await pdf.save());

    Get.snackbar("Success", "Expense PDF report saved to ${file.path}");
  }
}
