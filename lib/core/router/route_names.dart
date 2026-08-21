/// Named route constants for GoRouter.
abstract final class RouteNames {
  static const String dashboard = '/';
  static const String transactions = '/transactions';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense/:id';
  static const String transactionDetail = '/transaction/:id';
  static const String categoryManagement = '/categories';
  static const String budgetScreen = '/budget';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';

  static String editExpensePath(String id) => '/edit-expense/$id';
  static String transactionDetailPath(String id) => '/transaction/$id';
}
