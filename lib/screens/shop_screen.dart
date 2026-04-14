// ============================================================
// RPG Task Manager – Shop Screen (Updated with Yellow Theme)
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rpg_task_manager/controllers/item_shop_controller.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const kBg        = Color(0xFFF9F9F9); // Light background for the screen
const kCard      = Color.fromARGB(255, 225, 180, 254); // Your requested color (255, 235, 155)
const kCardAlt   = Color.fromARGB(255, 171, 155, 179); // Slightly darker for contrast 3 text field color
const kBorder    = Color.fromARGB(255, 0, 0, 0); // Gold/Brown border for visibility
const kPurple    = Color(0xFF7C3AED);
const kPurpleMid = Color(0xFF6D28D9); 
const kPurpleDim = Color(0xFF4C2A8A);
const kGold      = Color(0xFFB45309); // Darker gold for text readability
const kGreen     = Color(0xFF15803D);
const kRed       = Color(0xFFB91C1C);
const kBlue      = Color(0xFF1D4ED8);
const kTxt       = Color(0xFF000000); // Black text
const kTxtSub    = Color(0xFF4B5563); // Dark Grey subtext

// ─── Cart model ──────────────────────────────────────────────────────────────
class CartEntry {
  final String   id;
  final String   name;
  final String   subtitle;
  final int      price;
  final bool     isToken;
  final IconData? tokenIcon;
  final String?  imagePath;
  int qty;

  CartEntry({
    required this.id, required this.name, required this.subtitle,
    required this.price, required this.isToken,
    this.tokenIcon, this.imagePath, this.qty = 1,
  });
}

// ─── Static token items ───────────────────────────────────────────────────────
class _TDef {
  final String name, desc; final int price; final IconData icon;
  const _TDef(this.name, this.desc, this.price, this.icon);
}

const _tokenItems = [
  _TDef('Exp Booster Small',  'Improve your EXP collecting 1 day',   10, Icons.star_outline),
  _TDef('Exp Booster Big',    'Improve your EXP collecting 7 days',  40, Icons.star),
  _TDef('Token Booster Small','Improve your token collect 1 day',    10, Icons.toll_outlined),
  _TDef('Token Booster Big',  'Improve your token collect 7 days',   40, Icons.toll),
];

// ─── Custom item model ────────────────────────────────────────────────────────
class CustomItem {
  final String id;
  final String name, ability, description;
  final int price;
  final DateTime uploadedAt;
  final String? imagePath;
  int purchaseCount;

  CustomItem({
    required this.id, required this.name, required this.ability,
    required this.description, required this.price, required this.uploadedAt,
    this.imagePath, this.purchaseCount = 0,
  });

  bool get isNew => DateTime.now().difference(uploadedAt).inDays < 3;
}

const _abilities = [
  '0.1% EXP boost', '0.5% EXP boost', '1.0% EXP boost', '2.0% EXP boost',
  '0.1% Token boost','0.5% Token boost','1.0% Token boost','2.0% Token boost',
];

List<CustomItem> gCustomItems = [];
int gPlayerTokens = 6000;

