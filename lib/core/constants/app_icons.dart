import 'package:flutter/material.dart';

/// Maps string icon keys (stored in DB) to Flutter [IconData].
/// Using Material Symbols as the icon set — no third-party icon package needed.
abstract final class AppIcons {
  static const Map<String, IconData> _registry = {
    // Food
    'utensils': Icons.restaurant,
    'chef_hat': Icons.soup_kitchen,
    'shopping_basket': Icons.shopping_basket,
    'coffee': Icons.coffee,
    'cookie': Icons.cookie,
    // Transport
    'car': Icons.directions_car,
    'fuel': Icons.local_gas_station,
    'taxi': Icons.local_taxi,
    'bus': Icons.directions_bus,
    // Shopping
    'shopping_bag': Icons.shopping_bag,
    'shirt': Icons.checkroom,
    'laptop': Icons.laptop,
    'watch': Icons.watch,
    // Bills
    'receipt': Icons.receipt_long,
    'home': Icons.home,
    'wifi': Icons.wifi,
    'zap': Icons.bolt,
    'repeat': Icons.repeat,
    // Health
    'heart': Icons.favorite,
    'pill': Icons.medication,
    'stethoscope': Icons.medical_services,
    'dumbbell': Icons.fitness_center,
    // Entertainment
    'film': Icons.movie,
    'clapperboard': Icons.theaters,
    'gamepad': Icons.sports_esports,
    'plane': Icons.flight,
    // Income
    'trending_up': Icons.trending_up,
    'banknote': Icons.payments,
    'briefcase': Icons.work,
    'chart_line': Icons.show_chart,
    // Other
    'more_horizontal': Icons.more_horiz,
    'book': Icons.menu_book,
    'gift': Icons.card_giftcard,
    'package': Icons.inventory_2,
    // Settings / UI
    'moon': Icons.dark_mode,
    'sun': Icons.light_mode,
    'bell': Icons.notifications,
    'user': Icons.person,
    'shield': Icons.security,
    'download': Icons.download,
    'upload': Icons.upload,
    'trash': Icons.delete,
    'edit': Icons.edit,
    'plus': Icons.add,
    'check': Icons.check,
    'close': Icons.close,
    'arrow_right': Icons.arrow_forward_ios,
    'search': Icons.search,
    'filter': Icons.tune,
    'calendar': Icons.calendar_today,
    'camera': Icons.camera_alt,
    'credit_card': Icons.credit_card,
    'landmark': Icons.account_balance,
    'smartphone': Icons.smartphone,
    'settings': Icons.settings,
    'info': Icons.info_outline,
    'pie_chart': Icons.pie_chart,
    'bar_chart': Icons.bar_chart,
    'wallet': Icons.account_balance_wallet,
    'spa': Icons.spa,
    'pets': Icons.pets,
    'build': Icons.build,
    'savings': Icons.savings,
    'crypto': Icons.currency_bitcoin,
    'family': Icons.family_restroom,
    'school': Icons.school,
    'shopping_cart': Icons.shopping_cart,
    'sync': Icons.sync,
  };

  static IconData get(String key) => _registry[key] ?? Icons.circle;
}
