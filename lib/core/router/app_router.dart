import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/features/shell/shell_screen.dart';
import 'package:spendra/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:spendra/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:spendra/features/analytics/presentation/screens/reports_screen.dart';
import 'package:spendra/features/settings/presentation/screens/settings_screen.dart';
import 'package:spendra/features/expense/presentation/screens/add_edit_expense_screen.dart';
import 'package:spendra/features/expense/presentation/screens/transaction_detail_screen.dart';
import 'package:spendra/features/category/presentation/screens/category_management_screen.dart';
import 'package:spendra/features/budget/presentation/screens/budget_screen.dart';
import 'package:spendra/features/onboarding/presentation/screens/onboarding_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.onboarding,
  routes: [
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.transactions,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TransactionsScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.reports,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ReportsScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.addExpense,
      pageBuilder: (context, state) => CustomTransitionPage(
        fullscreenDialog: true,
        child: const AddEditExpenseScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: RouteNames.editExpense,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          fullscreenDialog: true,
          child: AddEditExpenseScreen(editId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: RouteNames.transactionDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TransactionDetailScreen(transactionId: id);
      },
    ),
    GoRoute(
      path: RouteNames.categoryManagement,
      builder: (context, state) => const CategoryManagementScreen(),
    ),
    GoRoute(
      path: RouteNames.budgetScreen,
      builder: (context, state) => const BudgetScreen(),
    ),
  ],
);
