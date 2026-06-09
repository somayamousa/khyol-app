import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await NotificationService.getNotifications();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _items = List<Map<String, dynamic>>.from(res.data!['notifications'] ?? []);
    }
    setState(() => _loading = false);
  }

  Future<void> _markRead(int id, int index) async {
    await NotificationService.markRead(id);
    if (!mounted) return;
    setState(() => _items[index]['is_read'] = 1);
  }

  Future<void> _markAllRead() async {
    await ApiService.post('/notifications/mark_all_read.php', {});
    if (!mounted) return;
    setState(() {
      for (final n in _items) {
        n['is_read'] = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((n) => n['is_read'] == 0).length;

    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('قراءة الكل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.gold, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔔', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 12),
                      Text('لا توجد إشعارات', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.textMuted)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final n = _items[i];
                      final isRead = (n['is_read'] ?? 0) == 1;
                      return GestureDetector(
                        onTap: () {
                          if (!isRead) _markRead(n['id'], i);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isRead ? AppColors.card : AppColors.bg2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isRead ? AppColors.border : AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: isRead ? AppColors.bg3 : AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(_iconFor(n['type']), style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n['title'] ?? '',
                                        style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary)),
                                    if (n['body'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(n['body'],
                                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                                          maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                    if (n['created_at'] != null) ...[
                                      const SizedBox(height: 6),
                                      Text(n['created_at'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ],
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8, height: 8,
                                  margin: const EdgeInsets.only(top: 4, right: 4),
                                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
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

  String _iconFor(String? type) {
    switch (type) {
      case 'auction': return '🔨';
      case 'booking': return '📅';
      case 'order': return '📦';
      case 'message': return '💬';
      default: return '🔔';
    }
  }
}
