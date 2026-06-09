import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/event_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _loading = true;
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await EventService.getEvents();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _events = (res.data!['events'] as List? ?? []).map((e) => EventModel.fromJson(e)).toList();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('الفعاليات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _events.isEmpty
              ? const Center(child: Text('لا توجد فعاليات قادمة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)))
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemCount: _events.length,
                    itemBuilder: (ctx, i) {
                      final e = _events[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/event', arguments: e.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              // تاريخ الفعالية
                              Container(
                                width: 70,
                                color: AppColors.gold,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(DateFormat('dd').format(e.eventDate),
                                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.bg1)),
                                    Text(DateFormat('MMM', 'ar').format(e.eventDate),
                                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.bg1)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(e.typeLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(e.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      if (e.description != null)
                                        Text(e.description!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            e.isFree ? '🎟 مجاناً' : '🎟 ${e.price.toInt()} ₪',
                                            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: e.isFree ? AppColors.success : AppColors.gold),
                                          ),
                                          const Spacer(),
                                          const Text('التفاصيل ←', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.gold)),
                                        ],
                                      ),
                                    ],
                                  ),
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
