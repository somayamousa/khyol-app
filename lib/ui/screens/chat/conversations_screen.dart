import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _convs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ChatService.getConversations();
    if (!mounted) return;
    if (res.success && res.data != null) {
      _convs = List<Map<String, dynamic>>.from(res.data!['conversations'] ?? []);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('المحادثات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _convs.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                    itemCount: _convs.length,
                    itemBuilder: (ctx, i) => _buildTile(_convs[i]),
                  ),
                ),
    );
  }

  Widget _buildTile(Map<String, dynamic> conv) {
    final unread = conv['unread_count'] ?? 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: AppColors.bg3,
        radius: 26,
        child: Text(
          (conv['other_name'] ?? conv['title'] ?? '?').toString().isNotEmpty
              ? (conv['other_name'] ?? conv['title'] ?? '?').toString()[0]
              : '?',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, color: AppColors.gold, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(
        conv['other_name'] ?? conv['title'] ?? 'محادثة',
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        conv['last_message'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
              child: Text('$unread', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.bg1, fontWeight: FontWeight.w700)),
            ),
          if (conv['last_at'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(conv['last_at'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textMuted)),
            ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv['id'],
            title: conv['other_name'] ?? conv['title'] ?? 'محادثة',
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('💬', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text('لا توجد محادثات بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 8),
          Text('ستظهر محادثاتك هنا', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
