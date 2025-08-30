import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/match_prediction.dart';
import '../models/team.dart';
import '../constants/app_constants.dart';
import 'mock_data_service.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);
  Dio? _dio;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio() {
    print('🔧 Creating new Dio instance...');
    
    final dio = Dio(BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptor for logging
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('🌐 DIO: $obj'),
      ),
    );
    
    print('✅ Dio initialized successfully');
    return dio;
  }

  /// Platform'a göre base URL seç
  String get baseUrl {
    // Android emulator için her zaman 10.0.2.2 kullan
    if (Platform.isAndroid) {
      return AppConstants.baseUrlAndroid; // 10.0.2.2 Android emulator için
    } else if (Platform.isIOS) {
      return AppConstants.baseUrlIOS; // localhost iOS simulator için
    }
    // Diğer platformlar için localhost
    return AppConstants.baseUrlIOS;
  }

  /// API sağlık kontrolü
  Future<bool> checkHealth() async {
    try {
      final url = '$baseUrl${AppConstants.healthEndpoint}';
      print('🔗 Platform: ${Platform.operatingSystem}');
      print('🔗 API URL deneniyor: $url');
      
      // Set base URL dynamically
      dio.options.baseUrl = baseUrl;
      
      final response = await dio.get(AppConstants.healthEndpoint);

      final isHealthy = response.statusCode == 200;
      print('💓 API Sağlık: ${isHealthy ? "✅ Sağlıklı" : "❌ Sorunlu"} (${response.statusCode})');
      if (isHealthy) {
        print('📋 API Response: ${response.data}');
      }
      return isHealthy;
    } catch (e) {
      print('❌ Health check failed: $e');
      if (e is DioException) {
        print('🔧 DioException: ${e.type}');
        print('🔧 Message: ${e.message}');
        if (e.response != null) {
          print('🔧 Response status: ${e.response?.statusCode}');
          print('🔧 Response data: ${e.response?.data}');
        }
      }
      print('🔧 Suggestion: Make sure API is running on http://localhost:8000');
      print('🔧 For Android emulator: API should be accessible via http://10.0.2.2:8000');
      return false;
    }
  }

  /// Takımları getir
  Future<List<String>> getTeams() async {
    try {
      final url = '$baseUrl${AppConstants.teamsEndpoint}';
      print('🔗 Teams URL: $url');
      
      // Set base URL dynamically
      dio.options.baseUrl = baseUrl;
      
      final response = await dio.get(AppConstants.teamsEndpoint);

      if (response.statusCode == 200) {
        final teamsResponse = TeamsResponse.fromJson(response.data);
        print('✅ Teams loaded: ${teamsResponse.count} teams');
        return teamsResponse.teams;
      } else {
        throw ApiException('Takımlar yüklenirken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('API hatası, mock data kullanılıyor: $e');
      // API çalışmadığında mock data döndür
      final mockResponse = MockDataService.getMockTeams();
      return mockResponse.teams;
    }
  }

  /// Maç tahmini al (GET)
  Future<MatchPrediction> getPrediction(String homeTeam, String awayTeam) async {
    try {
      final url = '$baseUrl${AppConstants.predictEndpoint}';
      print('🔗 Prediction URL: $url');
      print('🏟️ Match: $homeTeam vs $awayTeam');

      // Set base URL dynamically
      dio.options.baseUrl = baseUrl;

      final response = await dio.get(AppConstants.predictEndpoint, queryParameters: {
        'home': homeTeam,
        'away': awayTeam,
      });

      if (response.statusCode == 200) {
        print('✅ Prediction received successfully');
        return MatchPrediction.fromJson(response.data);
      } else {
        throw ApiException('Tahmin alınırken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('API hatası, mock prediction kullanılıyor: $e');
      if (e is DioException) {
        print('🔧 DioException type: ${e.type}');
        print('🔧 DioException message: ${e.message}');
      }
      // API çalışmadığında mock prediction döndür
      await Future.delayed(const Duration(seconds: 2)); // Gerçekçi gecikme
      return MockDataService.getMockPrediction(homeTeam, awayTeam);
    }
  }

  /// Maç tahmini al (POST)
  Future<MatchPrediction> postPrediction(String homeTeam, String awayTeam) async {
    try {
      final requestBody = {
        'home_team': homeTeam,
        'away_team': awayTeam,
      };

      // Set base URL dynamically
      dio.options.baseUrl = baseUrl;

      final response = await dio.post(AppConstants.predictEndpoint, data: requestBody);

      if (response.statusCode == 200) {
        return MatchPrediction.fromJson(response.data);
      } else {
        throw ApiException('Tahmin alınırken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('API hatası, mock prediction kullanılıyor: $e');
      if (e is DioException) {
        print('🔧 DioException type: ${e.type}');
        print('🔧 DioException message: ${e.message}');
      }
      // API çalışmadığında mock prediction döndür
      await Future.delayed(const Duration(seconds: 2)); // Gerçekçi gecikme
      return MockDataService.getMockPrediction(homeTeam, awayTeam);
    }
  }
}

/// API hata sınıfı
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
