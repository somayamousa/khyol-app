import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';

class AuctionDetailScreen extends StatefulWidget {
  final int id;
  const AuctionDetailScreen({super.key, required this.id});
  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _auction;
  List _bids = [];
  Timer? _timer;
  Duration _remaining = Duration.zero;
  final _bidCtrl = TextEditingController();
  bool _bidding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await AuctionService.getAuction(widget.id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _auction = Map<String, dynamic>.from(res.data!['auction']);
      _bids = _auction!['recent_bids'] ?? [];
      _startTimer();
    }
    setState(() => _loading = false);
  }

  void _startTimer() {
    final endsAt = DateTime.tryParse(_auction!['ends_at'] ?? '');
    if (endsAt == null) return;
    _updateRemaining(endsAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining(endsAt);
    });
  }

  void _updateRemaining(DateTime endsAt) {
    final diff = endsAt.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _placeBid() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final amount = double.tryParse(_bidCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('أدخل مبلغ صحيح', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _bidding = true);
    final res = await AuctionService.placeBid(widget.id, amount);
    if (!mounted) return;
    setState(() => _bidding = false);
    if (res.success) {
      _bidCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.message ?? 'تمت المزايدة بنجاح ✅', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success,
      ));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.message ?? 'فشلت المزايدة', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    if (_auction == null) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: Text('المزاد غير موجود', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted))));

    final isLive = _auction!['status'] == 'live';
    final currentBid = double.tryParse(_auction!['current_bid']?.toString() ?? '0') ?? 0;
    final startingPrice = double.tryParse(_auction!['starting_price']?.toString() ?? '0') ?? 0;
    final displayPrice = currentBid > 0 ? currentBid : startingPrice;
    final minIncrement = double.tryParse(_auction!['min_increment']?.toString() ?? '1') ?? 1;

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.bg2,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _auction!['main_image'] != null
                      ? CachedNetworkImage(imageUrl: _auction!['main_image'], fit: BoxFit.cover)
                      : Container(color: AppColors.bg3, child: const Center(child: Text('🔨', style: TextStyle(fontSize: 60)))),
                  if (isLive)
                    Positioned(top: 60, right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                        child: const Text('⦿ LIVE', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_auction!['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  // إحصائيات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderGold)),
                    child: Row(
                      children: [
                        _stat('السعر الحالي', '${displayPrice.toInt()} ₪', AppColors.gold),
                        _divider(),
                        _stat('المزايدات', '${_auction!['bids_count'] ?? 0}', AppColors.textPrimary),
                        _divider(),
                        _stat('الوقت المتبقي', isLive ? _fmt(_remaining) : (_auction!['status'] == 'ended' ? 'انتهى' : 'لم يبدأ'), isLive ? AppColors.error : AppColors.textMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_auction!['description'] != null) ...[
                    const Text('تفاصيل المزاد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(_auction!['description'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                    const SizedBox(height: 20),
                  ],
                  // معلومات الحصان
                  if (_auction!['horse_name'] != null) ...[
                    const Text('معلومات الحصان', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Column(
                        children: [
                          _infoRow('الاسم', _auction!['horse_name']),
                          if (_auction!['horse_breed'] != null) _infoRow('السلالة', _auction!['horse_breed']),
                          if (_auction!['horse_gender'] != null) _infoRow('الجنس', _auction!['horse_gender'] == 'male' ? 'ذكر' : 'أنثى'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // صندوق المزايدة
                  if (isLive) ...[
                    const Text('ضع مزايدتك', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gold.withValues(alpha: 0.4))),
                      child: Column(
                        children: [
                          Text('الحد الأدنى: ${(displayPrice + minIncrement).toInt()} ₪',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _bidCtrl,
                                  keyboardType: TextInputType.number,
                                  textDirection: TextDirection.ltr,
                                  decoration: const InputDecoration(
                                    hintText: 'مبلغ المزايدة ₪',
                                    prefixIcon: Icon(Icons.monetization_on_outlined, color: AppColors.gold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _bidding ? null : _placeBid,
                                child: _bidding
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.bg1, strokeWidth: 2))
                                    : const Text('زايد 🔨'),
                              ),
                            ],
                          ),
                          // أزرار سريعة
                          const SizedBox(height: 10),
                          Row(
                            children: [100, 250, 500].map((inc) =>
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      final min = displayPrice + minIncrement;
                                      _bidCtrl.text = (min + inc).toInt().toString();
                                    },
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                                    child: Text('+$inc ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                                  ),
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // آخر المزايدات
                  if (_bids.isNotEmpty) ...[
                    const Text('آخر المزايدات', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ..._bids.take(5).map((b) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          const Text('🔨', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(b['bidder_name'] ?? 'مجهول', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary))),
                          Text('${double.tryParse(b['amount']?.toString() ?? '0')?.toInt() ?? 0} ₪',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(
    child: Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
      ],
    ),
  );

  Widget _divider() => Container(width: 1, height: 40, color: AppColors.border);

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    ),
  );
}
