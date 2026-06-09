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
}

class NotificationService {
  static Future<ApiResponse<Map<String, dynamic>>> getNotifications() =>
      ApiService.get(ApiConstants.notifications);

  static Future<ApiResponse<Map<String, dynamic>>> markRead(int id) =>
      ApiService.post(ApiConstants.markRead, {'id': id});
}
