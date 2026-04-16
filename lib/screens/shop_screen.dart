// ============================================================
// RPG Task Manager – Shop Screen (Updated with Vouchers)
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/item_shop_controller.dart';
import 'package:rpg_task_manager/controllers/user_controller.dart';
import 'package:rpg_task_manager/helpers/app_colors.dart';
import 'package:rpg_task_manager/models/item/item.dart';
import 'package:rpg_task_manager/models/item/voucher.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const kBg        = Color(0xFFF9F9F9);
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

// Global vouchers list (will be stored in Hive later)
List<Voucher> gVouchers = [];

// ─── ROOT ─────────────────────────────────────────────────────────────────────
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final UserController _userController;

  @override 
  void initState() { 
    super.initState(); 
    _tab = TabController(length: 2, vsync: this); 
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userController = context.read<UserController>();
  }

  @override 
  void dispose() { 
    _tab.dispose(); 
    super.dispose(); 
  }

  // Buy REAL items (XP/Gold boosts)
  void _buyShopItem(Item item) {
    if (_userController.spendGolds(item.priceGold)) {
      // _applyBoost(item);
      _userController.addItem(item);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Purchased ${item.name}!', style: TextStyle(color: AppColors.primaryLight)),
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

  // Buy VOUCHERS (user-created rewards)
  void _buyVoucher(Voucher voucher) {
    if (_userController.spendGolds(voucher.priceGold)) {
      _userController.addVoucher(voucher);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Voucher purchased: ${voucher.name}! Redeem it from your profile.'),
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

  // void _applyBoost(Item item) {
  //   // Apply XP or Gold boost logic here
  //   if (item.name.contains('EXP')) {
  //     _userController.addExpBoost(item.boostValue ?? 0);
  //   } else if (item.name.contains('Token')) {
  //     _userController.addGoldBoost(item.boostValue ?? 0);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
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
              Tab(text: '🛒 Item Shop'), 
              Tab(text: '🎫 Voucher Shop')
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _TokenShopTab(onBuy: _buyShopItem),
              _VoucherShopTab(
                onBuyVoucher: _buyVoucher,
                onRefresh: () => setState(() {}),
                onViewDetail: (voucher) => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => VoucherDetailScreen(
                      voucher: voucher,
                      playerGold: _userController.user.golds,
                      onBuy: _buyVoucher,
                    ))),
                onNavigateAdd: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddVoucherScreen(
                        onVoucherAdded: (voucher) => setState(() => gVouchers.add(voucher)),
                      )));
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── ITEM SHOP TAB (Boosts) ───────────────────────────────────────────────────
class _TokenShopTab extends StatelessWidget {
  final void Function(Item item) onBuy;
  const _TokenShopTab({required this.onBuy});

  @override
  Widget build(BuildContext context){
    ItemShopController controller = context.watch<ItemShopController>();
    final items = controller.items;

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = items[i];
        return _ShopItemCard(
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: kCardAlt, borderRadius: BorderRadius.circular(8)),
            child: Image.asset(item.imageUrl),
          ),
          name: item.name,
          subtitle: item.description,
          price: item.priceGold,
          onBuy: () => onBuy(item),
        );
      },
    );
  }
}

// ─── VOUCHER SHOP TAB ─────────────────────────────────────────────────────────
class _VoucherShopTab extends StatefulWidget {
  final void Function(Voucher) onBuyVoucher;
  final void Function(Voucher) onViewDetail;
  final Future<void> Function() onNavigateAdd;
  final VoidCallback onRefresh;
  
  const _VoucherShopTab({
    required this.onBuyVoucher,
    required this.onViewDetail,
    required this.onNavigateAdd,
    required this.onRefresh,
  });
  
  @override
  State<_VoucherShopTab> createState() => _VoucherShopTabState();
}

class _VoucherShopTabState extends State<_VoucherShopTab> {
  List<Voucher> get _best {
    final s = [...gVouchers]..sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
    return s.where((e) => e.purchaseCount > 0).take(2).toList();
  }

  Set<String> get _bestIds => _best.map((e) => e.id).toSet();

