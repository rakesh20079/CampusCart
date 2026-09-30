import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static const String googleWebClientId =
      '426672383514-9o8eijmrdc3p0h0plb9hbv2v6psndv6m.apps.googleusercontent.com';

  final String baseUrl;
  final GoogleSignIn _googleSignIn;

  AuthService({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? AppConstants.defaultBaseUrl,
        _googleSignIn = GoogleSignIn(
          serverClientId: googleWebClientId,
          scopes: ['email', 'profile'],
        );

  Future<UserModel> signInWithGoogle() async {
    try {
      // Force account selection dialog by safely signing out if currently signed in
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      } catch (e) {
        debugPrint('SignOut prior to SignIn ignored: $e');
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Could not retrieve Google ID Token from device');
      }

      return await googleLogin(idToken);
    } catch (e) {
      debugPrint('AuthService.signInWithGoogle error: $e');
      rethrow;
    }
  }

  Future<UserModel> googleLogin(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      final dynamic rawData = jsonDecode(response.body);
      if (rawData is! Map<String, dynamic>) {
        throw Exception('Unexpected server response format');
      }

      final String? accessToken = rawData['accessToken'] as String?;
      final String? refreshToken = rawData['refreshToken'] as String?;
      final Map<String, dynamic>? userMap =
          rawData['user'] as Map<String, dynamic>?;

      if (accessToken == null || userMap == null) {
        throw Exception('Incomplete authentication response from server');
      }

      final user = UserModel.fromJson(userMap);

      await StorageService.saveAuthData(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
        user: user,
      );
      return user;
    } else {
      String errorMessage = 'Google login failed (${response.statusCode})';
      try {
        final dynamic err = jsonDecode(response.body);
        if (err is Map && err['message'] != null) {
          errorMessage = err['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }


  Future<bool> refreshToken() async {
    final currentRefreshToken = await StorageService.getRefreshToken();
    if (currentRefreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': currentRefreshToken}),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;
        final user =
            UserModel.fromJson(data['user'] as Map<String, dynamic>);

        await StorageService.saveAuthData(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('Logout Google error: $e');
    }
    await StorageService.clearAuth();
  }
}
