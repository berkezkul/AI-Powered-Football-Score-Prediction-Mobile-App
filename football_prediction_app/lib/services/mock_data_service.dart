import '../models/match_prediction.dart';
import '../models/team.dart';

/// Mock data servisi - API çalışmadığında test için
class MockDataService {
  /// Mock takım listesi - Premier League takımları
  static const List<String> mockTeams = [
    'Arsenal',
    'Aston Villa',
    'Birmingham',
    'Blackburn',
    'Bolton',
    'Bournemouth',
    'Brighton',
    'Burnley',
    'Cardiff',
    'Chelsea',
    'Crystal Palace',
    'Derby',
    'Everton',
    'Fulham',
    'Hull',
    'Leicester',
    'Liverpool',
    'Man City',
    'Man United',
    'Middlesbrough',
    'Newcastle',
    'Norwich',
    'Portsmouth',
    'QPR',
    'Reading',
    'Sheffield United',
    'Southampton',
    'Stoke',
    'Sunderland',
    'Swansea',
    'Tottenham',
    'Watford',
    'West Ham',
    'Wigan',
    'Wolves',
  ];

  /// Mock takım listesi döndür
  static TeamsResponse getMockTeams() {
    return const TeamsResponse(
      success: true,
      count: 35,
      teams: mockTeams,
    );
  }

  /// Mock tahmin döndür
  static MatchPrediction getMockPrediction(String homeTeam, String awayTeam) {
    // Rastgele sonuçlar üret
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    final homeGoals = (random % 4);
    final awayGoals = (random % 3);
    
    String result;
    if (homeGoals > awayGoals) {
      result = 'H';
    } else if (awayGoals > homeGoals) {
      result = 'A';
    } else {
      result = 'D';
    }

    final homeProb = 0.3 + (random % 40) / 100.0;
    final awayProb = 0.2 + (random % 30) / 100.0;
    final drawProb = 1.0 - homeProb - awayProb;
    
    return MatchPrediction(
      success: true,
      match: Match(
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      ),
      prediction: Prediction(
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        result: result,
        resultText: _getResultText(result),
        probabilities: Probabilities(
          home: homeProb,
          draw: drawProb > 0 ? drawProb : 0.1,
          away: awayProb,
        ),
        confidence: 0.5 + (random % 30) / 100.0,
      ),
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  static String _getResultText(String result) {
    switch (result) {
      case 'H':
        return 'Ev Sahibi Galibiyeti';
      case 'D':
        return 'Beraberlik';
      case 'A':
        return 'Deplasman Galibiyeti';
      default:
        return 'Bilinmeyen';
    }
  }
}
