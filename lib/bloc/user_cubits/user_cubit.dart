import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/api_constants.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  Future<void> fetchUser() async {
  emit(UserLoading());

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) {
    emit(UserError("Token not found"));
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/currentUser'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final name = data['name'];
      final id = data['_id'] ?? data['id'];

      if (name != null && id != null) {
        emit(UserLoaded(name, id));
      } else {
        emit(UserError("Invalid user data"));
      }
    } else {
      emit(UserError("Failed to load user"));
    }
  } catch (e) {
    emit(UserError(e.toString()));
  }
}


  Future<String?> fetchUsernameById(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['name'];
      } else {
        print("Failed to fetch user name: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }
}
