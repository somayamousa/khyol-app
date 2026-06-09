import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _loading = true;
  ProductModel? _product;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ShopService.getProduct(widget.id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _product = ProductModel.fromJson(res.data!['product']);
    }
    setState(() => _loading = false);
  }

  Future<void> _addToCart() async {
    if (_product == null) return;
    final messenger = ScaffoldMessenger.of(context);
    await ShopService.addToCart(_product!.id, _qty);
    messenger.showSnackBar(const SnackBar(
      content: Text('تمت الإضافة إلى السلة ✅', style: TextStyle(fontFamily: 'Cairo')),
      backgroundColor: AppColors.success,
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _product == null
              ? const Center(child: Text('المنتج غير موجود', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      backgroundColor: AppColors.bg2,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _product!.image != null
                            ? CachedNetworkImage(imageUrl: _product!.image!, fit: BoxFit.cover)
                            : Container(color: AppColors.bg3, child: const Center(child: Icon(Icons.image_outlined, size: 60, color: AppColors.textMuted))),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_product!.categoryName != null)
                              Text(_product!.categoryName!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.gold)),
                            const SizedBox(height: 6),
                            Text(_product!.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text('${_product!.price.toInt()} ₪',
                                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.gold)),
                                if (_product!.oldPrice != null) ...[
                                  const SizedBox(width: 10),
                                  Text('${_product!.oldPrice!.toInt()} ₪',
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.textMuted, decoration: TextDecoration.lineThrough)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      '${((_product!.oldPrice! - _product!.price) / _product!.oldPrice! * 100).round()}% خصم',
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 14)),
                                Text(' ${_product!.rating}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.gold, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (_product!.description != null) ...[
                              const Text('وصف المنتج', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              Text(_product!.description!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                              const SizedBox(height: 24),
                            ],
                            // الكمية
                            Row(
                              children: [
                                const Text('الكمية:', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 16),
                                _qtyBtn(Icons.remove, () { if (_qty > 1) setState(() => _qty--); }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('$_qty', style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                ),
                                _qtyBtn(Icons.add, () => setState(() => _qty++)),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _addToCart,
                                    icon: const Icon(Icons.shopping_cart_outlined),
                                    label: const Text('أضف إلى السلة'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                                  child: const Text('السلة'),
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
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.gold),
      ),
    );
  }
}