  List<Voucher> get _rest => gVouchers.where((e) => !_bestIds.contains(e.id)).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Widget _card(Voucher voucher) {
    final isBest = _bestIds.contains(voucher.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _VoucherCard(
        leading: _Avatar(imagePath: voucher.imagePath, size: 50),
        name: voucher.name,
        subtitle: voucher.description,
        price: voucher.priceGold,
        tags: [
          if (isBest) const _TagSpec('Popular', Colors.red),
          if (!isBest && voucher.isNew) const _TagSpec('New', Colors.blue),
        ],
        onDetail: () => widget.onViewDetail(voucher),
        onBuy: () => widget.onBuyVoucher(voucher),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_best.isNotEmpty) ...[
          const _SecTitle('🔥 Most Popular Vouchers:'),
          const SizedBox(height: 8),
          ..._best.map(_card),
          const SizedBox(height: 16),
        ],
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const _SecTitle('📜 All Vouchers:'),
          _AddVoucherBtn(onTap: () async { 
            await widget.onNavigateAdd(); 
            setState(() {}); 
          }),
        ]),
        const SizedBox(height: 8),
        if (gVouchers.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Column(children: [
              Icon(Icons.local_activity_outlined, color: kTxtSub, size: 42),
              SizedBox(height: 10),
              Text('No vouchers yet.\nCreate custom rewards for completing tasks!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTxtSub, fontSize: 13, height: 1.5)),
            ])),
          )
        else
          ..._rest.map(_card),
      ]),
    );
  }
}

// ─── ADD VOUCHER SCREEN ───────────────────────────────────────────────────────
class AddVoucherScreen extends StatefulWidget {
  final void Function(Voucher) onVoucherAdded;
  const AddVoucherScreen({super.key, required this.onVoucherAdded});
  
  @override
  State<AddVoucherScreen> createState() => _AddVoucherScreenState();
}

class _AddVoucherScreenState extends State<AddVoucherScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  File? _image;
  static const double _feeRate = 0.15;

  int get _price => int.tryParse(_priceCtrl.text) ?? 0;
  int get _receive => (_price * (1 - _feeRate)).toInt();
  int get _fee => (_price * _feeRate).toInt();

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (p != null) setState(() => _image = File(p.path));
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _price == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fill in name and price.'), backgroundColor: kRed));
      return;
    }
    
    widget.onVoucherAdded(Voucher(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priceGold: _price,
      createdAt: DateTime.now(),
      imagePath: _image?.path,
    ));
    Navigator.pop(context);
  }

  @override 
  void dispose() { 
    _nameCtrl.dispose(); 
    _priceCtrl.dispose(); 
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
        title: const Text('Create Voucher', style: TextStyle(color: kTxt, fontWeight: FontWeight.bold)),
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
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
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
                _Field(ctrl: _nameCtrl, hint: 'Voucher Name (e.g., "1 Hour Gaming")'),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _Field(ctrl: _priceCtrl, hint: 'Price (Gold)', isNumber: true, onChanged: (_) => setState(() {}))),
                  const SizedBox(width: 6),
                  const Icon(Icons.monetization_on, color: kGold, size: 20),
                ]),
                const SizedBox(height: 8),
                _PriceInfo(label: 'You receive:', value: _receive),
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
                hintText: 'What can the user do with this voucher?',
                hintStyle: TextStyle(color: kTxtSub, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kCardAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder)
            ),
            child: _PriceInfo(label: 'Upload fee (15%):', value: _fee),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: _OutlineBtn(label: 'Cancel', color: kRed, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _SolidBtn(label: 'Create Voucher', onTap: _submit)),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ─── VOUCHER DETAIL SCREEN ────────────────────────────────────────────────────
class VoucherDetailScreen extends StatelessWidget {
  final Voucher voucher;
  final int playerGold;
  final void Function(Voucher) onBuy;
  
