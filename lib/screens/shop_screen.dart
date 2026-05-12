import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/inventory_controller.dart';
import 'package:rpg_task_manager/controllers/item_shop_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/item/custom_item.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';
import 'package:rpg_task_manager/services/audio_service.dart';
import 'package:rpg_task_manager/services/user_service.dart';
import 'package:rpg_task_manager/storage/item_database.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
Color kBg(BuildContext ctx) => Theme.of(ctx).scaffoldBackgroundColor;
Color kCard(BuildContext ctx) => Theme.of(ctx).colorScheme.primary;
Color kCardAlt(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.primary.withOpacity(0.6);
Color kBorder(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.onSurface.withOpacity(0.2);
Color kPurple(BuildContext ctx) => Theme.of(ctx).colorScheme.secondary;
Color kPurpleMid(BuildContext ctx) => Theme.of(ctx).colorScheme.secondary;
Color kPurpleDim(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.secondary.withOpacity(0.7);
const kGold = Color(0xFFB45309);
const kGreen = Color(0xFF15803D);
const kRed = Color(0xFFB91C1C);
const kBlue = Color(0xFF1D4ED8);
Color kTxt(BuildContext ctx) => Theme.of(ctx).colorScheme.onSurface;
Color kTxtSub(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6);

// ─── ROOT ─────────────────────────────────────────────────────────────────────
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openLootBox() => openLootbox(context);

  // Buy REAL items (XP/Gold boosts)
  void _buyShopItem(Item item) {
    final userController = context.read<UserController>();

    if (userController.spendGolds(item.priceGold)) {
      final shopController = context.read<ItemShopController>();

      // If item can't be bought
      String buyMessage = shopController.buyItem(item);
      if (buyMessage != "") {
        HelperFunctions.showMessage(context, buyMessage);
      }

      AudioService.instance.playSfx("assets/audio/watcha_say.mp3");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purchased ${item.name}!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough golds! 💰'),
          backgroundColor: kRed,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Buy CUSTOM ITEMS (user-created rewards) - Does NOT remove from shop
  void _buyCustomItem(CustomItem item) {
    final userController = context.read<UserController>();

    if (userController.spendGolds(item.priceGold)) {
      final shopController = context.read<ItemShopController>();
      shopController.purchaseCustomItem(item.id);

      // Item stays in shop - no removal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Purchased ${item.name}! Find it in your inventory.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough golds! 💰'),
          backgroundColor: kRed,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _refreshShop() {
    final shopController = context.read<ItemShopController>();
    shopController.refreshShop();
    // _shopController.refreshCustomItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshShop,
        child: Icon(Icons.refresh, color: kPurple(context)),
      ),
      body: Column(
        children: [
          Container(
            color: kCard(context),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: TabBar(
              controller: _tab,
              indicatorColor: kPurple(context),
              indicatorWeight: 3,
              labelColor: kPurple(context),
              unselectedLabelColor: kTxtSub(context),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: const [
                Tab(text: 'Item Shop'),
                Tab(text: 'Reward Shop'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _TokenShopTab(onBuy: _buyShopItem, onOpenLootbox: _openLootBox),
                _CustomItemShopTab(onBuyCustomItem: _buyCustomItem),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ITEM SHOP TAB (Unchanged) ───────────────────────────────────────────────────
class _TokenShopTab extends StatelessWidget {
  final void Function(Item item) onBuy;
  final VoidCallback onOpenLootbox;

  const _TokenShopTab({required this.onBuy, required this.onOpenLootbox});

  @override
  Widget build(BuildContext context) {
    ItemShopController controller = context.watch<ItemShopController>();
    final items = controller.items;

    return Column(
      children: [
        SizedBox(
          child: Image.asset(
            'assets/images/shop_banner.gif',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),

        LootboxButton(onTap: onOpenLootbox),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = items[i];
              return _ShopItemCard(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 179, 148, 194),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(item.imageUrl),
                ),
                name: item.name,
                durationSec: item.durationSeconds,
                rarity: item.rarity,
                subtitle:
                    "${item.generateDescription()} (${item.getFormattedBaseDuration()})",
                price: item.priceGold,
                onBuy: () => onBuy(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── CUSTOM ITEM SHOP TAB (Simplified - No Most Popular, No Detail Button) ───
class _CustomItemShopTab extends StatelessWidget {
  final void Function(CustomItem) onBuyCustomItem;

  const _CustomItemShopTab({required this.onBuyCustomItem});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ItemShopController>();
    final allItems = controller.customItems;

    return Column(
      children: [
        SizedBox(
          child: Image.asset(
            'assets/images/custom_banner.png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SecTitle(
                      "📜 All Rewards (${allItems.length}/${UserService().currentUser.customShopSlot})",
                    ),
                    _AddVoucherBtn(
                      onTap: () async {
                        // Max rewards reached
                        if (allItems.length >=
                            UserService().currentUser.customShopSlot) {
                          HelperFunctions.showMessage(
                            context,
                            "Reward limit reached. Delete a reward to add new rewards!",
                          );
                          return;
                        }

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCustomItemScreen(),
                          ),
                        );
                        // Refresh after adding
                        // controller.refreshCustomItems();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (allItems.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_activity_outlined,
                            color: kTxtSub(context),
                            size: 42,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No rewards yet.\nCreate custom rewards for completing tasks!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTxtSub(context),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...allItems.map(
                    (item) => _buildCard(item, onBuyCustomItem, context),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    CustomItem item,
    void Function(CustomItem) onBuy,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => _showCustomItemOptions(item, onBuy, context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _CustomItemCard(
          leading: _CustomItemAvatar(imagePath: item.imagePath, size: 50),
          name: item.name,
          duration: HelperFunctions.formatDuration(item.durationMinutes * 60),
          subtitle: item.description,
          price: item.priceGold,
          onBuy: () => onBuy(item),
        ),
      ),
    );
  }

  void _showCustomItemOptions(
    CustomItem item,
    void Function(CustomItem) onBuy,
    BuildContext context,
  ) {
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
            // Description section
            if (item.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  item.description,
                  style: TextStyle(color: kTxt(context), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ListTile(
              leading: Icon(Icons.edit, color: kBlue),
              title: Text('Edit', style: TextStyle(color: kTxt(context))),
              onTap: () {
                Navigator.pop(context);
                _editCustomItem(item);
              },
            ),
            Divider(color: kBorder(context), height: 0),
            ListTile(
              leading: Icon(Icons.delete, color: kRed),
              title: Text('Delete', style: TextStyle(color: kTxt(context))),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteCustomItem(item, context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _editCustomItem(CustomItem item) {
    // TODO Edit methods
  }

  void _confirmDeleteCustomItem(CustomItem item, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard(context),
        title: Text('Delete Item', style: TextStyle(color: kTxt(context))),
        content: Text(
          'Delete "${item.name}"?',
          style: TextStyle(color: kTxt(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              context.read<ItemShopController>().deleteCustomItem(item.id);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('"${item.name}" deleted')));
            },
            child: Text('Delete', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }
}

// ─── ADD CUSTOM ITEM SCREEN (Unchanged) ───────────────────────────────────────
class AddCustomItemScreen extends StatefulWidget {
  const AddCustomItemScreen({super.key});

  @override
  State<AddCustomItemScreen> createState() => _AddCustomItemScreenState();
}

class _AddCustomItemScreenState extends State<AddCustomItemScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(); // NEW: duration controller
  final _descCtrl = TextEditingController();
  File? _imageFile;
  static const double _feeRate = 0.15;

  int get _price => int.tryParse(_priceCtrl.text) ?? 0;
  int get _duration =>
      int.tryParse(_durationCtrl.text) ?? 0; // NEW: duration getter
  int get _fee => (_price * _feeRate).toInt();

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _price == 0 || _duration == 0) {
      // MODIFIED: added duration check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill in name, price, and duration.'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    final controller = context.read<ItemShopController>();

    await controller.addCustomItem(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priceGold: _price,
      durationMinutes: _duration, // NEW: pass duration
      imageFile: _imageFile,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose(); // NEW: dispose duration controller
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg(context),
      appBar: AppBar(
        backgroundColor: kCard(context),
        iconTheme: IconThemeData(color: kTxt(context)),
        title: Text(
          'Create a Reward',
          style: TextStyle(color: kTxt(context), fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kCardAlt(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder(context)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: kTxtSub(context),
                                    size: 34,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'upload image',
                                    style: TextStyle(
                                      color: kTxtSub(context),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      _Field(
                        ctrl: _nameCtrl,
                        maxLength: 40,
                        maxHeight: 1,
                        hint: 'Name ("1 Hour Gaming" etc)',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              ctrl: _priceCtrl,
                              maxLength: 7,
                              maxHeight: 1,
                              hint: 'Price (Gold)',
                              isNumber: true,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.monetization_on,
                            color: kGold,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // NEW: spacing
                      Row(
                        children: [
                          // NEW: duration field row
                          Expanded(
                            child: _Field(
                              ctrl: _durationCtrl,
                              maxLength: 9,
                              maxHeight: 1,
                              hint: 'Duration (minutes)',
                              isNumber: true,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.timer,
                            color: kPurpleMid(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              height: 100,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kCardAlt(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder(context)),
              ),
              child: TextField(
                controller: _descCtrl,
                maxLines: null,
                maxLength: 60,
                expands: true,
                style: TextStyle(color: kTxt(context), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'What can the user do with this reward?',
                  hintStyle: TextStyle(color: kTxtSub(context), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: _OutlineBtn(
                    label: 'Cancel',
                    color: kRed,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SolidBtn(label: 'Create Reward', onTap: _submit),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── SHARED WIDGETS (Simplified - No Detail Button, No Tags) ────────────

class _ShopItemCard extends StatelessWidget {
  final Widget leading;
  final String name, subtitle;
  final int price;
  final int durationSec;
  final ItemRarity rarity;
  final VoidCallback onBuy;

  const _ShopItemCard({
    required this.leading,
    required this.name,
    required this.durationSec,
    required this.rarity,
    required this.subtitle,
    required this.price,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromARGB(255, 250, 241, 255), // Left side
            rarity.color, // Right side
          ],
          stops: [0.3, 1.0], // Optional: controls where each color starts/stops
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder(context)),
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name ",
                  style: TextStyle(
                    color: kTxt(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: kPurpleMid(context), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                Text(
                  rarity.name.toUpperCase(),
                  style: TextStyle(
                    color: rarity.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Row(
            children: [
              Text(
                '$price',
                style: TextStyle(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.monetization_on, color: kGold, size: 14),
              const SizedBox(width: 6),
              _BuyBtn(onTap: onBuy, label: 'BUY'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomItemCard extends StatelessWidget {
  final Widget leading;
  final String name, duration, subtitle;
  final int price;
  final VoidCallback onBuy;

  const _CustomItemCard({
    required this.leading,
    required this.duration,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: kCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder(context)),
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name ($duration)",
                  style: TextStyle(
                    color: kTxt(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: kTxtSub(context), fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Row(
            children: [
              Text(
                '$price',
                style: TextStyle(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.monetization_on, color: kGold, size: 14),
              const SizedBox(width: 6),
              _BuyBtn(onTap: onBuy, label: 'ACTIVATE'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomItemAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  _CustomItemAvatar({this.imagePath, required this.size});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imagePath != null) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        imageWidget = Image.file(file, fit: BoxFit.cover);
      } else {
        imageWidget = Icon(
          Icons.local_activity,
          color: kPurpleMid(context),
          size: 28,
        );
      }
    } else {
      imageWidget = Icon(
        Icons.local_activity,
        color: kPurpleMid(context),
        size: 28,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: Container(color: kCardAlt(context), child: imageWidget),
      ),
    );
  }
}

class _BuyBtn extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _BuyBtn({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    ),
  );
}

class _AddVoucherBtn extends StatelessWidget {
  final VoidCallback onTap;
  _AddVoucherBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kPurple(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'CREATE REWARD',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SecTitle extends StatelessWidget {
  final String text;
  _SecTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: kTxt(context),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isNumber;
  final void Function(String)? onChanged;
  final int maxLength, maxHeight;

  const _Field({
    required this.ctrl,
    required this.hint,
    required this.maxLength,
    required this.maxHeight,
    this.isNumber = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    onChanged: onChanged,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: TextStyle(color: kTxt(context), fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: kTxtSub(context), fontSize: 13),
      filled: true,
      fillColor: kCardAlt(context),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kPurple(context), width: 1.5),
      ),
    ),
    maxLength: !isNumber ? maxLength : null,
    inputFormatters: isNumber
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLength),
          ]
        : [],
  );
}

class _PriceInfo extends StatelessWidget {
  final String label;
  final int value;
  _PriceInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: kTxtSub(context), fontSize: 13)),
      Row(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: kGold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.monetization_on, color: kGold, size: 16),
        ],
      ),
    ],
  );
}

class _SolidBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  _SolidBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: kPurple(context),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: color),
      foregroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

// GAMBLING

// ─── Constants ────────────────────────────────────────────────────────────────
const _kLootboxCost = 100;
const _kCardWidth = 110.0;
const _kCardHeight = 140.0;
const _kCardGap = 10.0;
const _kRollDuration = Duration(milliseconds: 7000); // was 4500
const _kWinnerIndex = 60; // was 32, need more cards to scroll through
const _kStripItems = 72; // was 40, must be > _kWinnerIndex + buffer

// ─── Lootbox Button — drop this in _TokenShopTab between banner & ListView ───
class LootboxButton extends StatelessWidget {
  final VoidCallback onTap;
  const LootboxButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 176, 166, 59),
                Color.fromARGB(255, 206, 203, 21),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GAMBLING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    ' 100 Gold per roll',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Open lootbox — call this from _ShopScreenState ──────────────────────────
void openLootbox(BuildContext context) {
  final userController = context.read<UserController>();

  if (!userController.spendGolds(_kLootboxCost)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not enough gold! Need 100 💰'),
        backgroundColor: Color(0xFFB91C1C),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // Build a pool of ~40 randomized items; winner is at _kWinnerIndex
  final shopController = context.read<ItemShopController>();
  final rng = Random();

  List<Item> strip = List.generate(_kStripItems, (i) {
    final original =
        ItemDatabase.allItems[rng.nextInt(ItemDatabase.allItems.length)];
    final rarity = shopController.shopManager.getItemRarity();
    return ItemDatabase.randomizeItem(original, 1, rarity);
  });

  // Replace winner slot with a fresh roll (so it's truly random)
  final winnerOriginal =
      ItemDatabase.allItems[rng.nextInt(ItemDatabase.allItems.length)];
  final winnerRarity = shopController.shopManager.getItemRarity();
  final winner = ItemDatabase.randomizeItem(winnerOriginal, 1, winnerRarity);
  strip[_kWinnerIndex] = winner;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LootboxDialog(
      strip: strip,
      winner: winner,
      onClaim: (item) {
        context.read<InventoryController>().addItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added to inventory!'),
            backgroundColor: const Color(0xFF6D28D9),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    ),
  );
}

// ─── Dialog ───────────────────────────────────────────────────────────────────
class _LootboxDialog extends StatefulWidget {
  final List<Item> strip;
  final Item winner;
  final void Function(Item) onClaim;

  const _LootboxDialog({
    required this.strip,
    required this.winner,
    required this.onClaim,
  });

  @override
  State<_LootboxDialog> createState() => _LootboxDialogState();
}

class _RollCurve extends Curve {
  const _RollCurve();

  @override
  double transformInternal(double t) {
    // Slow start (stall), accelerate to middle, slow end
    // Uses a sine-based ease with a heavier slow-in
    return (1 - cos(t * pi)) / 2;
  }
}

class _LootboxDialogState extends State<_LootboxDialog>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollCtrl;
  late final AnimationController _animCtrl;
  late final Animation<double> _scrollAnim;

  bool _done = false;

  // The center of the viewport is the "selector" line.
  // We want item at _kWinnerIndex to stop under it.
  // Each card = _kCardWidth + _kCardGap. We offset by half viewport width
  // to center the card.
  static const double _itemStep = _kCardWidth + _kCardGap;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();

    _animCtrl = AnimationController(vsync: this, duration: _kRollDuration);

    // Delay 1 frame so scroll controller has its viewport attached
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRoll());
  }

  void _startRoll() {
    AudioService().playSfx("assets/audio/gambling.mp3");
    final viewportWidth = _scrollCtrl.position.viewportDimension;
    final centerOffset = viewportWidth / 2 - _kCardWidth / 2;

    // Target scroll: winner card center is at viewport center
    final targetScroll = _kWinnerIndex * _itemStep - centerOffset;

    _scrollAnim = Tween<double>(
      begin: 0,
      end: targetScroll,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: const _RollCurve()));

    _scrollAnim.addListener(() {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(
          _scrollAnim.value.clamp(0, _scrollCtrl.position.maxScrollExtent),
        );
      }
    });

    _animCtrl.forward().then((_) {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A0A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'GOLD GOLD GOLD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),

            // Strip container
            Stack(
              alignment: Alignment.center,
              children: [
                // The scrolling strip
                SizedBox(
                  height: _kCardHeight,
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: widget.strip.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: _kCardGap),
                    itemBuilder: (_, i) => _StripCard(item: widget.strip[i]),
                  ),
                ),

                // Center selector lines (left & right edges of winner slot)
                Positioned(
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left marker
                      Container(
                        width: 3,
                        height: _kCardHeight + 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFBBF24).withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: _kCardWidth - 6),
                      // Right marker
                      Container(
                        width: 3,
                        height: _kCardHeight + 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFBBF24).withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Edge fades
                Positioned(
                  left: 0,
                  child: Container(
                    width: 60,
                    height: _kCardHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A0A2E),
                          const Color(0xFF1A0A2E).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: 60,
                    height: _kCardHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A0A2E).withOpacity(0),
                          const Color(0xFF1A0A2E),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Winner reveal / claim
            if (_done) ...[
              _WinnerReveal(item: widget.winner),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        foregroundColor: Colors.grey,
                      ),
                      child: Text('Discard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onClaim(widget.winner);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Claim!'),
                    ),
                  ),
                ],
              ),
            ] else
              const SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    'Rolling...',
                    style: TextStyle(color: Color(0xFFD8B4FE), fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Single card in the strip ─────────────────────────────────────────────────
class _StripCard extends StatelessWidget {
  final Item item;
  const _StripCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kCardWidth,
      height: _kCardHeight,
      decoration: BoxDecoration(
        color: item.rarity.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.rarity.color, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            item.imageUrl,
            width: 56,
            height: 56,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.auto_awesome, color: item.rarity.color, size: 40),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.rarity.name.toUpperCase(),
            style: TextStyle(
              color: item.rarity.color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Winner reveal shown after roll ──────────────────────────────────────────
class _WinnerReveal extends StatelessWidget {
  final Item item;
  const _WinnerReveal({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: item.rarity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.rarity.color, width: 1.5),
      ),
      child: Row(
        children: [
          Image.asset(
            item.imageUrl,
            width: 52,
            height: 52,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.auto_awesome, color: item.rarity.color, size: 42),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.rarity.name.toUpperCase(),
                  style: TextStyle(
                    color: item.rarity.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.generateDescription(),
                  style: TextStyle(color: Color(0xFFD8B4FE), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
