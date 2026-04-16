import 'package:hive/hive.dart';

part 'voucher.g.dart';

@HiveType(typeId: 2)
class Voucher {
  @HiveField(0)
  final String id;
  
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
  int purchaseCount;
  
  @HiveField(7)
  bool isRedeemed;

  Voucher({
    required this.id,
    required this.name,
    required this.description,
    required this.priceGold,
    required this.createdAt,
    this.imagePath,
    this.purchaseCount = 0,
    this.isRedeemed = false,
  });

  bool get isNew => DateTime.now().difference(createdAt).inDays < 3;
}