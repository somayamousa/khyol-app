import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.get('${ApiConstants.baseUrl}/shop/my_orders.php');
    if (!mounted) return;
    if (res.success && res.data != null) {
      _orders = List<Map<String, dynamic>>.from(res.data!['orders'] ?? []);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('طلباتي')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _orders.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: _orders.length,
                    itemBuilder: (ctx, i) => _buildCard(_orders[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> order) {
    final status = order['status'] ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('طلب #${order['id']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 8),
          Text('${order['items_count'] ?? '-'} منتج', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي: ${order['total'] ?? '-'} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gold)),
              Text(order['created_at'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = AppColors.warning; label = 'قيد المعالجة';
        break;
      case 'shipped':
        color = AppColors.info; label = 'تم الشحن';
        break;
      case 'delivered':
        color = AppColors.success; label = 'تم التسليم';
        break;
      case 'cancelled':
        color = AppColors.error; label = 'ملغي';
        break;
      default:
        color = AppColors.textMuted; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📦', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text('لا توجد طلبات بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 8),
          Text('تسوّق الآن من متجرنا', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
