import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ShopService.getCart();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _items = List<Map<String, dynamic>>.from(res.data!['items'] ?? []);
      _total = double.tryParse(res.data!['total']?.toString() ?? '0') ?? 0;
    }
    setState(() => _loading = false);
  }

  Future<void> _remove(int cartId) async {
    await ApiService.post(ApiConstants.cart, {'action': 'remove', 'cart_id': cartId});
    _load();
  }

  Future<void> _updateQty(int cartId, int qty) async {
    await ApiService.post(ApiConstants.cart, {'action': 'update', 'cart_id': cartId, 'quantity': qty});
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('السلة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛒', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      const Text('السلة فارغة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/shop'),
                        child: const Text('تسوق الآن'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: _items.length,
                        itemBuilder: (ctx, i) {
                          final item = _items[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(13), bottomRight: Radius.circular(13)),
                                  child: item['image'] != null
                                      ? CachedNetworkImage(imageUrl: item['image'], width: 90, height: 90, fit: BoxFit.cover)
                                      : Container(width: 90, height: 90, color: AppColors.bg3, child: const Icon(Icons.image_outlined, color: AppColors.textMuted)),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 6),
                                        Text('${double.tryParse(item['price'].toString())?.toInt() ?? 0} ₪',
                                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gold)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _qtyBtn(Icons.remove, () {
                                              final q = (item['quantity'] as int) - 1;
                                              if (q < 1) { _remove(item['id']); } else { _updateQty(item['id'], q); }
                                            }),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Text('${item['quantity']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                            ),
                                            _qtyBtn(Icons.add, () => _updateQty(item['id'], (item['quantity'] as int) + 1)),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () => _remove(item['id']),
                                              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // ملخص الطلب
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.bg2,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('المجموع', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.textSecondary)),
                              Text('${_total.toInt()} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gold)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/checkout'),
                              child: const Text('إتمام الطلب 🛒'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
        child: Icon(icon, size: 16, color: AppColors.gold),
      ),
    );
  }
}
