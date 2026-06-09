import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _offers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await OfferService.getOffers();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _offers = List<Map<String, dynamic>>.from(res.data!['offers'] ?? []);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('العروض والتخفيضات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _offers.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _offers.length,
                    itemBuilder: (ctx, i) => _buildCard(_offers[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> offer) {
    final discount = offer['discount_pct'] ?? offer['discount'];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer['image'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: CachedNetworkImage(
                imageUrl: offer['image'],
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(height: 160, color: AppColors.bg3, child: const Center(child: Text('🏷', style: TextStyle(fontSize: 48)))),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(offer['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    if (discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                        child: Text('-$discount%', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                  ],
                ),
                if (offer['description'] != null) ...[
                  const SizedBox(height: 6),
                  Text(offer['description'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary, height: 1.6), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                if (offer['expires_at'] != null) ...[
                  const SizedBox(height: 8),
                  Text('⏰ ينتهي: ${offer['expires_at']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏷', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text('لا توجد عروض حالياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 8),
          Text('تابعنا لتصلك أحدث العروض', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
