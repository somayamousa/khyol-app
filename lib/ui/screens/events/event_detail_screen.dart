import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';

class EventDetailScreen extends StatefulWidget {
  final int id;
  const EventDetailScreen({super.key, required this.id});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _loading = true;
  bool _registering = false;
  Map<String, dynamic>? _event;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await EventService.getEvent(widget.id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _event = Map<String, dynamic>.from(res.data!['event']);
    }
    setState(() => _loading = false);
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    setState(() => _registering = true);
    final res = await ApiService.post('/events/${widget.id}/register', {});
    if (!mounted) return;
    setState(() => _registering = false);
    final messenger = ScaffoldMessenger.of(context);
    if (res.success) {
      messenger.showSnackBar(SnackBar(
        content: Text(res.message ?? 'تم التسجيل في الفعالية ✅', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success,
      ));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(res.message ?? 'فشل التسجيل', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    if (_event == null) return const Scaffold(backgroundColor: AppColors.bg1, body: Center(child: Text('الفعالية غير موجودة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted))));

    final isFree = double.tryParse(_event!['price']?.toString() ?? '0') == 0;
    final price = double.tryParse(_event!['price']?.toString() ?? '0') ?? 0;
    DateTime? eventDate;
    try { eventDate = DateTime.parse(_event!['event_date'] ?? ''); } catch (_) {}

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.bg2,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _event!['image'] != null
                      ? CachedNetworkImage(imageUrl: _event!['image'], fit: BoxFit.cover)
                      : Container(color: AppColors.bg3, child: const Center(child: Text('🏆', style: TextStyle(fontSize: 60)))),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
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
                  // نوع الفعالية
                  if (_event!['type'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_event!['type_label'] ?? _event!['type'] ?? '',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
                    ),
                  Text(_event!['title'] ?? '',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  // بطاقة معلومات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderGold),
                    ),
                    child: Column(
                      children: [
                        if (eventDate != null)
                          _infoRow(Icons.calendar_today_outlined, 'التاريخ', DateFormat('EEEE، d MMMM yyyy', 'ar').format(eventDate)),
                        if (_event!['location'] != null)
                          _infoRow(Icons.location_on_outlined, 'الموقع', _event!['location']),
                        _infoRow(
                          isFree ? Icons.star_outline : Icons.monetization_on_outlined,
                          'الرسوم',
                          isFree ? 'مجاناً' : '${price.toInt()} ₪',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_event!['description'] != null) ...[
                    const Text('عن الفعالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Text(_event!['description'],
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.8)),
                    const SizedBox(height: 30),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registering ? null : _register,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _registering
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.bg1, strokeWidth: 2))
                          : Text(isFree ? 'سجل الآن مجاناً 🎟' : 'سجل الآن (${price.toInt()} ₪) 🎟',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
