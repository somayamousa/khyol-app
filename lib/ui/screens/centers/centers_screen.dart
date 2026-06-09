import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/center_model.dart';

class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key});
  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  bool _loading = true;
  List<CenterModel> _centers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await CenterService.getCenters();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _centers = (res.data!['centers'] as List? ?? []).map((e) => CenterModel.fromJson(e)).toList();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('مراكز الفروسية')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : RefreshIndicator(
              color: AppColors.gold,
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemCount: _centers.length,
                itemBuilder: (ctx, i) {
                  final c = _centers[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/center', arguments: c.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              c.image != null
                                  ? CachedNetworkImage(imageUrl: c.image!, height: 160, width: double.infinity, fit: BoxFit.cover)
                                  : Container(height: 160, color: AppColors.bg3, child: const Center(child: Text('🏇', style: TextStyle(fontSize: 48)))),
                              if (c.featured)
                                Positioned(top: 10, right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                                    child: const Text('⭐ مميز', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.bg1, fontWeight: FontWeight.w700)),
                                  )),
                              if (c.city != null)
                                Positioned(bottom: 10, left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                    child: Text('📍 ${c.city}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white)),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                if (c.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(c.description!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text('⭐', style: TextStyle(fontSize: 14)),
                                    Text(' ${c.rating}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.gold, fontWeight: FontWeight.w600)),
                                    Text(' (${c.reviewsCount})', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
                                    const Spacer(),
                                    const Text('التفاصيل والحجز ←', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
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
