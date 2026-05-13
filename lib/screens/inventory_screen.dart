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
Color kBg(BuildContext ctx) => Theme.of(ctx).scaffoldBackgroundColor;
Color kCard(BuildContext ctx) => Theme.of(ctx).colorScheme.primary;
Color kCardAlt(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.primary.withOpacity(0.6);
Color kBorder(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.onSurface.withOpacity(0.2);
Color kPurple(BuildContext ctx) => Theme.of(ctx).colorScheme.secondary;
Color kPurpleMid(BuildContext ctx) => Theme.of(ctx).colorScheme.secondary;
const kGold = Color(0xFFB45309);
const kGreen = Color(0xFF15803D);
const kRed = Color(0xFFB91C1C);
const kBlue = Color(0xFF1D4ED8);
Color kTxt(BuildContext ctx) => Theme.of(ctx).colorScheme.onSurface;
Color kTxtSub(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6);
const kOrange = Color(0xFFEA580C);
const kYellow = Color(0xFFD97706);

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

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
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
      items = items
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
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
    final inventoryController = context.read<InventoryController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: kCard(context),
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
              margin: EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: kBorder(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            if (!item.isActivated)
              ListTile(
                leading: Icon(Icons.play_arrow, color: kGreen),
                title: Text(
                  'Use / Activate',
                  style: TextStyle(color: kTxt(context)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<InventoryController>().equipItem(item);
                },
              ),

            ListTile(
              leading: Icon(Icons.delete, color: kRed),
              title: Text('Delete', style: TextStyle(color: kTxt(context))),
              onTap: () {
                Navigator.pop(context);
                // DELETE
                inventoryController.deleteItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRealItemSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard(context),
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
              margin: EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: kBorder(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sort by',
                style: TextStyle(
                  color: kTxt(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            ...SortOption.values.map(
              (option) => Column(
                children: [
                  ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        color: _currentSort == option
                            ? kPurple(context)
                            : kTxt(context),
                        fontWeight: _currentSort == option
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: _currentSort == option
                        ? Icon(Icons.check, color: kPurple(context), size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _currentSort = option;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  if (option != SortOption.nameDesc)
                    Divider(color: kBorder(context), height: 0),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── CUSTOM ITEMS METHODS ─────────────────────────────────────────────────
  List<OwnedCustomItem> getFilteredAndSortedCustomItems(
    List<OwnedCustomItem> items,
  ) {
    // Create a modifiable copy FIRST
    List<OwnedCustomItem> result = [...items]; // or List.from(items)

    if (_customSearchQuery.isNotEmpty) {
      result = result
          .where(
            (item) => item.customItem.name.toLowerCase().contains(
              _customSearchQuery.toLowerCase(),
            ),
          )
          .toList();
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
        result.sort(
          (a, b) => a.customItem.priceGold.compareTo(b.customItem.priceGold),
        );
        break;
      case CustomSortOption.priceDesc:
        result.sort(
          (a, b) => b.customItem.priceGold.compareTo(a.customItem.priceGold),
        );
        break;
      case CustomSortOption.remainingAsc:
        result.sort(
          (a, b) =>
              a.getRemainingDuration().compareTo(b.getRemainingDuration()),
        );
        break;
      case CustomSortOption.remainingDesc:
        result.sort(
          (a, b) =>
              b.getRemainingDuration().compareTo(a.getRemainingDuration()),
        );
        break;
    }
    return result;
  }

  void _showCustomItemSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard(context),
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
              margin: EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: kBorder(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sort Custom Items',
                style: TextStyle(
                  color: kTxt(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            ...CustomSortOption.values.map(
              (option) => Column(
                children: [
                  ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        color: _currentCustomSort == option
                            ? kOrange
                            : kTxt(context),
                        fontWeight: _currentCustomSort == option
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: _currentCustomSort == option
                        ? Icon(Icons.check, color: kOrange, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _currentCustomSort = option;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  if (option != CustomSortOption.remainingDesc)
                    Divider(color: kBorder(context), height: 0),
                ],
              ),
            ),
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
      backgroundColor: kCard(context),
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
              margin: EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: kBorder(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Custom item info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Text(
                    ownedItem.customItem.name,
                    style: TextStyle(
                      color: kTxt(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    ownedItem.customItem.description,
                    style: TextStyle(color: kTxtSub(context), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kCardAlt(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stack count: ${ownedItem.stackCount}',
                      style: TextStyle(
                        color: kTxt(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: kBorder(context), height: 0),

            // Play/Pause button (only if active)
            if (isActive)
              ListTile(
                leading: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: isPaused ? kGreen : kOrange,
                ),
                title: Text(
                  isPaused ? 'Resume' : 'Pause',
                  style: TextStyle(color: kTxt(context)),
                ),
                subtitle: Text(
                  isPaused
                      ? 'Continue counting down'
                      : 'Temporarily stop timer',
                  style: TextStyle(color: kTxtSub(context), fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (isPaused) {
                    context
                        .read<CustomItemInventoryController>()
                        .resumeCustomItem(ownedItem.id);
                  } else {
                    context
                        .read<CustomItemInventoryController>()
                        .pauseCustomItem(ownedItem.id);
                  }
                },
              ),

            // Stack/Add more button
            // ListTile(
            //   leading: Icon(Icons.add_circle, color: kBlue),
            //   title: Text('Add Stack (+1)', style: TextStyle(color: kTxt(context))),
            //   subtitle: Text('Add another instance of this reward', style: TextStyle(color: kTxtSub(context), fontSize: 11)),
            //   onTap: () {
            //     Navigator.pop(context);
            //     context.read<CustomItemInventoryController>().addStackToCustomItem(ownedItem.id);
            //   },
            // ),

            // Divider(color: kBorder(context), height: 0),

            // Delete button
            ListTile(
              leading: Icon(Icons.delete, color: kRed),
              title: Text('Delete', style: TextStyle(color: kTxt(context))),
              subtitle: Text(
                'Remove this reward from inventory',
                style: TextStyle(color: kTxtSub(context), fontSize: 11),
              ),
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
        backgroundColor: kCard(context),
        title: Text(
          'Delete Custom Item?',
          style: TextStyle(color: kTxt(context)),
        ),
        content: Text(
          'Are you sure you want to delete "${ownedItem.customItem.name}"?\n\nThis will remove all stacks of this reward from your inventory.',
          style: TextStyle(color: kTxtSub(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: kTxtSub(context))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CustomItemInventoryController>().deleteCustomItem(
                ownedItem.id,
              );
            },
            child: Text('Delete', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final itemTimerService = context.watch<ItemTimerService>();
    final inventoryController = context.watch<InventoryController>();
    final customInventoryController = context
        .watch<CustomItemInventoryController>();

    final activatedItems = inventoryController.activatedItems;
    final inventoryItems = inventoryController.inventoryItems;
    final ownedCustomItems = customInventoryController.ownedCustomItems;

    final userController = context.watch<UserController>();
    final user = userController.user;

    return Scaffold(
      backgroundColor: kBg(context),
      appBar: AppBar(
        backgroundColor: kCard(context),
        elevation: 0,
        title: Text(
          'Inventory',
          style: TextStyle(
            color: kTxt(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: kTxt(context)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPurple(context),
          indicatorWeight: 3,
          labelColor: kPurple(context),
          unselectedLabelColor: kTxtSub(context),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
  Widget _buildRealItemsTab(
    List<Item> activatedItems,
    List<Item> inventoryItems,
    User user,
  ) {
    return Column(
      children: [
        // Top 1/3 - Activated Items Section
        Container(
          height: MediaQuery.of(context).size.height / 3,
          color: kCardAlt(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.power_settings_new, color: kGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Active Effects',
                      style: TextStyle(
                        color: kTxt(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPurple(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activatedItems.length}/${user.maxEquippedItemAmount} active',
                        style: TextStyle(
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tv_off,
                              size: 48,
                              color: kTxtSub(context),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No active items',
                              style: TextStyle(
                                color: kTxtSub(context),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Activate items from your inventory',
                              style: TextStyle(
                                color: kTxtSub(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: activatedItems.length,
                        itemBuilder: (context, index) {
                          final item = activatedItems[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kCard(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kBorder(context)),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: kCardAlt(context),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.asset(item.imageUrl),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        'Lv.${item.level}',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          color: kTxt(context),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        item.generateDescription(),
                                        style: TextStyle(
                                          color: kPurple(context),
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.4),
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

        // Bottom section - Search + Inventory Grid
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: kCard(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder(context)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: TextStyle(color: kTxt(context), fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            hintStyle: TextStyle(
                              color: kTxtSub(context),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: kTxtSub(context),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showRealItemSortOptions,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: kCard(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder(context)),
                        ),
                        child: Icon(
                          Icons.sort,
                          color: kPurple(context),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${inventoryItems.length}/${UserService().currentUser.inventorySlot} items',
                      style: TextStyle(color: kTxtSub(context), fontSize: 12),
                    ),
                    Text(
                      'Showing ${_currentSort.label}',
                      style: TextStyle(
                        color: kTxtSub(context),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: inventoryItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 64,
                              color: kTxtSub(context),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                color: kTxtSub(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                color: kTxtSub(context),
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
                        itemCount: getFilteredAndSortedItems(
                          inventoryItems,
                        ).length,
                        itemBuilder: (context, index) {
                          final item = getFilteredAndSortedItems(
                            inventoryItems,
                          )[index];
                          return GestureDetector(
                            onTap: () => _showItemOptions(item),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kCardAlt(context),
                                    border: Border.all(
                                      color: item.isActivated
                                          ? kGreen
                                          : kBorder(context),
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
                                      color: kCard(context),
                                      child: Image.asset(item.imageUrl),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    color: kTxt(context),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "${item.generateDescription()} (${item.getFormattedBaseDuration()})",
                                  style: TextStyle(
                                    color: kTxt(context),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Lv.${item.level}',
                                  style: TextStyle(
                                    color: kGold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.isActivated)
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
                                    child: Text(
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
        //   padding: EdgeInsets.all(16),
        //   color: kCardAlt(context),
        //   child: Column(
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceAround,
        //         children: [
        //           _buildStatCard(
        //             icon: Icons.card_giftcard,
        //             label: 'Unique Items',
        //             value: ownedCustomItems.length.toString(),
        //             color: kPurple(context),
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
        //       SizedBox(height: 12),
        //       Container(
        //         padding: EdgeInsets.all(8),
        //         decoration: BoxDecoration(
        //           color: kCard(context),
        //           borderRadius: BorderRadius.circular(8),
        //           border: Border.all(color: kBorder(context)),
        //         ),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(Icons.info_outline, color: kTxtSub(context), size: 16),
        //             SizedBox(width: 8),
        //             Expanded(
        //               child: Text(
        //                 'Custom rewards have no usage limit. Tap on an item to pause, resume, or add more stacks.',
        //                 style: TextStyle(color: kTxtSub(context), fontSize: 11),
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
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: kCard(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder(context)),
                  ),
                  child: TextField(
                    controller: _customSearchController,
                    onChanged: (value) {
                      setState(() {
                        _customSearchQuery = value;
                      });
                    },
                    style: TextStyle(color: kTxt(context), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search rewards...',
                      hintStyle: TextStyle(
                        color: kTxtSub(context),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: kTxtSub(context),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _showCustomItemSortOptions,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: kCard(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder(context)),
                  ),
                  child: const Icon(Icons.sort, color: kOrange, size: 24),
                ),
              ),
            ],
          ),
        ),

        // Sort label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredItems.length} rewards',
                style: TextStyle(color: kTxtSub(context), fontSize: 12),
              ),
              Text(
                'Sorted: ${_currentCustomSort.label}',
                style: TextStyle(
                  color: kTxtSub(context),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        // Custom items list
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: kTxtSub(context),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No rewards redeemed',
                        style: TextStyle(
                          color: kTxtSub(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Go to shop to redeem rewards!',
                        style: TextStyle(color: kTxtSub(context), fontSize: 13),
                      ),
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
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kCard(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpired
                                ? kRed
                                : (isPaused
                                      ? kOrange
                                      : (isActive ? kGreen : kBorder(context))),
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
                                color: kCardAlt(context),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ownedItem.customItem.imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(ownedItem.customItem.imagePath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.card_giftcard,
                                          color: kPurpleMid(context),
                                          size: 30,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.card_giftcard,
                                      color: kPurpleMid(context),
                                      size: 30,
                                    ),
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
                                          style: TextStyle(
                                            color: kTxt(context),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isExpired)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kRed,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'EXPIRED',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      if (isPaused && !isExpired)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kOrange,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'PAUSED',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    ownedItem.customItem.description,
                                    style: TextStyle(
                                      color: kTxtSub(context),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kCardAlt(context),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.layers,
                                              size: 12,
                                              color: kTxtSub(context),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'x${ownedItem.stackCount}',
                                              style: TextStyle(
                                                color: kTxt(context),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isExpired
                                              ? kRed.withOpacity(0.2)
                                              : (isPaused
                                                    ? kOrange.withOpacity(0.2)
                                                    : kCardAlt(context)),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isExpired
                                                  ? Icons.timer_off
                                                  : (isPaused
                                                        ? Icons.pause
                                                        : Icons.timer),
                                              size: 12,
                                              color: isExpired
                                                  ? kRed
                                                  : (isPaused
                                                        ? kOrange
                                                        : kGreen),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              isExpired
                                                  ? 'Expired'
                                                  : _formatDuration(remaining),
                                              style: TextStyle(
                                                color: isExpired
                                                    ? kRed
                                                    : (isPaused
                                                          ? kOrange
                                                          : kTxt(context)),
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
                                    icon: const Icon(
                                      Icons.pause_circle,
                                      color: kOrange,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<CustomItemInventoryController>()
                                          .pauseCustomItem(ownedItem.id);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                if (isPaused && !isExpired)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.play_circle,
                                      color: kGreen,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<CustomItemInventoryController>()
                                          .resumeCustomItem(ownedItem.id);
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
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: kRed,
                                    size: 24,
                                  ),
                                  onPressed: () =>
                                      _showDeleteConfirmation(ownedItem),
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
  //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: kCard(context),
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: kBorder(context)),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(icon, color: color, size: 20),
  //         SizedBox(height: 4),
  //         Text(
  //           value,
  //           style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
  //         ),
  //         Text(
  //           label,
  //           style: TextStyle(color: kTxtSub(context), fontSize: 10),
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
