import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import 'clinic_detail_screen.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _clinics = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ClinicService.getClinics();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _clinics = List<Map<String, dynamic>>.from(res.data!['clinics'] ?? []);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('العيادات البيطرية')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _clinics.isEmpty
              ? const Center(child: Text('لا توجد عيادات متاحة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)))
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _clinics.length,
                    itemBuilder: (ctx, i) => _buildCard(_clinics[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ClinicDetailScreen(clinicId: c['id'])),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: const Center(child: Text('🩺', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  if (c['city'] != null) ...[
                    const SizedBox(height: 4),
                    Text('📍 ${c['city']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
                  ],
                  if (c['phone'] != null) ...[
                    const SizedBox(height: 4),
                    Text('📞 ${c['phone']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
