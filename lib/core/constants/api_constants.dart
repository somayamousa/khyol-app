class ApiConstants {
  // غير هذا لـ IP الجهاز عند الاختبار على موبايل حقيقي
  // مثال: 'http://192.168.1.X/khyol_app/api'
  static const String baseUrl = 'http://10.0.2.2/khyol_app/api'; // للمحاكي

  // Auth
  static const String login = '$baseUrl/auth/login.php';
  static const String register = '$baseUrl/auth/register.php';
  static const String logout = '$baseUrl/auth/logout.php';

  // Home
  static const String home = '$baseUrl/home.php';

  // Shop
  static const String products = '$baseUrl/shop/products.php';
  static const String product = '$baseUrl/shop/product.php';
  static const String categories = '$baseUrl/shop/categories.php';

  // Cart
  static const String cart = '$baseUrl/shop/cart.php';

  // Centers
  static const String centers = '$baseUrl/centers/list.php';
  static const String center = '$baseUrl/centers/detail.php';

  // Horses
  static const String horsesMarket = '$baseUrl/horses/market.php';
  static const String myHorses = '$baseUrl/horses/my.php';

  // Auctions
  static const String auctions = '$baseUrl/auctions/list.php';
  static const String auction = '$baseUrl/auctions/detail.php';
  static const String bid = '$baseUrl/auctions/bid.php';

  // Events
  static const String events = '$baseUrl/events/list.php';
  static const String event = '$baseUrl/events/detail.php';

  // Chat
  static const String conversations = '$baseUrl/chat/conversations.php';
  static const String messages = '$baseUrl/chat/messages.php';
  static const String sendMessage = '$baseUrl/chat/send.php';

  // Clinics
  static const String clinics = '$baseUrl/clinics/list.php';
  static const String appointments = '$baseUrl/clinics/appointments.php';

  // Offers
  static const String offers = '$baseUrl/offers/list.php';

  // Notifications
  static const String notifications = '$baseUrl/notifications/list.php';
  static const String markRead = '$baseUrl/notifications/mark_read.php';

  // Booking
  static const String book = '$baseUrl/centers/book.php';
  static const String myBookings = '$baseUrl/centers/my_bookings.php';

  // Account
  static const String account = '$baseUrl/account/profile.php';
  static const String updateAccount = '$baseUrl/account/update.php';
}
