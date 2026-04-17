import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../models/itinerary.dart';
import '../models/comment.dart';
import '../models/vote.dart';
import '../models/notification.dart' as app;

class ApiService {
  late final Dio _dio;
  String? _accessToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && _accessToken != null) {
          // 可以在这里实现 refresh token 逻辑
        }
        handler.next(error);
      },
    ));
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
  }

  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  bool get isAuthenticated => _accessToken != null;

  // Auth
  Future<Map<String, dynamic>> register(String email, String password, String displayName) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    await setTokens(res.data['accessToken'], res.data['refreshToken']);
    return res.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await setTokens(res.data['accessToken'], res.data['refreshToken']);
    return res.data;
  }

  Future<User> getMe() async {
    final res = await _dio.get('/users/me');
    return User.fromJson(res.data);
  }

  // Trips
  Future<List<Trip>> getTrips() async {
    final res = await _dio.get('/trips');
    return (res.data as List).map((t) => Trip.fromJson(t)).toList();
  }

  Future<Trip> createTrip(Map<String, dynamic> data) async {
    final res = await _dio.post('/trips', data: data);
    return Trip.fromJson(res.data);
  }

  Future<Trip> getTrip(String id) async {
    final res = await _dio.get('/trips/$id');
    return Trip.fromJson(res.data);
  }

  Future<Trip> joinTrip(String inviteCode) async {
    final res = await _dio.post('/trips/join', data: {'inviteCode': inviteCode});
    return Trip.fromJson(res.data);
  }

  // Itineraries
  Future<List<Itinerary>> getItineraries(String tripId) async {
    final res = await _dio.get('/trips/$tripId/itineraries');
    return (res.data as List).map((i) => Itinerary.fromJson(i)).toList();
  }

  Future<Itinerary> createItinerary(String tripId, Map<String, dynamic> data) async {
    final res = await _dio.post('/trips/$tripId/itineraries', data: data);
    return Itinerary.fromJson(res.data);
  }

  Future<Itinerary> updateItinerary(String tripId, String id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/trips/$tripId/itineraries/$id', data: data);
    return Itinerary.fromJson(res.data);
  }

  Future<void> deleteItinerary(String tripId, String id) async {
    await _dio.delete('/trips/$tripId/itineraries/$id');
  }

  // Comments
  Future<List<Comment>> getComments(String itineraryId) async {
    final res = await _dio.get('/itineraries/$itineraryId/comments');
    return (res.data as List).map((c) => Comment.fromJson(c)).toList();
  }

  Future<Comment> createComment(String itineraryId, String content) async {
    final res = await _dio.post('/itineraries/$itineraryId/comments', data: {'content': content});
    return Comment.fromJson(res.data);
  }

  // Votes
  Future<List<Vote>> getVotes(String itineraryId) async {
    final res = await _dio.get('/itineraries/$itineraryId/votes');
    return (res.data as List).map((v) => Vote.fromJson(v)).toList();
  }

  Future<List<Vote>> vote(String itineraryId, String option) async {
    final res = await _dio.post('/itineraries/$itineraryId/votes', data: {'option': option});
    return (res.data as List).map((v) => Vote.fromJson(v)).toList();
  }

  // Notifications
  Future<List<app.AppNotification>> getNotifications() async {
    final res = await _dio.get('/notifications');
    return (res.data as List).map((n) => app.AppNotification.fromJson(n)).toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }
}
