import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/expense/data/models/expense_isar_model.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

class ImportResult {
  const ImportResult({
    required this.importedCount,
    this.failedCount = 0,
    this.errorMessage,
    this.cancelled = false,
  });

  final int importedCount;
  final int failedCount;
  final String? errorMessage;
  final bool cancelled;

  bool get isSuccess => errorMessage == null && !cancelled && importedCount > 0;
}

abstract final class DataImporter {
  static const _uuid = Uuid();

  static const String sampleCsvTemplate =
      'Date,Title,Type,Category,Amount,PaymentMethod,Merchant,Note\n'
      '2026-08-20 14:30,Grocery Shopping,expense,Food & Dining,65.50,cash,Supermarket,Weekly essentials\n'
      '2026-08-19 09:00,Monthly Salary,income,Salary,3500.00,bankTransfer,Company Ltd,August Paycheck\n'
      '2026-08-18 19:15,Uber Ride,expense,Transportation,18.25,digitalWallet,Uber,Trip downtown';

  /// Prompts user to pick a CSV or TXT file and imports transactions into Isar.
  static Future<ImportResult> pickAndImport({
    required Isar isar,
    required List<Category> categories,
  }) async {
    try {
      FilePickerResult? pickResult;
      try {
        pickResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv', 'txt'],
          withData: true,
        );
      } catch (_) {
        // Fallback for devices where custom mime filter fails
        pickResult = await FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: true,
        );
      }

      if (pickResult == null || pickResult.files.isEmpty) {
        return const ImportResult(importedCount: 0, cancelled: true);
      }

      final fileInfo = pickResult.files.single;
      String csvString;

      if (fileInfo.bytes != null) {
        try {
          csvString = utf8.decode(fileInfo.bytes!);
        } catch (_) {
          csvString = latin1.decode(fileInfo.bytes!);
        }
      } else if (fileInfo.path != null) {
        final file = File(fileInfo.path!);
        try {
          csvString = await file.readAsString(encoding: utf8);
        } catch (_) {
          csvString = await file.readAsString(encoding: latin1);
        }
      } else {
        return const ImportResult(
          importedCount: 0,
          errorMessage: 'Could not read selected file.',
        );
      }

