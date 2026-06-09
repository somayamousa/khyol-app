import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';

class HorseDetailScreen extends StatefulWidget {
  final int id;
  const HorseDetailScreen({super.key, required this.id});
  @override
  State<HorseDetailScreen> createState() => _HorseDetailScreenState();
}

class _HorseDetailScreenState extends State<HorseDetailScreen> {
  bool _loading = true;
  bool _sending = false;
  Map<String, dynamic>? _horse;
  final _msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await HorseService.getHorse(widget.id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _horse = Map<String, dynamic>.from(res.data!['horse'] ?? res.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _contactOwner() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) return;

    setState(() => _sending = true);
    final res = await HorseService.contactOwner(widget.id, msg);
    if (!mounted) return;
    setState(() => _sending = false);

    final messenger = ScaffoldMessenger.of(context);
    if (res.success) {
      _msgCtrl.clear();
      messenger.showSnackBar(const SnackBar(
        content: Text('تم إرسال رسالتك للمالك ✅', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success,
      ));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(res.message ?? 'فشل الإرسال', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    if (_horse == null) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: Text('الحصان غير موجود', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted))));

    final forSale = _horse!['for_sale'] == 1 || _horse!['for_sale'] == true;
    final price = double.tryParse(_horse!['price']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.bg2,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _horse!['image'] != null
                      ? CachedNetworkImage(imageUrl: _horse!['image'], fit: BoxFit.cover)
                      : Container(color: AppColors.bg3, child: const Center(child: Text('🐎', style: TextStyle(fontSize: 80)))),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  if (forSale)
                    Positioned(
                      top: 60, left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                        child: const Text('للبيع 🏷', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.bg1)),
                      ),
                    ),
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
                  // الاسم والسعر
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(_horse!['name'] ?? '',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                      if (forSale && price > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${price.toInt()} ₪',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gold)),
                            const Text('السعر', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // بطاقة المواصفات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderGold),
                    ),
                    child: Column(
                      children: [
                        _specRow('السلالة', _horse!['breed']),
                        _specRow('العمر', _horse!['age'] != null ? '${_horse!['age']} سنة' : null),
                        _specRow('الجنس', _horse!['gender'] == 'male' ? 'ذكر' : _horse!['gender'] == 'female' ? 'أنثى' : _horse!['gender']),
                        _specRow('اللون', _horse!['color']),
                        _specRow('المدينة', _horse!['city']),
                        _specRow('المالك', _horse!['owner_name']),
                      ].where((w) => w != null).cast<Widget>().toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_horse!['description'] != null) ...[
                    const Text('عن الحصان', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Text(_horse!['description'],
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.8)),
                    const SizedBox(height: 20),
                  ],
                  // تواصل مع المالك
                  const Text('تواصل مع المالك', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _msgCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'اكتب رسالتك للمالك...',
                            prefixIcon: Icon(Icons.chat_bubble_outline, color: AppColors.gold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _sending ? null : _contactOwner,
                            child: _sending
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.bg1, strokeWidth: 2))
                                : const Text('إرسال رسالة 📩'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _specRow(String label, String? value) {
    if (value == null || value.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
