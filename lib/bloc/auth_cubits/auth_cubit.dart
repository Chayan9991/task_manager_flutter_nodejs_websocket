import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_state.dart';
import 'package:task_manager_flutter_nodejs/utils/api_constants.dart';

class AuthCubit extends Cubit<AuthState> {
  static const String _tokenKey = 'jwt_token';

  AuthCubit() : super(AuthInitial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String phoneNumber,
  ) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        }),
      );
      print('Register response: ${response.body}');

      if (response.statusCode == 200) {
        emit(AuthRegistered());
      } else {
        final error = jsonDecode(response.body)['msg'] ?? 'Registration failed';
        emit(AuthError(error));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);

          emit(AuthAuthenticated());
        } else {
          emit(AuthError('Invalid token from server'));
        }
      } else {
        final error = jsonDecode(response.body)['msg'] ?? 'Login failed';
        emit(AuthError(error));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    emit(AuthUnauthenticated());
  }
}
