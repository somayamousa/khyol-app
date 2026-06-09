import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.get('/bookings/my_bookings.php');
    if (!mounted) return;
    if (res.success && res.data != null) {
      _bookings = List<Map<String, dynamic>>.from(res.data!['bookings'] ?? []);
    }
    setState(() => _loading = false);
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'confirmed': return AppColors.success;
      case 'pending': return AppColors.gold;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textMuted;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'confirmed': return 'مؤكد ✅';
      case 'pending': return 'قيد المراجعة ⏳';
      case 'cancelled': return 'ملغى ❌';
      default: return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📅', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 12),
                      Text('لا توجد حجوزات', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.textMuted)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _bookings.length,
                    itemBuilder: (ctx, i) {
                      final b = _bookings[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(b['center_name'] ?? '',
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(b['status']).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _statusColor(b['status']).withValues(alpha: 0.4)),
                                  ),
                                  child: Text(_statusLabel(b['status']),
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: _statusColor(b['status']), fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 10),
                            if (b['package_title'] != null)
                              _row(Icons.local_offer_outlined, 'الباقة', b['package_title']),
                            if (b['booking_date'] != null)
                              _row(Icons.calendar_today_outlined, 'التاريخ', b['booking_date']),
                            if (b['booking_time'] != null)
                              _row(Icons.access_time_outlined, 'الوقت', b['booking_time']),
                            if (b['total_price'] != null)
                              _row(Icons.monetization_on_outlined, 'المبلغ',
                                  '${double.tryParse(b['total_price'].toString())?.toInt() ?? 0} ₪'),
                            if (b['notes'] != null && b['notes'].toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('ملاحظات: ${b['notes']}',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.gold),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
