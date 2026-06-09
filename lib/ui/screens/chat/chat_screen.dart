import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String title;
  const ChatScreen({super.key, required this.conversationId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _messages = [];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await ChatService.getMessages(widget.conversationId);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(res.data!['messages'] ?? []);
        _loading = false;
      });
      _scrollToBottom();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _poll() async {
    final res = await ChatService.getMessages(widget.conversationId);
    if (!mounted) return;
    if (res.success && res.data != null) {
      final newMsgs = List<Map<String, dynamic>>.from(res.data!['messages'] ?? []);
      if (newMsgs.length != _messages.length) {
        setState(() => _messages = newMsgs);
        _scrollToBottom();
      }
    }
  }

  Future<void> _send() async {
    final body = _ctrl.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    _ctrl.clear();
    final res = await ChatService.sendMessage(widget.conversationId, body);
    if (!mounted) return;
    setState(() => _sending = false);
    if (res.success) {
      await _poll();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'فشل الإرسال', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _messages.isEmpty
                    ? const Center(child: Text('لا توجد رسائل بعد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted)))
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) => _buildBubble(_messages[i]),
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final isMine = msg['is_mine'] == true || msg['is_mine'] == 1;
    return Align(
      alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMine ? AppColors.gold.withValues(alpha: 0.15) : AppColors.bg2,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine ? Radius.zero : const Radius.circular(16),
            bottomRight: isMine ? const Radius.circular(16) : Radius.zero,
          ),
          border: Border.all(color: isMine ? AppColors.borderGold : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg['body'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
            const SizedBox(height: 4),
            Text(msg['created_at'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                hintStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(24)),
              child: _sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.bg1, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: AppColors.bg1, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