  const VoucherDetailScreen({
    super.key,
    required this.voucher,
    required this.playerGold,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canBuy = playerGold >= voucher.priceGold;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        iconTheme: const IconThemeData(color: kTxt),
        title: const Text('Voucher Details', style: TextStyle(color: kTxt, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: double.infinity, height: 180,
              child: voucher.imagePath != null
                  ? Image.file(File(voucher.imagePath!), fit: BoxFit.cover)
                  : Container(color: kCardAlt, child: const Icon(Icons.local_activity, color: kPurpleMid, size: 64))),
          ),
          const SizedBox(height: 12),
          Text(voucher.name, style: const TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder)
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('What you can do:', style: TextStyle(color: kPurpleMid, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              Text(voucher.description.isEmpty ? 'No description.' : voucher.description,
                  style: const TextStyle(color: kTxt, fontSize: 13, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder)
            ),
            child: Column(children: [
              _SimpleRow('Price', '${voucher.priceGold}', kGold),
              const Divider(color: kBorder, height: 14),
              _SimpleRow('Your Gold', '$playerGold', kGold,
                  suffix: canBuy ? ' Available' : ' Not enough',
                  suffixColor: canBuy ? kGreen : kRed),
            ]),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: _OutlineBtn(label: 'Back', color: kRed, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _SolidBtn(label: 'PURCHASE VOUCHER', onTap: canBuy ? () {
              onBuy(voucher);
              Navigator.pop(context);
            } : null)),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _ShopItemCard extends StatelessWidget {
  final Widget leading;
  final String name, subtitle;
  final int price;
  final VoidCallback onBuy;
  
  const _ShopItemCard({
    required this.leading,
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
            Text(name,
              style: const TextStyle(color: kTxt, fontWeight: FontWeight.w600, fontSize: 13)
            ),
            const SizedBox(height: 3),
            Text(subtitle,
              style: const TextStyle(color: kPurpleMid, fontSize: 11),
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

class _VoucherCard extends StatelessWidget {
  final Widget leading;
  final String name, subtitle;
  final int price;
  final List<_TagSpec> tags;
  final VoidCallback? onDetail;
  final VoidCallback onBuy;
  
  const _VoucherCard({
    required this.leading,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.tags,
    required this.onBuy,
    this.onDetail,
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
            Row(children: [
              Flexible(
                child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kTxt, fontWeight: FontWeight.w600, fontSize: 13)
                ),
              ),
              const SizedBox(width: 4),
              if (onDetail != null) _DetailBtn(onTap: onDetail!),
              for (final t in tags) ...[
                const SizedBox(width: 4),
                _TagWidget(t.label, t.color)
              ],
            ]),
            const SizedBox(height: 3),
            Text(subtitle,
              style: const TextStyle(color: kTxtSub, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            Text('$price', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 3),
            const Icon(Icons.monetization_on, color: kGold, size: 14),
          ]),
          const SizedBox(height: 4),
          _BuyBtn(onTap: onBuy, label: 'REDEEM'),
        ]),
      ]),
    );
  }
}

class _TagSpec { 
  final String label; 
  final Color color; 
  const _TagSpec(this.label, this.color); 
}

class _TagWidget extends StatelessWidget {
  final String label;
  final Color color;
  const _TagWidget(this.label, this.color);
  
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
  );
}

class _Avatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  const _Avatar({this.imagePath, required this.size});
  
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(width: size, height: size,
      child: imagePath != null 
          ? Image.file(File(imagePath!), fit: BoxFit.cover) 
          : Container(color: kCardAlt, child: const Icon(Icons.local_activity, color: kPurpleMid, size: 28))),
  );
}

class _DetailBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _DetailBtn({required this.onTap});
  
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: kPurple, borderRadius: BorderRadius.circular(5)),
      child: const Text('Detail', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  );
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
        Text('+ADD Voucher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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

class _SimpleRow extends StatelessWidget {
  final String label, value;
  final Color valColor;
  final String? suffix;
  final Color? suffixColor;
  
  const _SimpleRow(this.label, this.value, this.valColor, {this.suffix, this.suffixColor});
  
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: kTxtSub, fontSize: 13)),
      Row(children: [
        Text(value, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13)),
        if (suffix != null) Text(suffix!, style: TextStyle(color: suffixColor, fontSize: 11, fontWeight: FontWeight.bold)),
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