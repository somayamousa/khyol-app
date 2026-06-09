import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _bids = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await AccountService.getMyBids();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _bids = List<Map<String, dynamic>>.from(res.data!['bids'] ?? []);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('مزايداتي')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _bids.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: _bids.length,
                    itemBuilder: (ctx, i) => _buildCard(_bids[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> bid) {
    final isWinner = bid['is_winner'] == true || bid['is_winner'] == 1;
    final status = bid['auction_status'] ?? '';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/auction', arguments: bid['auction_id']),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isWinner ? AppColors.gold : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(bid['auction_title'] ?? 'مزاد', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ),
                if (isWinner)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderGold)),
                    child: const Text('🏆 فائز', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('مزايدتك', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
                    Text('${bid['amount'] ?? '-'} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('السعر الحالي', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
                    Text('${bid['current_bid'] ?? '-'} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                _statusBadge(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'active': color = AppColors.success; label = 'جارٍ';
        break;
      case 'ended': color = AppColors.textMuted; label = 'منتهٍ';
        break;
      default: color = AppColors.info; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔨', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text('لا توجد مزايدات بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 8),
          Text('شارك في مزاداتنا الآن', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
