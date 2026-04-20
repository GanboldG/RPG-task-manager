import 'package:hive/hive.dart';

part 'custom_item.g.dart';

@HiveType(typeId: 3)
class CustomItem {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final int priceGold;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final String? imagePath;
  
  @HiveField(6)
  final int purchaseCount;

  @HiveField(7)
  final int durationMinutes;

  CustomItem({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.description,
    required this.priceGold,
    required this.createdAt,
    this.imagePath,
    this.purchaseCount = 0,
  });

  // Helper to check if item is new (created within last 7 days)
  bool get isNew {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return createdAt.isAfter(sevenDaysAgo);
  }

  @override
  String toString() {
    return 'CustomItem(id: $id, name: $name, price: $priceGold, purchases: $purchaseCount)';
  }
}

// Keep old Voucher class for backward compatibility during migration
@deprecated
typedef Voucher = CustomItem;