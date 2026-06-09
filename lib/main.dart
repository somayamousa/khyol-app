import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'ui/screens/auth/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/home/main_shell.dart';
import 'ui/screens/shop/product_detail_screen.dart';
import 'ui/screens/shop/cart_screen.dart';
import 'ui/screens/centers/centers_screen.dart';
import 'ui/screens/centers/center_detail_screen.dart';
import 'ui/screens/horses/horses_screen.dart';
import 'ui/screens/horses/horse_detail_screen.dart';
import 'ui/screens/auctions/auctions_screen.dart';
import 'ui/screens/auctions/auction_detail_screen.dart';
import 'ui/screens/events/events_screen.dart';
import 'ui/screens/events/event_detail_screen.dart';
import 'ui/screens/notifications/notifications_screen.dart';
import 'ui/screens/bookings/my_bookings_screen.dart';
import 'ui/screens/bookings/booking_screen.dart';
import 'ui/screens/chat/conversations_screen.dart';
import 'ui/screens/clinics/clinics_screen.dart';
import 'ui/screens/offers/offers_screen.dart';
import 'ui/screens/account/my_orders_screen.dart';
import 'ui/screens/account/my_bids_screen.dart';

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
        '/cart': (_) => const CartScreen(),
        '/centers': (_) => const CentersScreen(),
        '/events': (_) => const EventsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/bookings': (_) => const MyBookingsScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/product':
            final id = settings.arguments as int? ?? 0;
            return MaterialPageRoute(builder: (_) => ProductDetailScreen(id: id));

          case '/center':
            final id = settings.arguments as int? ?? 0;
            return MaterialPageRoute(builder: (_) => CenterDetailScreen(id: id));

          case '/horse':
            final id = settings.arguments as int? ?? 0;
            return MaterialPageRoute(builder: (_) => HorseDetailScreen(id: id));

          case '/auction':
            final id = settings.arguments as int? ?? 0;
            return MaterialPageRoute(builder: (_) => AuctionDetailScreen(id: id));

          case '/event':
            final id = settings.arguments as int? ?? 0;
            return MaterialPageRoute(builder: (_) => EventDetailScreen(id: id));

          case '/book':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => BookingScreen(
                centerId: args['center_id'] as int? ?? 0,
                package: args['package'] as Map<String, dynamic>? ?? {},
              ),
            );

          case '/shop':
            return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1));

          case '/horses-market':
            return MaterialPageRoute(builder: (_) => const HorsesScreen());

          case '/auctions':
            return MaterialPageRoute(builder: (_) => const AuctionsScreen());

          case '/chat':
            return MaterialPageRoute(builder: (_) => const ConversationsScreen());
          case '/orders':
            return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
          case '/my-bids':
            return MaterialPageRoute(builder: (_) => const MyBidsScreen());
          case '/clinics':
            return MaterialPageRoute(builder: (_) => const ClinicsScreen());
          case '/offers':
            return MaterialPageRoute(builder: (_) => const OffersScreen());
          case '/my-horses':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('خيولي'));
          case '/photographers':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('التصوير'));
          case '/boarding':
            return MaterialPageRoute(builder: (_) => const _PlaceholderScreen('الإيواء والتدريب'));
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
