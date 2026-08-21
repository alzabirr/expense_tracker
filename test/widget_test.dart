import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendra/core/widgets/amount_display.dart';
import 'package:spendra/core/widgets/empty_state.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/presentation/widgets/category_chip.dart';

void main() {
  group('Core Widget Tests', () {
    testWidgets('AmountLabel displays negative sign for expense', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountLabel(
              amount: 45.5,
              symbol: '\$',
              isExpense: true,
            ),
          ),
        ),
      );

      expect(find.text('-\$45.50'), findsOneWidget);
    });

    testWidgets('AmountLabel displays positive sign for income', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountLabel(
              amount: 2500,
              symbol: '\$',
              isExpense: false,
            ),
          ),
        ),
      );

      expect(find.text('+\$2,500.00'), findsOneWidget);
    });

    testWidgets('EmptyState renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Data Found',
              subtitle: 'Please add items to get started.',
            ),
          ),
        ),
      );

      expect(find.text('No Data Found'), findsOneWidget);
      expect(find.text('Please add items to get started.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('CategoryChip displays name and handles tap', (tester) async {
      bool tapped = false;
      const category = Category(
        id: 'cat_test',
        name: 'Groceries',
        iconKey: 'shopping_basket',
        colorToken: 'coral',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: category,
              isSelected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
