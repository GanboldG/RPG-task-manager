import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/item_shop_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/helpers/helper_functions.dart';
import 'package:rpg_task_manager/models/item/custom_item.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/item_rarity.dart';
import 'package:rpg_task_manager/services/audio_service.dart';
import 'package:rpg_task_manager/services/item_service.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const kBg        = Color.fromARGB(255, 246, 232, 255);
const kCard      = Color.fromARGB(255, 225, 180, 254);
const kCardAlt   = Color.fromARGB(255, 171, 155, 179);
const kBorder    = Color.fromARGB(255, 0, 0, 0);
const kPurple    = Color(0xFF7C3AED);
const kPurpleMid = Color(0xFF6D28D9); 
const kPurpleDim = Color(0xFF4C2A8A);
const kGold      = Color(0xFFB45309);
const kGreen     = Color(0xFF15803D);
const kRed       = Color(0xFFB91C1C);
const kBlue      = Color(0xFF1D4ED8);
const kTxt       = Color(0xFF000000);
const kTxtSub    = Color(0xFF4B5563);

// ─── ROOT ─────────────────────────────────────────────────────────────────────
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final UserController _userController;
  late final ItemShopController _shopController;

  @override 
  void initState() { 
    super.initState(); 
    _tab = TabController(length: 2, vsync: this); 
    
    _userController = context.read<UserController>();
    _shopController = context.read<ItemShopController>();
  }
  
  @override 
  void dispose() { 
    _tab.dispose(); 
    super.dispose(); 
  }

  // Buy REAL items (XP/Gold boosts)
  void _buyShopItem(Item item) {
    if (_userController.spendGolds(item.priceGold)) {
      final shopController = context.read<ItemShopController>();
      shopController.buyItem(item);
      
      AudioService.instance.playSfx("assets/audio/watcha_say.mp3");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Purchased ${item.name}!', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.textSecondary,
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Not enough golds! 💰'),
        backgroundColor: kRed,
        duration: Duration(seconds: 2),
      ));
    }
  }

  // Buy CUSTOM ITEMS (user-created rewards) - Does NOT remove from shop
  void _buyCustomItem(CustomItem item) {
    if (_userController.spendGolds(item.priceGold)) {
      final shopController = context.read<ItemShopController>();
      shopController.purchaseCustomItem(item.id);

      // Item stays in shop - no removal
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Purchased ${item.name}! Find it in your inventory.",
          style: TextStyle(color: Colors.white)
        ),
        backgroundColor: AppColors.textSecondary,
        duration: const Duration(seconds: 3),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Not enough golds! 💰'),
        backgroundColor: kRed,
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _refreshShop(){
    final shopController = context.read<ItemShopController>();
    shopController.refreshShop();
    // _shopController.refreshCustomItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshShop,
        child: Icon(Icons.refresh, color: kPurple),
      ),
      body: Column(children: [
        Container(
          color: kCard,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: TabBar(
            controller: _tab,
            indicatorColor: kPurple,
            indicatorWeight: 3,
            labelColor: kPurple,
            unselectedLabelColor: kTxtSub,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [
              Tab(text: 'Item Shop',), 
              Tab(text: 'Custom Items'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _TokenShopTab(onBuy: _buyShopItem),
              _CustomItemShopTab(onBuyCustomItem: _buyCustomItem),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── ITEM SHOP TAB (Unchanged) ───────────────────────────────────────────────────
class _TokenShopTab extends StatelessWidget {
  final void Function(Item item) onBuy;
  const _TokenShopTab({required this.onBuy});

  @override
  Widget build(BuildContext context){
    ItemShopController controller = context.watch<ItemShopController>();
    final items = controller.items;

      return Column(
        children: [
          SizedBox(
            child: Image.asset(
              'assets/images/shop_banner.gif',
              fit: BoxFit.cover,
              width: double.infinity,
            )
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = items[i];
                return _ShopItemCard(
                  leading: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: const Color.fromARGB(255, 179, 148, 194), borderRadius: BorderRadius.circular(8)),
                    child: Image.asset(item.imageUrl),
                  ),
                  name: item.name,
                  durationSec: item.durationSeconds,
                  rarity: item.rarity,
                  subtitle: "${item.generateDescription()} (${item.getFormattedBaseDuration()})",
                  price: item.priceGold,
                  onBuy: () => onBuy(item),
                );
              },
            )
          )
        ]
      );
  }
}

// ─── CUSTOM ITEM SHOP TAB (Simplified - No Most Popular, No Detail Button) ───
class _CustomItemShopTab extends StatelessWidget {
  final void Function(CustomItem) onBuyCustomItem;
  
  const _CustomItemShopTab({
    required this.onBuyCustomItem,
  });

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
          )
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const _SecTitle('📜 All Custom Items:'),
                _AddVoucherBtn(onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AddCustomItemScreen()
                  ));
                  // Refresh after adding
                  // controller.refreshCustomItems();
                }),
              ]),
              const SizedBox(height: 8),
              if (allItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Column(children: [
                    Icon(Icons.local_activity_outlined, color: kTxtSub, size: 42),
                    SizedBox(height: 10),
                    Text('No custom items yet.\nCreate custom rewards for completing tasks!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTxtSub, fontSize: 13, height: 1.5)),
                  ])),
                )
              else
                ...allItems.map((item) => _buildCard(item, onBuyCustomItem, context)),
            ]),
          )
        )
      ]
    );
  }

  Widget _buildCard(CustomItem item, void Function(CustomItem) onBuy, BuildContext context) {
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

  void _showCustomItemOptions(CustomItem item, void Function(CustomItem) onBuy, BuildContext context) {
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
            // Description section
            if (item.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  item.description,
                  style: const TextStyle(color: kTxt, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ListTile(
              leading: const Icon(Icons.edit, color: kBlue),
              title: const Text('Edit', style: TextStyle(color: kTxt)),
              onTap: () {
                Navigator.pop(context);
                _editCustomItem(item);
              },
            ),
            const Divider(color: kBorder, height: 0),
            ListTile(
              leading: const Icon(Icons.delete, color: kRed),
              title: const Text('Delete', style: TextStyle(color: kTxt)),
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
        backgroundColor: kCard,
        title: const Text('Delete Item', style: TextStyle(color: kTxt)),
        content: Text('Delete "${item.name}"?', style: const TextStyle(color: kTxt)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              context.read<ItemShopController>().deleteCustomItem(item.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${item.name}" deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: kRed)),
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
  int get _duration => int.tryParse(_durationCtrl.text) ?? 0; // NEW: duration getter
  int get _fee => (_price * _feeRate).toInt();

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _price == 0 || _duration == 0) { // MODIFIED: added duration check
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Fill in name, price, and duration.'),
        backgroundColor: kRed,
      ));
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
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        iconTheme: const IconThemeData(color: kTxt),
        title: const Text('Create Custom Item', style: TextStyle(color: kTxt, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: _pickImage,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kCardAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder)
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.image_outlined, color: kTxtSub, size: 34),
                            SizedBox(height: 6),
                            Text('upload image', style: TextStyle(color: kTxtSub, fontSize: 11)),
                          ]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 2,
              child: Column(children: [
                _Field(ctrl: _nameCtrl, hint: 'Item Name (e.g., "1 Hour Gaming")'),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _Field(ctrl: _priceCtrl, hint: 'Price (Gold)', isNumber: true, onChanged: (_) => setState(() {}))),
                  const SizedBox(width: 6),
                  const Icon(Icons.monetization_on, color: kGold, size: 20),
                ]),
                const SizedBox(height: 8), // NEW: spacing
                Row(children: [ // NEW: duration field row
                  Expanded(child: _Field(ctrl: _durationCtrl, hint: 'Duration (minutes)', isNumber: true, onChanged: (_) => setState(() {}))),
                  const SizedBox(width: 6),
                  const Icon(Icons.timer, color: kPurpleMid, size: 20),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 100,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kCardAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder)
            ),
            child: TextField(
              controller: _descCtrl,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: kTxt, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'What can the user do with this item?',
                hintStyle: TextStyle(color: kTxtSub, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          // const SizedBox(height: 12),
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     color: kCardAlt,
          //     borderRadius: BorderRadius.circular(10),
          //     border: Border.all(color: kBorder)
          //   ),
          //   child: _PriceInfo(label: 'Listing fee (15%):', value: _fee),
          // ),
          const Spacer(),
          Row(children: [
            Expanded(child: _OutlineBtn(label: 'Cancel', color: kRed, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _SolidBtn(label: 'Create Item', onTap: _submit)),
          ]),
          const SizedBox(height: 16),
        ]),
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
            const Color.fromARGB(255, 250, 241, 255),        // Left side
            rarity.color,        // Right side
          ],
          stops: const [0.3, 1.0],  // Optional: controls where each color starts/stops
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(children: [
        leading,
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("$name ",
              style: const TextStyle(color: kTxt, fontWeight: FontWeight.w600, fontSize: 13)
            ),
            const SizedBox(height: 3),
            Text(subtitle,
              style: const TextStyle(color: kPurpleMid, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 3),

            Text(rarity.name.toUpperCase(),
              style: TextStyle(color: rarity.color, fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: 6),
        Row(children: [
          Text('$price', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 3),
          const Icon(Icons.monetization_on, color: kGold, size: 14),
          const SizedBox(width: 6),
          _BuyBtn(onTap: onBuy, label: 'BUY'),
        ]),
      ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder)
      ),
      child: Row(children: [
        leading,
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("$name ($duration)",
              style: const TextStyle(color: kTxt, fontWeight: FontWeight.w600, fontSize: 13)
            ),
            const SizedBox(height: 3),
            Text(subtitle,
              style: const TextStyle(color: kTxtSub, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: 6),
        Row(children: [
          Text('$price', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 3),
          const Icon(Icons.monetization_on, color: kGold, size: 14),
          const SizedBox(width: 6),
          _BuyBtn(onTap: onBuy, label: 'ACTIVATE'),
        ]),
      ]),
    );
  }
}

class _CustomItemAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  const _CustomItemAvatar({this.imagePath, required this.size});
  
  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imagePath != null) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        imageWidget = Image.file(file, fit: BoxFit.cover);
      } else {
        imageWidget = const Icon(Icons.local_activity, color: kPurpleMid, size: 28);
      }
    } else {
      imageWidget = const Icon(Icons.local_activity, color: kPurpleMid, size: 28);
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size, 
        height: size,
        child: Container(color: kCardAlt, child: imageWidget),
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
      decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    ),
  );
}

class _AddVoucherBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddVoucherBtn({required this.onTap});
  
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: kPurple, borderRadius: BorderRadius.circular(8)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, color: Colors.white, size: 14),
        SizedBox(width: 4),
        Text('ADD ITEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    ),
  );
}

class _SecTitle extends StatelessWidget {
  final String text;
  const _SecTitle(this.text);
  
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 14));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isNumber;
  final void Function(String)? onChanged;
  
  const _Field({
    required this.ctrl,
    required this.hint,
    this.isNumber = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    onChanged: onChanged,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: kTxt, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kTxtSub, fontSize: 13),
      filled: true,
      fillColor: kCardAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPurple, width: 1.5)),
    ),
  );
}

class _PriceInfo extends StatelessWidget {
  final String label;
  final int value;
  const _PriceInfo({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: kTxtSub, fontSize: 13)),
      Row(children: [
        Text('$value', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 4),
        const Icon(Icons.monetization_on, color: kGold, size: 16),
      ]),
    ],
  );
}

class _SolidBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _SolidBtn({required this.label, this.onTap});
  
  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: kPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.color, required this.onTap});
  
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: color),
      foregroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}