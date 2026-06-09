import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';

class ClinicDetailScreen extends StatefulWidget {
  final int clinicId;
  const ClinicDetailScreen({super.key, required this.clinicId});

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends State<ClinicDetailScreen> {
  bool _loading = true;
  bool _booking = false;
  Map<String, dynamic>? _clinic;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ClinicService.getClinic(widget.clinicId);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _clinic = Map<String, dynamic>.from(res.data!['clinic'] ?? res.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _bookAppointment() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final dateCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: const Text('حجز موعد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateCtrl,
              style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'التاريخ (yyyy-mm-dd)', hintStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'ملاحظات (اختياري)', hintStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد الحجز', style: TextStyle(fontFamily: 'Cairo'))),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _booking = true);
    final res = await ClinicService.bookAppointment({
      'clinic_id': widget.clinicId,
      'date': dateCtrl.text.trim(),
      if (noteCtrl.text.trim().isNotEmpty) 'notes': noteCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _booking = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.success ? '✅ تم حجز الموعد' : (res.message ?? 'فشل الحجز'), style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: res.success ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    if (_clinic == null) return Scaffold(backgroundColor: AppColors.bg1, appBar: AppBar(title: const Text('العيادة')), body: const Center(child: Text('لم يتم العثور على العيادة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted))));

    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: Text(_clinic!['name'] ?? 'العيادة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: Column(
                children: [
                  const Text('🩺', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(_clinic!['name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
                  if (_clinic!['city'] != null) ...[
                    const SizedBox(height: 6),
                    Text('📍 ${_clinic!['city']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_clinic!['description'] != null) ...[
              const Text('عن العيادة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Text(_clinic!['description'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.8)),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  if (_clinic!['phone'] != null) _infoRow(Icons.phone_outlined, 'الهاتف', _clinic!['phone']),
                  if (_clinic!['address'] != null) _infoRow(Icons.location_on_outlined, 'العنوان', _clinic!['address']),
                  if (_clinic!['hours'] != null) _infoRow(Icons.access_time_outlined, 'ساعات العمل', _clinic!['hours']),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _booking ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _booking
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.bg1, strokeWidth: 2))
                    : const Text('📅 احجز موعداً الآن', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
              Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
