import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/auction_model.dart';

class AuctionsScreen extends StatefulWidget {
  const AuctionsScreen({super.key});

  @override
  State<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends State<AuctionsScreen> {
  bool _loading = true;
  List<AuctionModel> _auctions = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await AuctionService.getAuctions();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _auctions = (res.data!['auctions'] as List? ?? []).map((e) => AuctionModel.fromJson(e)).toList();
    }
    setState(() => _loading = false);
  }

  String _fmt(Duration d) {
    if (d.isNegative) return 'انتهى';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('المزادات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _auctions.isEmpty
              ? const Center(child: Text('لا توجد مزادات حالياً', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)))
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemCount: _auctions.length,
                    itemBuilder: (ctx, i) {
                      final a = _auctions[i];
                      final remaining = a.endsAt.difference(DateTime.now());
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/auction', arguments: a.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: a.isLive ? AppColors.gold.withValues(alpha: 0.6) : AppColors.border, width: a.isLive ? 1.5 : 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              if (a.mainImage != null)
                                Stack(
                                  children: [
                                    CachedNetworkImage(imageUrl: a.mainImage!, height: 170, width: double.infinity, fit: BoxFit.cover),
                                    if (a.isLive)
                                      Positioned(
                                        top: 10, right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                                          child: const Text('⦿ LIVE', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 10, left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                        child: Text(_fmt(remaining), style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('السعر الحالي', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
                                              Text('${a.displayPrice.toInt()} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('عدد المزايدات', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
                                            Text('${a.bidsCount}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                          ],
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