// ─── ROOT ─────────────────────────────────────────────────────────────────────
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final List<CartEntry> _cart = [];

  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void dispose()   { _tab.dispose(); super.dispose(); }

  void _addToCart(CartEntry e) => setState(() {
    final ex = _cart.where((c) => c.id == e.id);
    if (ex.isEmpty) _cart.add(e); else ex.first.qty++;
  });

  int get _cartCount => _cart.fold(0, (s, e) => s + e.qty);
  int get _cartTotal => _cart.fold(0, (s, e) => s + e.price * e.qty);

  void _onBuyAll() {
    setState(() {
      for (final e in _cart) {
        if (!e.isToken) {
          final m = gCustomItems.where((c) => c.id == e.id);
          if (m.isNotEmpty) m.first.purchaseCount += e.qty;
        }
      }
      gPlayerTokens -= _cartTotal;
      _cart.clear();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Purchase successful! 🎉'),
        backgroundColor: kGreen, duration: Duration(seconds: 2)));
  }

  void _openCart() {
    showModalBottomSheet(
      context: context, backgroundColor: kBg, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (_, setBS) => _CartSheet(
          cart: _cart, playerTokens: gPlayerTokens,
          onQtyChange: () { setBS(() {}); setState(() {}); },
          onBuy: _onBuyAll,
        ),
      ),
    );
  }

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
            indicatorColor: kPurple, indicatorWeight: 3,
            labelColor: kPurple, unselectedLabelColor: kTxtSub,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [Tab(text: 'Token Shop'), Tab(text: 'Custom Shop')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _TokenShopTab(onAddToCart: _addToCart),
              _CustomShopTab(
                onAddToCart: _addToCart,
                onRefresh: () => setState(() {}),
                onViewDetail: (item) => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ItemDetailScreen(
                      item: item, playerTokens: gPlayerTokens,
                      onAddToCart: _addToCart,
                    ))),
                onNavigateAdd: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddItemScreen(
                        onItemAdded: (item) => setState(() => gCustomItems.add(item)),
                      )));
                },
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCart, backgroundColor: kPurple,
        child: Stack(alignment: Alignment.topRight, children: [
          const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.shopping_cart, color: Colors.white, size: 26)),
          if (_cartCount > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle),
              child: Text('$_cartCount', style: const TextStyle(
                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
        ]),
      ),
    );
  }
}

// ─── TOKEN SHOP TAB ───────────────────────────────────────────────────────────
class _TokenShopTab extends StatelessWidget {
  final void Function(CartEntry) onAddToCart;
  const _TokenShopTab({required this.onAddToCart});

  @override
  Widget build(BuildContext context){
    ItemShopController controller = context.watch<ItemShopController>();

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: _tokenItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = _tokenItems[i];
        return _ShopCard(
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: kCardAlt, borderRadius: BorderRadius.circular(8)),
            child: Icon(t.icon, color: kPurpleMid, size: 22),
          ),
          name: t.name, subtitle: t.desc, price: t.price, tags: const [],
          onAdd: () => onAddToCart(CartEntry(
            id: 'token_$i', name: t.name, subtitle: t.desc,
            price: t.price, isToken: true, tokenIcon: t.icon,
          )),
        );
      },
    );
  }
}

// ─── CUSTOM SHOP TAB ──────────────────────────────────────────────────────────
class _CustomShopTab extends StatefulWidget {
  final void Function(CartEntry) onAddToCart;
  final void Function(CustomItem) onViewDetail;
  final Future<void> Function() onNavigateAdd;
  final VoidCallback onRefresh;
  const _CustomShopTab({required this.onAddToCart, required this.onViewDetail,
      required this.onNavigateAdd, required this.onRefresh});
  @override State<_CustomShopTab> createState() => _CustomShopTabState();
}

class _CustomShopTabState extends State<_CustomShopTab> {
  List<CustomItem> get _best {
    final s = [...gCustomItems]..sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
    return s.where((e) => e.purchaseCount > 0).take(2).toList();
  }

  Set<String> get _bestIds => _best.map((e) => e.id).toSet();

  List<CustomItem> get _rest => gCustomItems.where((e) => !_bestIds.contains(e.id)).toList()
    ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

