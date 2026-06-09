import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class CenterDetailScreen extends StatefulWidget {
  final int id;
  const CenterDetailScreen({super.key, required this.id});
  @override
  State<CenterDetailScreen> createState() => _CenterDetailScreenState();
}

class _CenterDetailScreenState extends State<CenterDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _center;
  List _packages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await CenterService.getCenter(widget.id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _center = Map<String, dynamic>.from(res.data!['center']);
      _packages = _center!['packages'] ?? [];
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    if (_center == null) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: Text('المركز غير موجود', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted))));

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.bg2,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_center!['name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700)),
              background: _center!['image'] != null
                  ? CachedNetworkImage(imageUrl: _center!['image'], fit: BoxFit.cover)
                  : Container(color: AppColors.bg3, child: const Center(child: Text('🏇', style: TextStyle(fontSize: 60)))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تقييم ومدينة
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      Text(' ${_center!['rating'] ?? 0}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.gold, fontWeight: FontWeight.w700)),
                      Text(' (${_center!['reviews_count'] ?? 0} تقييم)', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
                      const Spacer(),
                      if (_center!['city'] != null)
                        Text('📍 ${_center!['city']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_center!['description'] != null) ...[
                    const Text('عن المركز', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(_center!['description'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                    const SizedBox(height: 20),
                  ],
                  if (_center!['phone'] != null) ...[
                    _infoRow(Icons.phone_outlined, _center!['phone']),
                    const SizedBox(height: 8),
                  ],
                  if (_center!['opening_hours'] != null) ...[
                    _infoRow(Icons.access_time_outlined, _center!['opening_hours']),
                    const SizedBox(height: 20),
                  ],
                  // باقات الحجز
                  if (_packages.isNotEmpty) ...[
                    const Text('باقات الحجز', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    ..._packages.map((pkg) => _packageCard(context, pkg)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary))),
      ],
    );
  }

  Widget _packageCard(BuildContext context, Map pkg) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/book', arguments: {'center_id': widget.id, 'package': pkg}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGold),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pkg['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  if (pkg['description'] != null)
                    Text(pkg['description'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${double.tryParse(pkg['price']?.toString() ?? '0')?.toInt() ?? 0} ₪',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
                const Text('احجز ←', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.gold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
