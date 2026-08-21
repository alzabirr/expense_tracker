/// App-wide constants.
abstract final class AppConstants {
  static const String appName = 'Momentum';
  static const String appVersion = '1.0.0';

  // Isar
  static const String isarDbName = 'momentum_db';

  // Settings
  static const int settingsIsarId = 0;

  // Budgets
  static const double budgetWarningThreshold = 0.8;  // 80%
  static const double budgetDangerThreshold = 1.0;   // 100%

  // Transactions
  static const double largeTransactionWarning = 1000.0;
  static const int softDeleteRetentionDays = 30;
  static const int recentTransactionsCount = 10;

  // Analytics
  static const int trendMonthsBack = 6;

  // Default currency
  static const String defaultCurrencyCode = 'USD';
  static const String defaultLocale = 'en_US';
}
