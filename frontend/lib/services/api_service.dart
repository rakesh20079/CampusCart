import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/contact_details_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class ApiService {
  final String baseUrl;

  ApiService({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? AppConstants.defaultBaseUrl;

  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await StorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/categories'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get Products with filtering
  Future<List<ProductModel>> getProducts({
    int page = 0,
    int size = 30,
    int? categoryId,
    String? query,
    String? campus,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
      };
      if (categoryId != null) queryParams['categoryId'] = categoryId.toString();
      if (query != null && query.trim().isNotEmpty) queryParams['query'] = query.trim();
      if (campus != null && campus.isNotEmpty && campus != 'All Campuses') queryParams['campus'] = campus;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/api/v1/products').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders(requireAuth: true));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get Product by ID
  Future<ProductModel?> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/products/$id'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create Listing
  Future<ProductModel?> createProduct({
    required String title,
    required String description,
    required double price,
    double? originalPrice,
    required String conditionGrade,
    required String campusLocation,
    String? contactPhone,
    String? contactWhatsapp,
    String? imageUrl,
    required int categoryId,
  }) async {
    final body = jsonEncode({
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'conditionGrade': conditionGrade,
      'campusLocation': campusLocation,
      'contactPhone': contactPhone,
      'contactWhatsapp': contactWhatsapp,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/products'),
      headers: await _getHeaders(requireAuth: true),
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Failed to list product (${response.statusCode})');
    }
  }

  // Reveal Contact (Student decides to buy / contact seller)
  Future<ContactDetailsModel> revealContact(int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/products/$productId/reveal-contact'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      return ContactDetailsModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get contact details (${response.statusCode})');
    }
  }

  // My Listings
  Future<List<ProductModel>> getMyListings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/products/my-listings'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Update Status (AVAILABLE / RESERVED / SOLD)
  Future<ProductModel?> updateProductStatus(int productId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/v1/products/$productId/status'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Delete Listing
  Future<bool> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/products/$productId'),
      headers: await _getHeaders(requireAuth: true),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  // Update Profile
  Future<UserModel?> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? whatsappNumber,
    String? campusName,
    String? dormOrHostel,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/users/me'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'whatsappNumber': whatsappNumber,
        'campusName': campusName,
        'dormOrHostel': dormOrHostel,
      }),
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(jsonDecode(response.body));
      await StorageService.saveUser(user);
      return user;
    }
    return null;
  }

  // Upload Product Image (Multipart)
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/v1/uploads'));
      final token = await StorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name.isNotEmpty ? imageFile.name : 'product_photo.jpg',
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String relativeUrl = data['url'] as String;
        if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) {
          return relativeUrl;
        }
        return '$baseUrl$relativeUrl';
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
