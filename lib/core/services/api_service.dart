import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});
}

class ApiService {
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<ApiResponse<Map<String, dynamic>>> get(String url, {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return ApiResponse(success: false, message: 'خطأ في الاتصال: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> post(String url, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse(url), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _parse(res);
    } catch (e) {
      return ApiResponse(success: false, message: 'خطأ في الاتصال: $e');
    }
  }

  static ApiResponse<Map<String, dynamic>> _parse(http.Response res) {
    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final ok = res.statusCode >= 200 && res.statusCode < 300 && (data['success'] ?? true) != false;
      return ApiResponse(success: ok, data: data, message: data['message']);
    } catch (_) {
      return ApiResponse(success: false, message: 'خطأ في معالجة البيانات');
    }
  }
}

class AuthService {
  static Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) =>
      ApiService.post(ApiConstants.login, {'email': email, 'password': password});

  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? city,
  }) =>
      ApiService.post(ApiConstants.register, {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        if (city != null) 'city': city,
      });
}

class HomeService {
  static Future<ApiResponse<Map<String, dynamic>>> getHomeData() =>
      ApiService.get(ApiConstants.home);
}

class ShopService {
  static Future<ApiResponse<Map<String, dynamic>>> getProducts({int? categoryId, String? search}) =>
      ApiService.get(ApiConstants.products, params: {
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      });

  static Future<ApiResponse<Map<String, dynamic>>> getProduct(int id) =>
      ApiService.get(ApiConstants.product, params: {'id': id.toString()});

  static Future<ApiResponse<Map<String, dynamic>>> addToCart(int productId, int qty) =>
      ApiService.post(ApiConstants.cart, {'action': 'add', 'product_id': productId, 'quantity': qty});

  static Future<ApiResponse<Map<String, dynamic>>> getCart() =>
      ApiService.get(ApiConstants.cart);
}

class CenterService {
  static Future<ApiResponse<Map<String, dynamic>>> getCenters() =>
      ApiService.get(ApiConstants.centers);

  static Future<ApiResponse<Map<String, dynamic>>> getCenter(int id) =>
      ApiService.get(ApiConstants.center, params: {'id': id.toString()});

  static Future<ApiResponse<Map<String, dynamic>>> book(Map<String, dynamic> data) =>
      ApiService.post(ApiConstants.book, data);
}

class AuctionService {
  static Future<ApiResponse<Map<String, dynamic>>> getAuctions() =>
      ApiService.get(ApiConstants.auctions);

  static Future<ApiResponse<Map<String, dynamic>>> getAuction(int id) =>
      ApiService.get(ApiConstants.auction, params: {'id': id.toString()});

  static Future<ApiResponse<Map<String, dynamic>>> placeBid(int auctionId, double amount) =>
      ApiService.post(ApiConstants.bid, {'auction_id': auctionId, 'amount': amount});
}

class EventService {
  static Future<ApiResponse<Map<String, dynamic>>> getEvents() =>
      ApiService.get(ApiConstants.events);

  static Future<ApiResponse<Map<String, dynamic>>> getEvent(int id) =>
      ApiService.get(ApiConstants.event, params: {'id': id.toString()});
}

class HorseService {
  static Future<ApiResponse<Map<String, dynamic>>> getHorsesMarket() =>
      ApiService.get(ApiConstants.horsesMarket);

  static Future<ApiResponse<Map<String, dynamic>>> getHorse(int id) =>
      ApiService.get(ApiConstants.horse, params: {'id': id.toString()});

  static Future<ApiResponse<Map<String, dynamic>>> contactOwner(int horseId, String message) =>
      ApiService.post('${ApiConstants.baseUrl}/horses/contact.php', {'horse_id': horseId, 'message': message});
}

class ChatService {
  static Future<ApiResponse<Map<String, dynamic>>> getConversations() =>
      ApiService.get(ApiConstants.conversations);

  static Future<ApiResponse<Map<String, dynamic>>> getMessages(int conversationId) =>
      ApiService.get(ApiConstants.messages, params: {'conversation_id': conversationId.toString()});

  static Future<ApiResponse<Map<String, dynamic>>> sendMessage(int conversationId, String body) =>
      ApiService.post(ApiConstants.sendMessage, {'conversation_id': conversationId, 'body': body});
}

class ClinicService {
  static Future<ApiResponse<Map<String, dynamic>>> getClinics() =>
      ApiService.get(ApiConstants.clinics);

  static Future<ApiResponse<Map<String, dynamic>>> getClinic(int id) =>
      ApiService.get('${ApiConstants.baseUrl}/clinics/detail.php', params: {'id': id.toString()});

  static Future<ApiResponse<Map<String, dynamic>>> getAppointments() =>
      ApiService.get(ApiConstants.appointments);

  static Future<ApiResponse<Map<String, dynamic>>> bookAppointment(Map<String, dynamic> data) =>
      ApiService.post(ApiConstants.appointments, data);
}

class OfferService {
  static Future<ApiResponse<Map<String, dynamic>>> getOffers() =>
      ApiService.get(ApiConstants.offers);
}

class AccountService {
  static Future<ApiResponse<Map<String, dynamic>>> getProfile() =>
      ApiService.get(ApiConstants.account);

  static Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> data) =>
      ApiService.post(ApiConstants.updateAccount, data);

  static Future<ApiResponse<Map<String, dynamic>>> getMyBookings() =>
      ApiService.get(ApiConstants.myBookings);

  static Future<ApiResponse<Map<String, dynamic>>> getMyBids() =>
      ApiService.get('${ApiConstants.baseUrl}/auctions/my_bids.php');
}

class NotificationService {
  static Future<ApiResponse<Map<String, dynamic>>> getNotifications() =>
      ApiService.get(ApiConstants.notifications);

  static Future<ApiResponse<Map<String, dynamic>>> markRead(int id) =>
      ApiService.post(ApiConstants.markRead, {'id': id});
}
