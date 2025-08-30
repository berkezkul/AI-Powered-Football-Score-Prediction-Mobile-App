/// Uygulama sabitleri
class AppConstants {
  AppConstants._();

  // API konfigürasyonu - Debug için değiştirildi
  static const String baseUrl = 'http://localhost:8000'; // Debug için localhost
  static const String baseUrlAndroid = 'http://10.0.2.2:8000'; // Android emulator için
  static const String baseUrlIOS = 'http://localhost:8000'; // iOS simulator için
  
  // API endpoints
  static const String predictEndpoint = '/predict';
  static const String teamsEndpoint = '/teams';
  static const String healthEndpoint = '/health';
  
  // Uygulama metinleri
  static const String appName = 'Premier League Predictor';
  static const String appSubtitle = 'AI ile Maç Tahmini';
  
  // Animasyon süreleri (milisaniye)
  static const int shortAnimationDuration = 300;
  static const int mediumAnimationDuration = 500;
  static const int longAnimationDuration = 800;
  
  // Timeout süreleri
  static const int apiTimeout = 10000; // 10 saniye
  static const int connectionTimeout = 5000; // 5 saniye
  
  // UI sabitleri
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  static const double smallBorderRadius = 8.0;
  
  // Font boyutları
  static const double titleFontSize = 24.0;
  static const double headingFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;
  
  // Takım logoları (placeholder)
  static const Map<String, String> teamLogos = {
    'Arsenal': '🔴',
    'Chelsea': '🔵',
    'Liverpool': '🔴',
    'Man City': '💙',
    'Man United': '🔴',
    'Tottenham': '⚪',
    'Newcastle': '⚫',
    'Brighton': '🔵',
    'Aston Villa': '🟣',
    'West Ham': '🟤',
  };
  
  // Hata mesajları
  static const String networkError = 'İnternet bağlantınızı kontrol edin';
  static const String serverError = 'Sunucuda bir hata oluştu';
  static const String timeoutError = 'İstek zaman aşımına uğradı';
  static const String unknownError = 'Bilinmeyen bir hata oluştu';
  
  // Başarı mesajları
  static const String predictionSuccess = 'Tahmin başarıyla alındı';
  static const String teamsLoaded = 'Takımlar yüklendi';
}