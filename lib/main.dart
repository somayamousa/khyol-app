import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'ui/screens/auth/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/home/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const KhyolApp(),
    ),
  );
}

class KhyolApp extends StatelessWidget {
  const KhyolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHYOL - خيول',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: const Locale('ar', 'PS'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainShell(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/product':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('تفاصيل المنتج'));
          case '/center':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('تفاصيل المركز'));
          case '/centers':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('المراكز'));
          case '/horse':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('تفاصيل الحصان'));
          case '/auction':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('المزاد'));
          case '/event':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('الفعالية'));
          case '/events':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('الفعاليات'));
          case '/shop':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('المتجر'));
          case '/cart':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('السلة'));
          case '/chat':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('المحادثات'));
          case '/notifications':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('الإشعارات'));
          case '/orders':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('طلباتي'));
          case '/bookings':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('حجوزاتي'));
          case '/my-horses':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('خيولي'));
          case '/my-bids':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('مزايداتي'));
          case '/photographers':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('التصوير'));
          case '/boarding':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('الإيواء والتدريب'));
          case '/clinics':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('العيادات البيطرية'));
          case '/admin':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('لوحة التحكم'));
          default:
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('الصفحة غير موجودة'));
        }
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFF5EDD8))),
            const SizedBox(height: 8),
            const Text('قريباً...', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF7A7260))),
          ],
        ),
      ),
    );
  }
}