      return await importFromCsvString(
        csvString: csvString,
        isar: isar,
        categories: categories,
      );
    } catch (e) {
      return ImportResult(
        importedCount: 0,
        errorMessage: 'Import failed: ${e.toString()}',
      );
    }
  }

  /// Parses CSV string and inserts/upserts transactions into Isar database.
  static Future<ImportResult> importFromCsvString({
    required String csvString,
    required Isar isar,
    required List<Category> categories,
  }) async {
    try {
      final cleanedCsv = csvString
          .replaceAll('\uFEFF', '') // Strip UTF-8 BOM if present
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');

      final lines = const LineSplitter()
          .convert(cleanedCsv)
          .where((l) => l.trim().isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        return const ImportResult(
          importedCount: 0,
          errorMessage: 'The file/content has no transaction lines.',
        );
      }

      // Pre-fetch existing transactions to safely map UUIDs & prevent unique key violations
      final existingModels = await isar.expenseIsarModels.where().findAll();
      final existingUuidMap = <String, int>{
        for (final m in existingModels) m.uuid: m.id,
      };

      final categoryMap = <String, String>{};
      for (final cat in categories) {
        categoryMap[cat.name.toLowerCase().trim()] = cat.id;
        categoryMap[cat.id.toLowerCase().trim()] = cat.id;
      }

      int idCol = -1;
      int dateCol = -1;
      int titleCol = -1;
      int typeCol = -1;
      int catCol = -1;
      int amountCol = -1;
      int methodCol = -1;
      int merchantCol = -1;
      int noteCol = -1;

      int startIndex = 0;
      final headerRow = _parseCsvRow(lines.first);
      final isHeader = headerRow.any((cell) {
        final c = cell.toLowerCase().trim();
        return c == 'title' ||
            c == 'amount' ||
            c == 'date' ||
            c == 'category' ||
            c == 'id' ||
            c == 'type';
      });

      if (isHeader) {
        startIndex = 1;
        for (var i = 0; i < headerRow.length; i++) {
          final colName =
              headerRow[i].toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
          if (colName == 'id' || colName == 'uuid') {
            idCol = i;
          } else if (colName.contains('date') || colName.contains('time')) {
            dateCol = i;
          } else if (colName.contains('title') ||
              colName.contains('name') ||
              colName.contains('description') ||
              colName.contains('item')) {
            titleCol = i;
          } else if (colName.contains('type')) {
            typeCol = i;
          } else if (colName.contains('cat')) {
            catCol = i;
          } else if (colName.contains('amount') ||
              colName.contains('cost') ||
              colName.contains('price') ||
              colName.contains('value') ||
              colName.contains('spent') ||
              colName.contains('money') ||
              colName.contains('total')) {
            amountCol = i;
          } else if (colName.contains('method') ||
              colName.contains('payment') ||
              colName.contains('pay')) {
            methodCol = i;
          } else if (colName.contains('merchant') ||
              colName.contains('vendor') ||
              colName.contains('payee') ||
              colName.contains('store') ||
              colName.contains('shop')) {
            merchantCol = i;
          } else if (colName.contains('note') ||
              colName.contains('memo') ||
              colName.contains('comment') ||
              colName.contains('remark')) {
            noteCol = i;
          }
        }
      }

      // If no explicit amount column was found in header, detect by first data row
      if (amountCol == -1 && lines.length > startIndex) {
        final sampleRow = _parseCsvRow(lines[startIndex]);
        for (var i = 0; i < sampleRow.length; i++) {
          final cleanVal = sampleRow[i].replaceAll(RegExp(r'[^0-9.]'), '');
          if (cleanVal.isNotEmpty && double.tryParse(cleanVal) != null) {
            amountCol = i;
            break;
          }
        }
      }

      // Fallback default standard order: ID,Date,Title,Type,Category,Amount,PaymentMethod,Merchant,Note
      if (titleCol == -1) titleCol = idCol == 0 ? 2 : 1;
      if (dateCol == -1) dateCol = idCol == 0 ? 1 : 0;
      if (amountCol == -1) amountCol = 5;

      final modelsToInsert = <ExpenseIsarModel>[];
      int failedCount = 0;

      for (var lineIndex = startIndex; lineIndex < lines.length; lineIndex++) {
        final rawLine = lines[lineIndex].trim();
        if (rawLine.isEmpty) continue;

        final row = _parseCsvRow(rawLine);
        if (row.isEmpty) continue;

        try {
          final uuidVal = (idCol >= 0 &&
                  idCol < row.length &&
                  row[idCol].trim().isNotEmpty)
              ? row[idCol].trim()
              : _uuid.v4();

          final titleVal = (titleCol >= 0 &&
                  titleCol < row.length &&
                  row[titleCol].trim().isNotEmpty)
              ? row[titleCol].trim()
              : 'Imported Transaction';

          final amountStr = (amountCol >= 0 && amountCol < row.length)
              ? row[amountCol].replaceAll(RegExp(r'[^0-9.-]'), '').trim()
              : '0';
          final parsedAmount = (double.tryParse(amountStr) ?? 0.0).abs();
          if (parsedAmount <= 0) {
            failedCount++;
            continue;
          }

          // Parse Type
          int typeIdx = 0; // 0 = expense, 1 = income
          if (typeCol >= 0 && typeCol < row.length) {
            final t = row[typeCol].toLowerCase().trim();
            if (t.contains('income') || t == 'in' || t == '1' || t == '+') {
              typeIdx = 1;
            } else {
              typeIdx = 0;
            }
          }

          // Parse Category
          String categoryId = typeIdx == 1 ? 'cat_income_salary' : 'cat_other';
          if (catCol >= 0 && catCol < row.length) {
            final catStr = row[catCol].toLowerCase().trim();
            if (categoryMap.containsKey(catStr)) {
              categoryId = categoryMap[catStr]!;
            } else {
              for (final entry in categoryMap.entries) {
                if (entry.key.contains(catStr) || catStr.contains(entry.key)) {
                  categoryId = entry.value;
                  break;
                }
              }
            }
          }

          // Parse Payment Method
          int paymentMethodIdx = 0; // cash
          if (methodCol >= 0 && methodCol < row.length) {
            final m = row[methodCol].toLowerCase().trim();
            if (m.contains('debit')) {
              paymentMethodIdx = PaymentMethod.debitCard.index;
            } else if (m.contains('credit')) {
              paymentMethodIdx = PaymentMethod.creditCard.index;
            } else if (m.contains('bank') || m.contains('transfer')) {
              paymentMethodIdx = PaymentMethod.bankTransfer.index;
            } else if (m.contains('wallet') ||
                m.contains('digital') ||
                m.contains('bkash') ||
                m.contains('nagad')) {
              paymentMethodIdx = PaymentMethod.digitalWallet.index;
            } else if (m.contains('other')) {
              paymentMethodIdx = PaymentMethod.other.index;
            } else {
              paymentMethodIdx = PaymentMethod.cash.index;
            }
          }

          // Parse Date
          DateTime dateVal = DateTime.now();
          if (dateCol >= 0 &&
              dateCol < row.length &&
              row[dateCol].trim().isNotEmpty) {
            dateVal = _parseDate(row[dateCol].trim()) ?? DateTime.now();
          }

          // Merchant & Note
          final merchantVal = (merchantCol >= 0 &&
                  merchantCol < row.length &&
                  row[merchantCol].trim().isNotEmpty)
              ? row[merchantCol].trim()
              : null;
          final noteVal = (noteCol >= 0 &&
                  noteCol < row.length &&
                  row[noteCol].trim().isNotEmpty)
              ? row[noteCol].trim()
              : null;

          final model = ExpenseIsarModel()
            ..uuid = uuidVal
            ..title = titleVal
            ..amount = parsedAmount
            ..categoryId = categoryId
            ..typeIndex = typeIdx
            ..paymentMethodIndex = paymentMethodIdx
            ..date = dateVal
            ..createdAt = dateVal
            ..updatedAt = DateTime.now()
            ..merchant = merchantVal
            ..note = noteVal
            ..isDeleted = false;

          // If this record's UUID already exists in Isar, set the existing integer ID so it updates safely
          if (existingUuidMap.containsKey(uuidVal)) {
            model.id = existingUuidMap[uuidVal]!;
          }

          modelsToInsert.add(model);
        } catch (_) {
          failedCount++;
        }
      }

      if (modelsToInsert.isEmpty) {
        return ImportResult(
          importedCount: 0,
          failedCount: failedCount,
          errorMessage: 'No valid transaction records could be parsed.',
        );
      }

      // Batch insert into Isar in an atomic transaction
      await isar.writeTxn(() async {
        await isar.expenseIsarModels.putAll(modelsToInsert);
      });

      return ImportResult(
        importedCount: modelsToInsert.length,
        failedCount: failedCount,
      );
    } catch (e) {
      return ImportResult(
        importedCount: 0,
        errorMessage: 'Import failed: ${e.toString()}',
      );
    }
  }

  /// Splits a CSV row into cells supporting quoted fields with commas and double quotes.
  static List<String> _parseCsvRow(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // Skip escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        cells.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    cells.add(buffer.toString().trim());
    return cells;
  }

  /// Parses date using various common formats
  static DateTime? _parseDate(String dateStr) {
    // Try standard ISO
    final iso = DateTime.tryParse(dateStr);
    if (iso != null) return iso;

    final formats = [
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd HH:mm'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy HH:mm:ss'),
      DateFormat('dd/MM/yyyy HH:mm'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy HH:mm:ss'),
      DateFormat('MM/dd/yyyy HH:mm'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('dd-MM-yyyy HH:mm:ss'),
      DateFormat('dd-MM-yyyy HH:mm'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('d MMM yyyy, h:mm a'),
      DateFormat('d MMM yyyy'),
    ];

    for (final fmt in formats) {
      try {
        return fmt.parse(dateStr);
      } catch (_) {}
    }

    return null;
  }
}
