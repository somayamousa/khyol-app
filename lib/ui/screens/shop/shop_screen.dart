import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/product_model.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _loading = true;
  List<ProductModel> _products = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String? search}) async {
    setState(() => _loading = true);
    final res = await ShopService.getProducts(search: search);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _products = (res.data!['products'] as List? ?? []).map((e) => ProductModel.fromJson(e)).toList();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(
        title: const Text('المتجر'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textMuted), onPressed: () { _searchCtrl.clear(); _load(); })
                    : null,
              ),
              onSubmitted: (v) => _load(search: v),
              onChanged: (v) { if (v.isEmpty) _load(); },
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _products.isEmpty
              ? const Center(child: Text('لا توجد منتجات', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)))
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (ctx, i) {
                      final p = _products[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/product', arguments: p.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: p.image != null
                                    ? CachedNetworkImage(imageUrl: p.image!, width: double.infinity, fit: BoxFit.cover)
                                    : Container(color: AppColors.bg3, child: const Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted))),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (p.categoryName != null)
                                      Text(p.categoryName!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.gold)),
                                    Text(p.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${p.price.toInt()} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
                                        GestureDetector(
                                          onTap: () async {
                                            final messenger = ScaffoldMessenger.of(context);
                                            await ShopService.addToCart(p.id, 1);
                                            messenger.showSnackBar(
                                              const SnackBar(content: Text('تمت الإضافة إلى السلة ✅', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.success, duration: Duration(seconds: 2)),
                                            );
                                          },
                                          child: Container(
                                            width: 30, height: 30,
                                            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.add, color: AppColors.bg1, size: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
