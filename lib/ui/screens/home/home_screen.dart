import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/center_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/auction_model.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/khyol_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<ProductModel> _featured = [];
  List<CenterModel> _centers = [];
  List<EventModel> _events = [];
  AuctionModel? _liveAuction;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await HomeService.getHomeData();
    if (!mounted) return;
    if (res.success && res.data != null) {
      final d = res.data!;
      setState(() {
        _featured = (d['featured'] as List? ?? []).map((e) => ProductModel.fromJson(e)).toList();
        _centers = (d['centers'] as List? ?? []).map((e) => CenterModel.fromJson(e)).toList();
        _events = (d['events'] as List? ?? []).map((e) => EventModel.fromJson(e)).toList();
        if (d['live_auction'] != null) {
          _liveAuction = AuctionModel.fromJson(d['live_auction']);
          _startCountdown();
        }
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _startCountdown() {
    _updateRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (_liveAuction == null) return;
    final diff = _liveAuction!.endsAt.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg1,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildServicesStrip()),
            if (_liveAuction != null) SliverToBoxAdapter(child: _buildLiveAuction()),
            SliverToBoxAdapter(child: _buildStats()),
            if (_featured.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(title: 'منتجات مختارة', subtitle: 'الأكثر تميزاً', onMore: () => Navigator.pushNamed(context, '/shop')),
              ),
              SliverToBoxAdapter(child: _buildProductsRow()),
            ],
            if (_centers.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(title: 'مراكز مميزة', subtitle: 'أفضل مراكز الفروسية', onMore: () => Navigator.pushNamed(context, '/centers')),
              ),
              SliverToBoxAdapter(child: _buildCentersRow()),
            ],
            if (_events.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(title: 'فعاليات قادمة', subtitle: 'لا تفوّت أهم الفعاليات', onMore: () => Navigator.pushNamed(context, '/events')),
              ),
              SliverToBoxAdapter(child: _buildEventsRow()),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.bg2,
      title: Row(
        children: [
          const Text('🐎', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('KHYOL', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
              Text('خيـول', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textSecondary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bg2, AppColors.bg3],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha:0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Text('✨ منصة الفروسية الأولى في فلسطين',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.gold)),
          ),
          const SizedBox(height: 16),
          const Text('عالم الفروسية\nبين يديك',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3)),
          const SizedBox(height: 12),
          const Text('اكتشف أفضل مراكز الفروسية، احجز دروسك، واقتنِ أفخر مستلزمات الخيول.',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/shop'),
                child: const Text('🛒 تسوق الآن'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('انضم إلينا'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesStrip() {
    final services = [
      {'icon': '🔨', 'title': 'المزاد', 'sub': 'زاحم على أفخر الخيول', 'route': '/auctions'},
      {'icon': '📸', 'title': 'التصوير', 'sub': 'جلسات مع ملابس مجانية', 'route': '/photographers'},
      {'icon': '🏇', 'title': 'الإيواء', 'sub': 'أودع فرسك واربح', 'route': '/boarding'},
      {'icon': '🩺', 'title': 'البيطرة', 'sub': 'دليل صحي للخيول', 'route': '/clinics'},
    ];
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: services.length,
        itemBuilder: (ctx, i) {
          final s = services[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, s['route']!),
            child: Container(
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['icon']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(s['title']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(s['sub']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveAuction() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha:0.5), width: 1.5),
      ),
      child: Column(
        children: [
          if (_liveAuction!.mainImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: _liveAuction!.mainImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                      child: const Text('⦿ LIVE', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_liveAuction!.title,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _auctionStat('السعر الحالي', '${_liveAuction!.displayPrice.toInt()} ₪'),
                    _auctionStat('المزايدات', '${_liveAuction!.bidsCount}'),
                    _auctionStat('الوقت المتبقي', _formatDuration(_remaining)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/auction', arguments: _liveAuction!.id),
                    child: const Text('دخول غرفة المزاد 🔨'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _auctionStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      {'num': '50+', 'lbl': 'مركز فروسية'},
      {'num': '1200+', 'lbl': 'عميل سعيد'},
      {'num': '300+', 'lbl': 'منتج متنوع'},
      {'num': '15+', 'lbl': 'مدينة فلسطينية'},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: stats.map((s) => Expanded(
          child: Column(
            children: [
              Text(s['num']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gold)),
              Text(s['lbl']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted), textAlign: TextAlign.center),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildProductsRow() {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _featured.length,
        itemBuilder: (ctx, i) => KhyolCard.product(_featured[i], onTap: () => Navigator.pushNamed(context, '/product', arguments: _featured[i].id)),
      ),
    );
  }

  Widget _buildCentersRow() {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _centers.length,
        itemBuilder: (ctx, i) => KhyolCard.center(_centers[i], onTap: () => Navigator.pushNamed(context, '/center', arguments: _centers[i].id)),
      ),
    );
  }

  Widget _buildEventsRow() {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _events.length,
        itemBuilder: (ctx, i) => KhyolCard.event(_events[i], onTap: () => Navigator.pushNamed(context, '/event', arguments: _events[i].id)),
      ),
    );
  }
}