  Widget _card(CustomItem item) {
    final isBest = _bestIds.contains(item.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _ShopCard(
        leading: _Avatar(imagePath: item.imagePath, size: 50),
        name: item.name, subtitle: item.ability, price: item.price,
        tags: [
          if (isBest) const _TagSpec('Best', Colors.red),
          if (!isBest && item.isNew) const _TagSpec('New', Colors.blue),
        ],
        onDetail: () => widget.onViewDetail(item),
        onAdd: () => widget.onAddToCart(CartEntry(
          id: item.id, name: item.name, subtitle: item.ability,
          price: item.price, isToken: false, imagePath: item.imagePath,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_best.isNotEmpty) ...[
          const _SecTitle('Best Custom Item of week:'),
          const SizedBox(height: 8),
          ..._best.map(_card),
          const SizedBox(height: 16),
        ],
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const _SecTitle('All Custom Items:'),
          _AddItemBtn(onTap: () async { await widget.onNavigateAdd(); setState(() {}); }),
        ]),
        const SizedBox(height: 8),
        if (gCustomItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Column(children: [
              Icon(Icons.add_box_outlined, color: kTxtSub, size: 42),
              SizedBox(height: 10),
              Text('No items yet.\nTap +ADD Item to create one.',
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

// ─── ADD ITEM SCREEN ──────────────────────────────────────────────────────────
class AddItemScreen extends StatefulWidget {
  final void Function(CustomItem) onItemAdded;
  const AddItemScreen({super.key, required this.onItemAdded});
  @override State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String? _ability;
  File?   _image;
  static const double _feeRate = 0.15;

  int get _price    => int.tryParse(_priceCtrl.text) ?? 0;
  int get _receive  => (_price * (1 - _feeRate)).toInt();
  int get _fee      => (_price * _feeRate).toInt();

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (p != null) setState(() => _image = File(p.path));
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _ability == null || _price == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fill in name, ability and price.'), backgroundColor: kRed));
      return;
    }
    widget.onItemAdded(CustomItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(), ability: _ability!,
      description: _descCtrl.text.trim(), price: _price,
      uploadedAt: DateTime.now(), imagePath: _image?.path,
    ));
    Navigator.pop(context);
  }

  @override void dispose() { _nameCtrl.dispose(); _priceCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        iconTheme: const IconThemeData(color: kTxt),
        title: const Text('Add Custom Item', style: TextStyle(color: kTxt, fontWeight: FontWeight.bold)),
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
                    decoration: BoxDecoration(color: const Color.fromARGB(255, 171, 155, 179), borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
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
                _Field(ctrl: _nameCtrl, hint: 'Enter Your Item Name'),
                const SizedBox(height: 8),
                _Dropdown(value: _ability, onChanged: (v) => setState(() => _ability = v)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _Field(ctrl: _priceCtrl, hint: 'Buy item price', isNumber: true, onChanged: (_) => setState(() {}))),
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
            height: 100, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 171, 155, 179), borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
            child: TextField(
              controller: _descCtrl, maxLines: null, expands: true,
              style: const TextStyle(color: kTxt, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Enter Your Item description',
                hintStyle: TextStyle(color: kTxtSub, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 171, 155, 179), borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
            child: _PriceInfo(label: 'To upload you pay:', value: _fee),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: _OutlineBtn(label: 'Back', color: kRed, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _SolidBtn(label: 'Upload Item', onTap: _submit)),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ─── ITEM DETAIL SCREEN ───────────────────────────────────────────────────────
class ItemDetailScreen extends StatelessWidget {
  final CustomItem item;
  final int playerTokens;
  final void Function(CartEntry) onAddToCart;
  const ItemDetailScreen({super.key, required this.item, required this.playerTokens, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final canBuy = playerTokens >= item.price;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        iconTheme: const IconThemeData(color: kTxt),
        title: const Text('Item Detail', style: TextStyle(color: kTxt, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: double.infinity, height: 180,
              child: item.imagePath != null
                  ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
                  : Container(color: kCardAlt, child: const Icon(Icons.person, color: kPurpleMid, size: 64))),
          ),
          const SizedBox(height: 12),
          Text(item.name, style: const TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(item.ability, style: const TextStyle(color: kPurpleMid, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
            child: Text(item.description.isEmpty ? 'No description.' : item.description,
                style: const TextStyle(color: kTxt, fontSize: 13, height: 1.5)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
            child: Column(children: [
              _SimpleRow('Item Cost', '${item.price}', kGold),
              const Divider(color: kBorder, height: 14),
              _SimpleRow('Your Token', '$playerTokens', kGold,
                  suffix: canBuy ? ' Buyable' : ' Not Buyable',
                  suffixColor: canBuy ? kGreen : kRed),
            ]),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: _OutlineBtn(label: 'Back', color: kRed, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _SolidBtn(label: '+ADD Cart', onTap: () {
              onAddToCart(CartEntry(id: item.id, name: item.name, subtitle: item.ability, price: item.price, isToken: false, imagePath: item.imagePath));
              Navigator.pop(context);
            })),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ─── CART BOTTOM SHEET ────────────────────────────────────────────────────────
class _CartSheet extends StatelessWidget {
  final List<CartEntry> cart;
  final int playerTokens;
  final VoidCallback onQtyChange;
  final VoidCallback onBuy;
  const _CartSheet({required this.cart, required this.playerTokens, required this.onQtyChange, required this.onBuy});

  int get _total => cart.fold(0, (s, e) => s + e.price * e.qty);
  bool get _canBuy => playerTokens >= _total;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCard, // Yellow background for cart
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.68),
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('Cart Items', style: TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 16)))),
        cart.isEmpty
          ? const Padding(padding: EdgeInsets.all(32),
              child: Text('Your cart is empty', style: TextStyle(color: kTxtSub)))
          : Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cart.length,
                itemBuilder: (_, i) {
                  final e = cart[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      _Avatar(imagePath: e.imagePath, tokenIcon: e.tokenIcon, size: 40),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.name, style: const TextStyle(color: kTxt, fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(e.subtitle, style: const TextStyle(color: kPurpleMid, fontSize: 11)),
                      ])),
                      Row(children: [
                        Text('${e.price}', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        _QtyBtn('-', () { if (e.qty > 1) e.qty--; else cart.removeAt(i); onQtyChange(); }),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${e.qty}', style: const TextStyle(color: kTxt, fontWeight: FontWeight.bold))),
                        _QtyBtn('+', () { e.qty++; onQtyChange(); }),
                      ]),
                    ]),
                  );
                },
              ),
            ),
        const Divider(color: kBorder, height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            _SimpleRow('Total Cost', '$_total', kGold),
            const SizedBox(height: 4),
            _SimpleRow('Your Token', '$playerTokens', kGold, suffix: _canBuy ? ' Buyable' : ' Not Buyable', suffixColor: _canBuy ? kGreen : kRed),
          ]),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: _OutlineBtn(label: 'Back', color: kRed, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: _SolidBtn(label: 'Buy Item', onTap: (cart.isEmpty || !_canBuy) ? null : onBuy)),
          ]),
        ),
      ]),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _ShopCard extends StatelessWidget {
  final Widget leading; final String name, subtitle; final int price; final List<_TagSpec> tags;
  final VoidCallback? onDetail; final VoidCallback onAdd;
  const _ShopCard({required this.leading, required this.name, required this.subtitle, required this.price, required this.tags, required this.onAdd, this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Row(children: [
        leading, const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTxt, fontWeight: FontWeight.w600, fontSize: 13))),
            const SizedBox(width: 4),
            if (onDetail != null) _DetailBtn(onTap: onDetail!),
            for (final t in tags) ...[const SizedBox(width: 4), _TagWidget(t.label, t.color)],
          ]),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: kPurpleMid, fontSize: 11)),
        ])),
        const SizedBox(width: 6),
        Row(children: [
          Text('$price', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 3),
          const Icon(Icons.monetization_on, color: kGold, size: 14),
          const SizedBox(width: 6),
          _PlusBtn(onTap: onAdd),
        ]),
      ]),
    );
  }
}

