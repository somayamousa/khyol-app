import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.bg1,
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔐', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('سجّل دخولك للوصول لحسابك', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('تسجيل الدخول'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('إنشاء حساب جديد'),
              ),
            ],
          ),
        ),
      );
    }

    final user = auth.user!;
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        children: [
          // Profile header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.bg3,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Center(child: Text('👤', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(user.email, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
                      if (user.city != null)
                        Text('📍 ${user.city}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          _menuSection('الطلبات والحجوزات', [
            _menuItem(context, '🛒 طلباتي', '/orders'),
            _menuItem(context, '📅 حجوزاتي', '/bookings'),
            _menuItem(context, '🐎 خيولي', '/my-horses'),
          ]),
          _menuSection('الخدمات', [
            _menuItem(context, '🔔 الإشعارات', '/notifications'),
            _menuItem(context, '💬 المحادثات', '/chat'),
            _menuItem(context, '🔨 مزايداتي', '/my-bids'),
          ]),
          if (user.role == 'admin')
            _menuSection('الإدارة', [
              _menuItem(context, '👑 لوحة التحكم', '/admin'),
            ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _menuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _menuItem(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary))),
            const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
