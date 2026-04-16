import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/inventory_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/services/timer/item_timer_service.dart';

// ─── Color Palette (matching your shop screen) ───────────────────────────────
const kBg        = Color(0xFFF9F9F9);
const kCard      = Color.fromARGB(255, 225, 180, 254);
const kCardAlt   = Color.fromARGB(255, 171, 155, 179);
const kBorder    = Color.fromARGB(255, 0, 0, 0);
const kPurple    = Color(0xFF7C3AED);
const kPurpleMid = Color(0xFF6D28D9);
const kGold      = Color(0xFFB45309);
const kGreen     = Color(0xFF15803D);
const kRed       = Color(0xFFB91C1C);
const kTxt       = Color(0xFF000000);
const kTxtSub    = Color(0xFF4B5563);


// ─── Sort Options ────────────────────────────────────────────────────────────
enum SortOption {
  levelAsc('Level ↑'),
  levelDesc('Level ↓'),
  dateNewest('Newest first'),
  dateOldest('Oldest first'),
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A');

  final String label;
  const SortOption(this.label);
}

// ─── MAIN INVENTORY SCREEN ───────────────────────────────────────────────────
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  SortOption _currentSort = SortOption.levelDesc;
  String _searchQuery = '';

  late final _inventoryController;

  @override 
  void initState() { 
    super.initState(); 
    _inventoryController = context.read<InventoryController>();
  }

  List<Item> getFilteredAndSortedItems(List<Item> items) {
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Sort items
    switch (_currentSort) {
      case SortOption.levelAsc:
        items.sort((a, b) => a.level.compareTo(b.level));
        break;
      case SortOption.levelDesc:
        items.sort((a, b) => b.level.compareTo(a.level));
        break;
      case SortOption.dateNewest:
        items.sort((a, b) => b.acquiredDate.compareTo(a.acquiredDate));
        break;
      case SortOption.dateOldest:
        items.sort((a, b) => a.acquiredDate.compareTo(b.acquiredDate));
        break;
      case SortOption.nameAsc:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return items;
  }

  void _showItemOptions(Item item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sell, color: kGold),
              title: const Text('Sell', style: TextStyle(color: kTxt)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sell function
              },
            ),
            const Divider(color: kBorder, height: 0),
            ListTile(
              leading: const Icon(Icons.delete, color: kRed),
              title: const Text('Delete', style: TextStyle(color: kTxt)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete function
              },
            ),
            if (!item.isActivated)
              const Divider(color: kBorder, height: 0),
            if (!item.isActivated)
              ListTile(
                leading: const Icon(Icons.play_arrow, color: kGreen),
                title: const Text('Use / Activate', style: TextStyle(color: kTxt)),
                onTap: () {
                  Navigator.pop(context);
                  _inventoryController.equipItem(item);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemTimerService = context.watch<ItemTimerService>(); 
    final inventoryController = context.watch<InventoryController>();
    final activatedItems = inventoryController.activatedItems;
    final inventoryItems = inventoryController.inventoryItems;
    
    final userController = context.watch<UserController>();
    final user = userController.user;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        elevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: kTxt,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kTxt),
      ),
      body: Column(
        children: [
          // ─── TOP 1/3 - ACTIVATED ITEMS SECTION ───────────────────────────
          Container(
            height: MediaQuery.of(context).size.height / 3,
            color: kCardAlt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.power_settings_new, color: kGreen, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Active Effects',
                        style: TextStyle(
                          color: kTxt,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${activatedItems.length}/${user.maxEquippedItemAmount} active',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: activatedItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.tv_off,
                                size: 48,
                                color: kTxtSub,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No active items',
                                style: TextStyle(
                                  color: kTxtSub,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Activate items from your inventory',
                                style: TextStyle(
                                  color: kTxtSub,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: activatedItems.length,
                          itemBuilder: (context, index) {
                            final item = activatedItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: kBorder),
                              ),
                              child: Row(
                                children: [
                                  // Item icon placeholder
                                  Column(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: kCardAlt,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.asset(item.imageUrl)
                                      ),

                                      SizedBox(height: 5),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          'Lv.${item.level}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ]
                                  ),

                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: kTxt,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),

                                        Text(
                                          item.description,
                                          style: const TextStyle(
                                            color: kPurple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.getFormattedRemainingDuration(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ─── BOTTOM SECTION - SEARCH + INVENTORY GRID ────────────────────
          Expanded(
            child: Column(
              children: [
                // Search bar with sort button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorder),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            style: const TextStyle(color: kTxt, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search items...',
                              hintStyle: const TextStyle(
                                color: kTxtSub,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: kTxtSub,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort Button
                      GestureDetector(
                        onTap: () {
                          _showSortOptions();
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorder),
                          ),
                          child: const Icon(
                            Icons.sort,
                            color: kPurple,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${inventoryItems.length} items',
                        style: const TextStyle(
                          color: kTxtSub,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Showing ${_currentSort.label}',
                        style: const TextStyle(
                          color: kTxtSub,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Inventory Grid (5 items per row)
                Expanded(
                  child: inventoryItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 64,
                                color: kTxtSub,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No items found',
                                style: TextStyle(
                                  color: kTxtSub,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  color: kTxtSub,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: inventoryItems.length,
                          itemBuilder: (context, index) {
                            final item = inventoryItems[index];
                            return GestureDetector(
                              onTap: () => _showItemOptions(item),
                              child: Column(
                                children: [
                                  // Circle avatar for item
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kCardAlt,
                                      border: Border.all(
                                        color: item.isActivated && item.isActivated
                                            ? kGreen
                                            : kBorder,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        if (item.isActivated && item.isActivated)
                                          BoxShadow(
                                            color: kGreen.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Container(
                                        color: kCard,
                                        child: Image.asset(item.imageUrl)
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: kTxt,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "${item.description} (${item.getFormattedBaseDuration()})",
                                    style: const TextStyle(
                                      color: kTxt,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Lv.${item.level}',
                                    style: const TextStyle(
                                      color: kGold,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.isActivated && item.isActivated)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kGreen,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sort by',
                style: TextStyle(
                  color: kTxt,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...SortOption.values.map((option) => Column(
                  children: [
                    ListTile(
                      title: Text(
                        option.label,
                        style: TextStyle(
                          color: _currentSort == option ? kPurple : kTxt,
                          fontWeight: _currentSort == option
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: _currentSort == option
                          ? const Icon(Icons.check, color: kPurple, size: 20)
                          : null,
                      onTap: () {
                        setState(() {
                          _currentSort = option;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    if (option != SortOption.nameDesc)
                      const Divider(color: kBorder, height: 0),
                  ],
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}