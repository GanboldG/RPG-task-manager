import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/custom_inventory_controller.dart';
import 'package:rpg_task_manager/controllers/inventory_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/owned_custom_item.dart';
import 'package:rpg_task_manager/models/user.dart';
import 'package:rpg_task_manager/services/user_service.dart';

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
const kBlue      = Color(0xFF1D4ED8);
const kTxt       = Color(0xFF000000);
const kTxtSub    = Color(0xFF4B5563);
const kOrange    = Color(0xFFEA580C);
const kYellow    = Color(0xFFD97706);

// ─── Sort Options for Real Items ────────────────────────────────────────────
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

// ─── Sort Options for Custom Items ──────────────────────────────────────────
enum CustomSortOption {
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A'),
  dateNewest('Newest first'),
  dateOldest('Oldest first'),
  priceAsc('Price ↑'),
  priceDesc('Price ↓'),
  remainingAsc('Soonest expiring'),
  remainingDesc('Longest remaining');

  final String label;
  const CustomSortOption(this.label);
}

// ─── MAIN INVENTORY SCREEN WITH TABS ────────────────────────────────────────
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  
  // Real items state
  final TextEditingController _searchController = TextEditingController();
  SortOption _currentSort = SortOption.levelDesc;
  String _searchQuery = '';

  // Custom items state
  final TextEditingController _customSearchController = TextEditingController();
  CustomSortOption _currentCustomSort = CustomSortOption.remainingDesc;
  String _customSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _customSearchController.dispose();
    super.dispose();
  }

  // ─── REAL ITEMS METHODS (UNCHANGED) ───────────────────────────────────────
  List<Item> getFilteredAndSortedItems(List<Item> items) {
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

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
                  context.read<InventoryController>().equipItem(item);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRealItemSortOptions() {
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
                style: TextStyle(color: kTxt, fontSize: 16, fontWeight: FontWeight.bold),
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
                      fontWeight: _currentSort == option ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: _currentSort == option
                      ? const Icon(Icons.check, color: kPurple, size: 20)
                      : null,
                  onTap: () {
                    setState(() { _currentSort = option; });
                    Navigator.pop(context);
                  },
                ),
                if (option != SortOption.nameDesc) const Divider(color: kBorder, height: 0),
              ],
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── CUSTOM ITEMS METHODS ─────────────────────────────────────────────────
  List<OwnedCustomItem> getFilteredAndSortedCustomItems(List<OwnedCustomItem> items) {
    // Create a modifiable copy FIRST
    List<OwnedCustomItem> result = [...items];  // or List.from(items)
    
    if (_customSearchQuery.isNotEmpty) {
      result = result.where((item) =>
          item.customItem.name.toLowerCase().contains(_customSearchQuery.toLowerCase())).toList();
    }

    switch (_currentCustomSort) {
      case CustomSortOption.nameAsc:
        result.sort((a, b) => a.customItem.name.compareTo(b.customItem.name));
        break;
      case CustomSortOption.nameDesc:
        result.sort((a, b) => b.customItem.name.compareTo(a.customItem.name));
        break;
      case CustomSortOption.dateNewest:
        result.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
        break;
      case CustomSortOption.dateOldest:
        result.sort((a, b) => a.purchasedAt.compareTo(b.purchasedAt));
        break;
      case CustomSortOption.priceAsc:
        result.sort((a, b) => a.customItem.priceGold.compareTo(b.customItem.priceGold));
        break;
      case CustomSortOption.priceDesc:
        result.sort((a, b) => b.customItem.priceGold.compareTo(a.customItem.priceGold));
        break;
      case CustomSortOption.remainingAsc:
        result.sort((a, b) => a.getRemainingDuration().compareTo(b.getRemainingDuration()));
        break;
      case CustomSortOption.remainingDesc:
        result.sort((a, b) => b.getRemainingDuration().compareTo(a.getRemainingDuration()));
        break;
    }
    return result;
  }

  void _showCustomItemSortOptions() {
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
                'Sort Custom Items',
                style: TextStyle(color: kTxt, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...CustomSortOption.values.map((option) => Column(
              children: [
                ListTile(
                  title: Text(
                    option.label,
                    style: TextStyle(
                      color: _currentCustomSort == option ? kOrange : kTxt,
                      fontWeight: _currentCustomSort == option ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: _currentCustomSort == option
                      ? const Icon(Icons.check, color: kOrange, size: 20)
                      : null,
                  onTap: () {
                    setState(() { _currentCustomSort = option; });
                    Navigator.pop(context);
                  },
                ),
                if (option != CustomSortOption.remainingDesc) const Divider(color: kBorder, height: 0),
              ],
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCustomItemOptions(OwnedCustomItem ownedItem) {
    final isActive = ownedItem.isActive;
    final isPaused = ownedItem.isPaused;
    
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
            // Custom item info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Text(
                    ownedItem.customItem.name,
                    style: const TextStyle(color: kTxt, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ownedItem.customItem.description,
                    style: const TextStyle(color: kTxtSub, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kCardAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stack count: ${ownedItem.stackCount}',
                      style: const TextStyle(color: kTxt, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: kBorder, height: 0),
            
            // Play/Pause button (only if active)
            if (isActive)
              ListTile(
                leading: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: isPaused ? kGreen : kOrange),
                title: Text(
                  isPaused ? 'Resume' : 'Pause',
                  style: const TextStyle(color: kTxt),
                ),
                subtitle: Text(
                  isPaused ? 'Continue counting down' : 'Temporarily stop timer',
                  style: const TextStyle(color: kTxtSub, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (isPaused) {
                    context.read<CustomItemInventoryController>().resumeCustomItem(ownedItem.id);
                  } else {
                    context.read<CustomItemInventoryController>().pauseCustomItem(ownedItem.id);
                  }
                },
              ),
            
            // Stack/Add more button
            // ListTile(
            //   leading: const Icon(Icons.add_circle, color: kBlue),
            //   title: const Text('Add Stack (+1)', style: TextStyle(color: kTxt)),
            //   subtitle: const Text('Add another instance of this reward', style: TextStyle(color: kTxtSub, fontSize: 11)),
            //   onTap: () {
            //     Navigator.pop(context);
            //     context.read<CustomItemInventoryController>().addStackToCustomItem(ownedItem.id);
            //   },
            // ),
            
            // const Divider(color: kBorder, height: 0),
            
            // Delete button
            ListTile(
              leading: const Icon(Icons.delete, color: kRed),
              title: const Text('Delete', style: TextStyle(color: kTxt)),
              subtitle: const Text('Remove this reward from inventory', style: TextStyle(color: kTxtSub, fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(ownedItem);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(OwnedCustomItem ownedItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Delete Custom Item?', style: TextStyle(color: kTxt)),
        content: Text(
          'Are you sure you want to delete "${ownedItem.customItem.name}"?\n\nThis will remove all stacks of this reward from your inventory.',
          style: const TextStyle(color: kTxtSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kTxtSub)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CustomItemInventoryController>().deleteCustomItem(ownedItem.id);
            },
            child: const Text('Delete', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final itemTimerService = context.watch<ItemTimerService>();
    final inventoryController = context.watch<InventoryController>();
    final customInventoryController = context.watch<CustomItemInventoryController>();
    
    final activatedItems = inventoryController.activatedItems;
    final inventoryItems = inventoryController.inventoryItems;
    final ownedCustomItems = customInventoryController.ownedCustomItems;
    
    final userController = context.watch<UserController>();
    final user = userController.user;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        elevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kTxt),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPurple,
          indicatorWeight: 3,
          labelColor: kPurple,
          unselectedLabelColor: kTxtSub,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: '⚔️ Items'),
            Tab(text: '🎁 Rewards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ─── TAB 1: REAL ITEMS (ORIGINAL UI - UNCHANGED) ─────────────────
          _buildRealItemsTab(activatedItems, inventoryItems, user),

          // ─── TAB 2: CUSTOM ITEMS (NEW UI) ───────────────────────────────
          _buildCustomItemsTab(ownedCustomItems),
        ],
      ),
    );
  }

  // ─── REAL ITEMS TAB (ORIGINAL UI - MOSTLY UNCHANGED) ──────────────────────
  Widget _buildRealItemsTab(List<Item> activatedItems, List<Item> inventoryItems, User user) {
    return Column(
      children: [
        // Top 1/3 - Activated Items Section
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
                      style: TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activatedItems.length}/${user.maxEquippedItemAmount} active',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
                            Icon(Icons.tv_off, size: 48, color: kTxtSub),
                            SizedBox(height: 12),
                            Text('No active items', style: TextStyle(color: kTxtSub, fontSize: 14)),
                            SizedBox(height: 4),
                            Text('Activate items from your inventory', style: TextStyle(color: kTxtSub, fontSize: 12)),
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
                                Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: kCardAlt,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.asset(item.imageUrl),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Text(
                                        'Lv.${item.level}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(color: kTxt, fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      Text(
                                        item.generateDescription(),
                                        style: const TextStyle(color: kPurple, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.textSecondaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.getFormattedRemainingDuration(),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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

        // Bottom section - Search + Inventory Grid
        Expanded(
          child: Column(
            children: [
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
                            setState(() { _searchQuery = value; });
                          },
                          style: const TextStyle(color: kTxt, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            hintStyle: const TextStyle(color: kTxtSub, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: kTxtSub, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showRealItemSortOptions,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Icon(Icons.sort, color: kPurple, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${inventoryItems.length}/${UserService().currentUser.inventorySlot} items', style: const TextStyle(color: kTxtSub, fontSize: 12)),
                    Text('Showing ${_currentSort.label}', style: const TextStyle(color: kTxtSub, fontSize: 11, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: inventoryItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory, size: 64, color: kTxtSub),
                            SizedBox(height: 16),
                            Text('No items found', style: TextStyle(color: kTxtSub, fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            Text('Try a different search term', style: TextStyle(color: kTxtSub, fontSize: 13)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: getFilteredAndSortedItems(inventoryItems).length,
                        itemBuilder: (context, index) {
                          final item = getFilteredAndSortedItems(inventoryItems)[index];
                          return GestureDetector(
                            onTap: () => _showItemOptions(item),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kCardAlt,
                                    border: Border.all(
                                      color: item.isActivated ? kGreen : kBorder,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      if (item.isActivated)
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
                                      child: Image.asset(item.imageUrl),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  style: const TextStyle(color: kTxt, fontSize: 10, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "${item.generateDescription()} (${item.getFormattedBaseDuration()})",
                                  style: const TextStyle(color: kTxt, fontSize: 10, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Lv.${item.level}',
                                  style: const TextStyle(color: kGold, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                                if (item.isActivated)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: kGreen,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
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
    );
  }

  // ─── CUSTOM ITEMS TAB (NEW UI) ────────────────────────────────────────────
  Widget _buildCustomItemsTab(List<OwnedCustomItem> ownedCustomItems) {
    final filteredItems = getFilteredAndSortedCustomItems(ownedCustomItems);
    // final totalStacks = ownedCustomItems.fold<int>(0, (sum, item) => sum + item.stackCount);
    
    return Column(
      children: [
        // // Top section - Stats and summary
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   color: kCardAlt,
        //   child: Column(
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceAround,
        //         children: [
        //           _buildStatCard(
        //             icon: Icons.card_giftcard,
        //             label: 'Unique Items',
        //             value: ownedCustomItems.length.toString(),
        //             color: kPurple,
        //           ),
        //           _buildStatCard(
        //             icon: Icons.layers,
        //             label: 'Total Stacks',
        //             value: totalStacks.toString(),
        //             color: kBlue,
        //           ),
        //           _buildStatCard(
        //             icon: Icons.timer,
        //             label: 'Active',
        //             value: ownedCustomItems.where((i) => i.isActive && !i.isPaused).length.toString(),
        //             color: kGreen,
        //           ),
        //           _buildStatCard(
        //             icon: Icons.pause,
        //             label: 'Paused',
        //             value: ownedCustomItems.where((i) => i.isPaused).length.toString(),
        //             color: kOrange,
        //           ),
        //         ],
        //       ),
        //       const SizedBox(height: 12),
        //       Container(
        //         padding: const EdgeInsets.all(8),
        //         decoration: BoxDecoration(
        //           color: kCard,
        //           borderRadius: BorderRadius.circular(8),
        //           border: Border.all(color: kBorder),
        //         ),
        //         child: const Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(Icons.info_outline, color: kTxtSub, size: 16),
        //             SizedBox(width: 8),
        //             Expanded(
        //               child: Text(
        //                 'Custom rewards have no usage limit. Tap on an item to pause, resume, or add more stacks.',
        //                 style: TextStyle(color: kTxtSub, fontSize: 11),
        //                 textAlign: TextAlign.center,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // Search and sort bar
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
                    controller: _customSearchController,
                    onChanged: (value) {
                      setState(() { _customSearchQuery = value; });
                    },
                    style: const TextStyle(color: kTxt, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search rewards...',
                      hintStyle: const TextStyle(color: kTxtSub, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: kTxtSub, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showCustomItemSortOptions,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Icon(Icons.sort, color: kOrange, size: 24),
                ),
              ),
            ],
          ),
        ),

        // Sort label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${filteredItems.length} rewards', style: const TextStyle(color: kTxtSub, fontSize: 12)),
              Text('Sorted: ${_currentCustomSort.label}', style: const TextStyle(color: kTxtSub, fontSize: 11, fontStyle: FontStyle.italic)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Custom items list
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, size: 64, color: kTxtSub),
                      SizedBox(height: 16),
                      Text('No rewards redeemed', style: TextStyle(color: kTxtSub, fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Text('Go to shop to redeem rewards!', style: TextStyle(color: kTxtSub, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final ownedItem = filteredItems[index];
                    final isActive = ownedItem.isActive;
                    final isPaused = ownedItem.isPaused;
                    final remaining = ownedItem.getRemainingDuration();
                    final isExpired = remaining <= 0;
                    
                    return GestureDetector(
                      onTap: () => _showCustomItemOptions(ownedItem),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpired ? kRed : (isPaused ? kOrange : (isActive ? kGreen : kBorder)),
                            width: isExpired || isPaused || isActive ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Item image or icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: kCardAlt,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ownedItem.customItem.imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(ownedItem.customItem.imagePath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.card_giftcard, color: kPurpleMid, size: 30),
                                      ),
                                    )
                                  : const Icon(Icons.card_giftcard, color: kPurpleMid, size: 30),
                            ),
                            const SizedBox(width: 12),
                            
                            // Item info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ownedItem.customItem.name,
                                          style: const TextStyle(
                                            color: kTxt,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isExpired)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: kRed,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'EXPIRED',
                                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      if (isPaused && !isExpired)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: kOrange,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'PAUSED',
                                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ownedItem.customItem.description,
                                    style: const TextStyle(color: kTxtSub, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: kCardAlt,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.layers, size: 12, color: kTxtSub),
                                            const SizedBox(width: 4),
                                            Text(
                                              'x${ownedItem.stackCount}',
                                              style: const TextStyle(color: kTxt, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isExpired ? kRed.withOpacity(0.2) : (isPaused ? kOrange.withOpacity(0.2) : kCardAlt),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isExpired ? Icons.timer_off : (isPaused ? Icons.pause : Icons.timer),
                                              size: 12,
                                              color: isExpired ? kRed : (isPaused ? kOrange : kGreen),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isExpired ? 'Expired' : _formatDuration(remaining),
                                              style: TextStyle(
                                                color: isExpired ? kRed : (isPaused ? kOrange : kTxt),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Action buttons
                            Column(
                              children: [
                                if (isActive && !isPaused && !isExpired)
                                  IconButton(
                                    icon: const Icon(Icons.pause_circle, color: kOrange, size: 28),
                                    onPressed: () {
                                      context.read<CustomItemInventoryController>().pauseCustomItem(ownedItem.id);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                if (isPaused && !isExpired)
                                  IconButton(
                                    icon: const Icon(Icons.play_circle, color: kGreen, size: 28),
                                    onPressed: () {
                                      context.read<CustomItemInventoryController>().resumeCustomItem(ownedItem.id);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                // if (!isExpired)
                                //   IconButton(
                                //     icon: const Icon(Icons.add_circle, color: kBlue, size: 28),
                                //     onPressed: () {
                                //       context.read<CustomItemInventoryController>().addStackToCustomItem(ownedItem.id);
                                //     },
                                //     padding: EdgeInsets.zero,
                                //     constraints: const BoxConstraints(),
                                //   ),
                                // const SizedBox(height: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: kRed, size: 24),
                                  onPressed: () => _showDeleteConfirmation(ownedItem),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: kCard,
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: kBorder),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(icon, color: color, size: 20),
  //         const SizedBox(height: 4),
  //         Text(
  //           value,
  //           style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
  //         ),
  //         Text(
  //           label,
  //           style: const TextStyle(color: kTxtSub, fontSize: 10),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'Expired';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}