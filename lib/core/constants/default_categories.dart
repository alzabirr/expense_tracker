/// Seed data for the 7 default category groups and their subcategories.
/// On first launch, these are written to Isar by the bootstrap service.
abstract final class DefaultCategories {
  static const List<Map<String, dynamic>> all = [
    // ── Food ───────────────────────────────────────────────────────
    {
      'uuid': 'cat_food',
      'name': 'Food & Drink',
      'iconKey': 'utensils',
      'colorToken': 'coral',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_food_restaurant',
      'name': 'Restaurant',
      'iconKey': 'chef_hat',
      'colorToken': 'coral',
      'parentId': 'cat_food',
      'isDefault': true,
    },
    {
      'uuid': 'cat_food_grocery',
      'name': 'Groceries',
      'iconKey': 'shopping_basket',
      'colorToken': 'coral',
      'parentId': 'cat_food',
      'isDefault': true,
    },
    {
      'uuid': 'cat_food_coffee',
      'name': 'Coffee',
      'iconKey': 'coffee',
      'colorToken': 'amber',
      'parentId': 'cat_food',
      'isDefault': true,
    },
    {
      'uuid': 'cat_food_snacks',
      'name': 'Snacks',
      'iconKey': 'cookie',
      'colorToken': 'amber',
      'parentId': 'cat_food',
      'isDefault': true,
    },

    // ── Transport ──────────────────────────────────────────────────
    {
      'uuid': 'cat_transport',
      'name': 'Transport',
      'iconKey': 'car',
      'colorToken': 'violet',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_transport_fuel',
      'name': 'Fuel',
      'iconKey': 'fuel',
      'colorToken': 'violet',
      'parentId': 'cat_transport',
      'isDefault': true,
    },
    {
      'uuid': 'cat_transport_taxi',
      'name': 'Taxi / Ride',
      'iconKey': 'taxi',
      'colorToken': 'violet',
      'parentId': 'cat_transport',
      'isDefault': true,
    },
    {
      'uuid': 'cat_transport_transit',
      'name': 'Public Transit',
      'iconKey': 'bus',
      'colorToken': 'sky',
      'parentId': 'cat_transport',
      'isDefault': true,
    },

    // ── Shopping ───────────────────────────────────────────────────
    {
      'uuid': 'cat_shopping',
      'name': 'Shopping',
      'iconKey': 'shopping_bag',
      'colorToken': 'pink',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_shopping_clothes',
      'name': 'Clothes',
      'iconKey': 'shirt',
      'colorToken': 'pink',
      'parentId': 'cat_shopping',
      'isDefault': true,
    },
    {
      'uuid': 'cat_shopping_electronics',
      'name': 'Electronics',
      'iconKey': 'laptop',
      'colorToken': 'slate',
      'parentId': 'cat_shopping',
      'isDefault': true,
    },
    {
      'uuid': 'cat_shopping_accessories',
      'name': 'Accessories',
      'iconKey': 'watch',
      'colorToken': 'rose',
      'parentId': 'cat_shopping',
      'isDefault': true,
    },

    // ── Bills ──────────────────────────────────────────────────────
    {
      'uuid': 'cat_bills',
      'name': 'Bills & Utilities',
      'iconKey': 'receipt',
      'colorToken': 'slate',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_bills_rent',
      'name': 'Rent',
      'iconKey': 'home',
      'colorToken': 'slate',
      'parentId': 'cat_bills',
      'isDefault': true,
    },
    {
      'uuid': 'cat_bills_internet',
      'name': 'Internet',
      'iconKey': 'wifi',
      'colorToken': 'sky',
      'parentId': 'cat_bills',
      'isDefault': true,
    },
    {
      'uuid': 'cat_bills_electricity',
      'name': 'Electricity',
      'iconKey': 'zap',
      'colorToken': 'amber',
      'parentId': 'cat_bills',
      'isDefault': true,
    },
    {
      'uuid': 'cat_bills_subscription',
      'name': 'Subscription',
      'iconKey': 'repeat',
      'colorToken': 'indigo',
      'parentId': 'cat_bills',
      'isDefault': true,
    },

    // ── Health ─────────────────────────────────────────────────────
    {
      'uuid': 'cat_health',
      'name': 'Health',
      'iconKey': 'heart',
      'colorToken': 'red',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_health_medicine',
      'name': 'Medicine',
      'iconKey': 'pill',
      'colorToken': 'red',
      'parentId': 'cat_health',
      'isDefault': true,
    },
    {
      'uuid': 'cat_health_doctor',
      'name': 'Doctor',
      'iconKey': 'stethoscope',
      'colorToken': 'red',
      'parentId': 'cat_health',
      'isDefault': true,
    },
    {
      'uuid': 'cat_health_fitness',
      'name': 'Fitness',
      'iconKey': 'dumbbell',
      'colorToken': 'lime',
      'parentId': 'cat_health',
      'isDefault': true,
    },

    // ── Entertainment ──────────────────────────────────────────────
    {
      'uuid': 'cat_entertainment',
      'name': 'Entertainment',
      'iconKey': 'film',
      'colorToken': 'teal',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_entertainment_movies',
      'name': 'Movies',
      'iconKey': 'clapperboard',
      'colorToken': 'teal',
      'parentId': 'cat_entertainment',
      'isDefault': true,
    },
    {
      'uuid': 'cat_entertainment_games',
      'name': 'Games',
      'iconKey': 'gamepad',
      'colorToken': 'indigo',
      'parentId': 'cat_entertainment',
      'isDefault': true,
    },
    {
      'uuid': 'cat_entertainment_travel',
      'name': 'Travel',
      'iconKey': 'plane',
      'colorToken': 'sky',
      'parentId': 'cat_entertainment',
      'isDefault': true,
    },

    // ── Income ─────────────────────────────────────────────────────
    {
      'uuid': 'cat_income',
      'name': 'Income',
      'iconKey': 'trending_up',
      'colorToken': 'teal',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_salary',
      'name': 'Salary',
      'iconKey': 'banknote',
      'colorToken': 'teal',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_freelance',
      'name': 'Freelance',
      'iconKey': 'briefcase',
      'colorToken': 'lime',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_investment',
      'name': 'Investment',
      'iconKey': 'chart_line',
      'colorToken': 'indigo',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_business',
      'name': 'Business',
      'iconKey': 'landmark',
      'colorToken': 'amber',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_bonus',
      'name': 'Bonus',
      'iconKey': 'trending_up',
      'colorToken': 'teal',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_rental',
      'name': 'Rental',
      'iconKey': 'home',
      'colorToken': 'sky',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_gift',
      'name': 'Gifts / Grants',
      'iconKey': 'gift',
      'colorToken': 'pink',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_side_hustle',
      'name': 'Side Hustle',
      'iconKey': 'zap',
      'colorToken': 'violet',
      'parentId': 'cat_income',
      'isDefault': true,
    },
    {
      'uuid': 'cat_income_other',
      'name': 'Other Income',
      'iconKey': 'wallet',
      'colorToken': 'teal',
      'parentId': 'cat_income',
      'isDefault': true,
    },

    // ── Other ──────────────────────────────────────────────────────
    {
      'uuid': 'cat_other',
      'name': 'Other',
      'iconKey': 'more_horizontal',
      'colorToken': 'stone',
      'parentId': null,
      'isDefault': true,
    },
    {
      'uuid': 'cat_other_education',
      'name': 'Education',
      'iconKey': 'book',
      'colorToken': 'sky',
      'parentId': 'cat_other',
      'isDefault': true,
    },
    {
      'uuid': 'cat_other_gifts',
      'name': 'Gifts',
      'iconKey': 'gift',
      'colorToken': 'rose',
      'parentId': 'cat_other',
      'isDefault': true,
    },
    {
      'uuid': 'cat_other_misc',
      'name': 'Miscellaneous',
      'iconKey': 'package',
      'colorToken': 'stone',
      'parentId': 'cat_other',
      'isDefault': true,
    },
  ];

  /// Top-level groups only (parentId == null).
  static List<Map<String, dynamic>> get groups =>
      all.where((c) => c['parentId'] == null).toList();

  /// Subcategories for a given parent UUID.
  static List<Map<String, dynamic>> childrenOf(String parentUuid) =>
      all.where((c) => c['parentId'] == parentUuid).toList();
}
