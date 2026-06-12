import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? accessToken;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.accessToken, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? accessToken, String? error}) {
    return AuthState(status: status ?? this.status, user: user ?? this.user, accessToken: accessToken ?? this.accessToken, error: error);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AuthState()) { _loadUser(); }

  Future<void> _loadUser() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      final userData = await storage.read(key: 'user_data');
      if (token != null && userData != null) {
        state = state.copyWith(status: AuthStatus.authenticated, accessToken: token, user: UserModel.fromJson(json.decode(userData)));
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {'email': email, 'password': password});
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = UserModel.fromJson(data['user']);
        final storage = ref.read(secureStorageProvider);
        await storage.write(key: 'access_token', value: data['accessToken']);
        await storage.write(key: 'refresh_token', value: data['refreshToken']);
        await storage.write(key: 'user_data', value: json.encode(data['user']));
        state = state.copyWith(status: AuthStatus.authenticated, user: user, accessToken: data['accessToken']);
      } else {
        state = state.copyWith(status: AuthStatus.error, error: response.data['message']);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Login failed. Please check your credentials.';
      state = state.copyWith(status: AuthStatus.error, error: msg);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: 'Login failed. Please check your credentials.');
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/register', data: data);
      if (response.data['success'] == true) {
        final respData = response.data['data'];
        final user = UserModel.fromJson(respData['user']);
        final storage = ref.read(secureStorageProvider);
        await storage.write(key: 'access_token', value: respData['accessToken']);
        await storage.write(key: 'refresh_token', value: respData['refreshToken']);
        await storage.write(key: 'user_data', value: json.encode(respData['user']));
        state = state.copyWith(status: AuthStatus.authenticated, user: user, accessToken: respData['accessToken']);
      } else {
        state = state.copyWith(status: AuthStatus.error, error: response.data['message']);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registration failed.';
      state = state.copyWith(status: AuthStatus.error, error: msg);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: 'Registration failed.');
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> forgotPassword(String email) async {
    final dio = ref.read(dioProvider);
    await dio.post('/auth/forgot-password', data: {'email': email});
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
