import 'package:flutter/foundation.dart';
import '../models/match_prediction.dart';
import '../models/team.dart';
import '../services/api_service.dart';

enum PredictionState {
  initial,
  loading,
  loaded,
  error,
}

class PredictionViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // State
  PredictionState _state = PredictionState.initial;
  PredictionState get state => _state;
  
  // Data
  List<String> _teams = [];
  List<String> get teams => _teams;
  
  List<Team> _teamObjects = [];
  List<Team> get teamObjects => _teamObjects;
  
  MatchPrediction? _prediction;
  MatchPrediction? get prediction => _prediction;
  
  String? _selectedHomeTeam;
  String? get selectedHomeTeam => _selectedHomeTeam;
  
  String? _selectedAwayTeam;
  String? get selectedAwayTeam => _selectedAwayTeam;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool _isApiHealthy = false;
  bool get isApiHealthy => _isApiHealthy;

  // Computed properties
  bool get canPredict => 
      _selectedHomeTeam != null && 
      _selectedAwayTeam != null && 
      _selectedHomeTeam != _selectedAwayTeam;

  bool get isLoading => _state == PredictionState.loading;
  bool get hasError => _state == PredictionState.error;
  bool get hasPrediction => _prediction != null;

  /// API sağlığını kontrol et
  Future<void> checkApiHealth() async {
    try {
      _isApiHealthy = await _apiService.checkHealth();
      notifyListeners();
    } catch (e) {
      _isApiHealthy = false;
      notifyListeners();
    }
  }

  /// Takımları yükle
  Future<void> loadTeams() async {
    if (_state == PredictionState.loading) return;

    _setState(PredictionState.loading);
    _clearError();

    try {
      _teams = await _apiService.getTeams();
      _teamObjects = _teams.map((name) => Team.fromName(name)).toList();
      
      // Takımları alfabetik sırala
      _teamObjects.sort((a, b) => a.displayName.compareTo(b.displayName));
      _teams = _teamObjects.map((team) => team.name).toList();
      
      _setState(PredictionState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Ev sahibi takımı seç
  void selectHomeTeam(String? team) {
    if (_selectedHomeTeam != team) {
      _selectedHomeTeam = team;
      
      // Eğer aynı takım hem ev sahibi hem deplasman olarak seçildiyse, deplasman takımını temizle
      if (_selectedAwayTeam == team) {
        _selectedAwayTeam = null;
      }
      
      // Önceki tahmini temizle
      _prediction = null;
      notifyListeners();
    }
  }

  /// Deplasman takımı seç
  void selectAwayTeam(String? team) {
    if (_selectedAwayTeam != team) {
      _selectedAwayTeam = team;
      
      // Eğer aynı takım hem ev sahibi hem deplasman olarak seçildiyse, ev sahibi takımını temizle
      if (_selectedHomeTeam == team) {
        _selectedHomeTeam = null;
      }
      
      // Önceki tahmini temizle
      _prediction = null;
      notifyListeners();
    }
  }

  /// Takımları değiştir
  void swapTeams() {
    final temp = _selectedHomeTeam;
    _selectedHomeTeam = _selectedAwayTeam;
    _selectedAwayTeam = temp;
    
    // Önceki tahmini temizle
    _prediction = null;
    notifyListeners();
  }

  /// Tahmin al
  Future<void> getPrediction() async {
    if (!canPredict || _state == PredictionState.loading) return;

    _setState(PredictionState.loading);
    _clearError();

    try {
      _prediction = await _apiService.getPrediction(
        _selectedHomeTeam!,
        _selectedAwayTeam!,
      );
      _setState(PredictionState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Seçimleri temizle
  void clearSelections() {
    _selectedHomeTeam = null;
    _selectedAwayTeam = null;
    _prediction = null;
    _clearError();
    notifyListeners();
  }

  /// Tahmini temizle
  void clearPrediction() {
    _prediction = null;
    _clearError();
    notifyListeners();
  }

  /// Takımı isimle bul
  Team? getTeamByName(String name) {
    try {
      return _teamObjects.firstWhere((team) => team.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Rastgele takım seç (demo için)
  void selectRandomTeams() {
    if (_teams.length < 2) return;

    final shuffled = List<String>.from(_teams)..shuffle();
    _selectedHomeTeam = shuffled[0];
    _selectedAwayTeam = shuffled[1];
    _prediction = null;
    notifyListeners();
  }

  // Private methods
  void _setState(PredictionState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = PredictionState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