class _TagSpec { final String label; final Color color; const _TagSpec(this.label, this.color); }

class _TagWidget extends StatelessWidget {
  final String label; final Color color;
  const _TagWidget(this.label, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
  );
}

class _Avatar extends StatelessWidget {
  final String? imagePath; final IconData? tokenIcon; final double size;
  const _Avatar({this.imagePath, this.tokenIcon, required this.size});
  @override Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(width: size, height: size,
      child: imagePath != null ? Image.file(File(imagePath!), fit: BoxFit.cover) : Container(color: kCardAlt, child: Icon(tokenIcon ?? Icons.person, color: kPurpleMid, size: size * 0.55))),
  );
}

class _DetailBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _DetailBtn({required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: kPurple, borderRadius: BorderRadius.circular(5)),
      child: const Text('Detail', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  );
}

class _PlusBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _PlusBtn({required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 26, height: 26, decoration: BoxDecoration(color: kPurple, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.add, color: Colors.white, size: 18)),
  );
}

class _QtyBtn extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _QtyBtn(this.label, this.onTap);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 24, height: 24, decoration: BoxDecoration(color: kCardAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: kBorder)),
      child: Center(child: Text(label, style: const TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 14)))),
  );
}

class _AddItemBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddItemBtn({required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: kPurple, borderRadius: BorderRadius.circular(8)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, color: Colors.white, size: 14),
        SizedBox(width: 4),
        Text('+ADD Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    ),
  );
}

