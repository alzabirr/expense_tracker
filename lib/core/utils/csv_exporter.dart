import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

abstract final class CsvExporter {
  static Future<void> exportAndShare({
    required List<Expense> expenses,
    required List<Category> categories,
    required String currencySymbol,
  }) async {
    final catMap = {for (final c in categories) c.id: c.name};
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('ID,Date,Title,Type,Category,Amount,PaymentMethod,Merchant,Note');

    for (final e in expenses) {
      final categoryName = _escapeCsv(catMap[e.categoryId] ?? 'Uncategorized');
      final title = _escapeCsv(e.title);
      final merchant = _escapeCsv(e.merchant ?? '');
      final note = _escapeCsv(e.note ?? '');
      final dateStr = dateFmt.format(e.date);

      buffer.writeln(
        '${e.id},$dateStr,"$title",${e.type.name},"$categoryName",${e.amount.toStringAsFixed(2)},${e.paymentMethod.name},"$merchant","$note"',
      );
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/momentum_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Momentum Financial Data Export',
      text: 'Here is your exported financial transaction data from Momentum.',
    );
  }

  static String _escapeCsv(String val) {
    return val.replaceAll('"', '""');
  }
}
