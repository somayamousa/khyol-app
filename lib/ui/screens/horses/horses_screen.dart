import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/horse_model.dart';

class HorsesScreen extends StatefulWidget {
  const HorsesScreen({super.key});

  @override
  State<HorsesScreen> createState() => _HorsesScreenState();
}

class _HorsesScreenState extends State<HorsesScreen> {
  bool _loading = true;
  List<HorseModel> _horses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.get(ApiConstants.horsesMarket);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _horses = (res.data!['horses'] as List? ?? []).map((e) => HorseModel.fromJson(e)).toList();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('سوق الخيول')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _horses.isEmpty
              ? const Center(child: Text('لا توجد خيول معروضة حالياً', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)))
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _horses.length,
                    itemBuilder: (ctx, i) {
                      final h = _horses[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/horse', arguments: h.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(14), bottomRight: Radius.circular(14)),
                                child: h.image != null
                                    ? CachedNetworkImage(imageUrl: h.image!, width: 110, height: 110, fit: BoxFit.cover)
                                    : Container(width: 110, height: 110, color: AppColors.bg3, child: const Center(child: Text('🐎', style: TextStyle(fontSize: 36)))),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(h.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                                          if (h.forSale)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.borderGold)),
                                              child: const Text('للبيع', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (h.breed != null) Text('السلالة: ${h.breed}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                                      if (h.age != null) Text('العمر: ${h.age} سنوات', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                                      if (h.city != null) Text('📍 ${h.city}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
                                      if (h.price != null) ...[
                                        const SizedBox(height: 6),
                                        Text('${h.price!.toInt()} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gold)),
                                      ],
                                    ],
                                  ),
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