class _SecTitle extends StatelessWidget {
  final String text;
  const _SecTitle(this.text);
  @override Widget build(BuildContext context) => Text(text, style: const TextStyle(color: kTxt, fontWeight: FontWeight.bold, fontSize: 14));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl; final String hint; final bool isNumber; final void Function(String)? onChanged;
  const _Field({required this.ctrl, required this.hint, this.isNumber = false, this.onChanged});

  @override Widget build(BuildContext context) => TextField(
    controller: ctrl, onChanged: onChanged,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: kTxt, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: kTxtSub, fontSize: 13),
      filled: true, fillColor: kCardAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPurple, width: 1.5)),
    ),
  );
}

class _Dropdown extends StatelessWidget {
  final String? value; final void Function(String?) onChanged;
  const _Dropdown({required this.value, required this.onChanged});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: kCardAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
    child: DropdownButton<String>(
      value: value, isExpanded: true, dropdownColor: const Color.fromARGB(255, 171, 155, 179), underline: const SizedBox(),
      hint: const Text('Select Item Ability', style: TextStyle(color: kTxtSub, fontSize: 13)),
      items: _abilities.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: kTxt, fontSize: 13)))).toList(),
      onChanged: onChanged,
    ),
  );
}

class _PriceInfo extends StatelessWidget {
  final String label; final int value;
  const _PriceInfo({required this.label, required this.value});
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(color: kTxtSub, fontSize: 13)),
    Row(children: [
      Text('$value', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(width: 4),
      const Icon(Icons.monetization_on, color: kGold, size: 16),
    ]),
  ]);
}

class _SimpleRow extends StatelessWidget {
  final String label, value; final Color valColor; final String? suffix; final Color? suffixColor;
  const _SimpleRow(this.label, this.value, this.valColor, {this.suffix, this.suffixColor});
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(color: kTxtSub, fontSize: 13)),
    Row(children: [
      Text(value, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(width: 4),
      const Icon(Icons.monetization_on, color: kGold, size: 14),
      if (suffix != null) Text(suffix!, style: TextStyle(color: suffixColor, fontSize: 11, fontWeight: FontWeight.bold)),
    ]),
  ]);
}

class _SolidBtn extends StatelessWidget {
  final String label; final VoidCallback? onTap;
  const _SolidBtn({required this.label, this.onTap});
  @override Widget build(BuildContext context) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(backgroundColor: kPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

class _OutlineBtn extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.color, required this.onTap});
  @override Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(side: BorderSide(color: color), foregroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}