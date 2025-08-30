import 'package:json_annotation/json_annotation.dart';
import 'match_analysis.dart';

part 'match_prediction.g.dart';

@JsonSerializable()
class MatchPrediction {
  @JsonKey(name: 'success')
  final bool success;
  
  @JsonKey(name: 'match')
  final Match match;
  
  @JsonKey(name: 'prediction')
  final Prediction prediction;
  
  @JsonKey(name: 'timestamp')
  final String? timestamp;
  
  @JsonKey(name: 'detailed_analysis')
  final MatchAnalysis? detailedAnalysis;

  const MatchPrediction({
    required this.success,
    required this.match,
    required this.prediction,
    this.timestamp,
    this.detailedAnalysis,
  });

  factory MatchPrediction.fromJson(Map<String, dynamic> json) =>
      _$MatchPredictionFromJson(json);

  Map<String, dynamic> toJson() => _$MatchPredictionToJson(this);
}

@JsonSerializable()
class Match {
  @JsonKey(name: 'home_team')
  final String homeTeam;
  
  @JsonKey(name: 'away_team')
  final String awayTeam;

  const Match({
    required this.homeTeam,
    required this.awayTeam,
  });

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  Map<String, dynamic> toJson() => _$MatchToJson(this);
}

@JsonSerializable()
class Prediction {
  @JsonKey(name: 'home_goals')
  final int homeGoals;
  
  @JsonKey(name: 'away_goals')
  final int awayGoals;
  
  @JsonKey(name: 'result')
  final String result; // 'H', 'D', 'A'
  
  @JsonKey(name: 'result_text')
  final String? resultText;
  
  @JsonKey(name: 'probabilities')
  final Probabilities probabilities;
  
  @JsonKey(name: 'confidence')
  final double confidence;

  const Prediction({
    required this.homeGoals,
    required this.awayGoals,
    required this.result,
    this.resultText,
    required this.probabilities,
    required this.confidence,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionToJson(this);

  /// Sonuç metnini döndürür
  String get resultDisplayText {
    switch (result) {
      case 'H':
        return 'Ev Sahibi Galibiyeti';
      case 'D':
        return 'Beraberlik';
      case 'A':
        return 'Deplasman Galibiyeti';
      default:
        return resultText ?? 'Bilinmeyen';
    }
  }

  /// Güven seviyesi kategorisi
  String get confidenceLevel {
    if (confidence >= 0.7) return 'Yüksek';
    if (confidence >= 0.5) return 'Orta';
    return 'Düşük';
  }

  /// Skor metni
  String get scoreText => '$homeGoals - $awayGoals';
}

@JsonSerializable()
class Probabilities {
  @JsonKey(name: 'home')
  final double home;
  
  @JsonKey(name: 'draw')
  final double draw;
  
  @JsonKey(name: 'away')
  final double away;

  const Probabilities({
    required this.home,
    required this.draw,
    required this.away,
  });

  factory Probabilities.fromJson(Map<String, dynamic> json) =>
      _$ProbabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$ProbabilitiesToJson(this);

  /// En yüksek olasılığa sahip sonucu döndürür
  String get mostLikely {
    if (home >= draw && home >= away) return 'H';
    if (draw >= home && draw >= away) return 'D';
    return 'A';
  }

  /// Yüzde cinsinden ev sahibi olasılığı
  int get homePercentage => (home * 100).round();
  
  /// Yüzde cinsinden beraberlik olasılığı
  int get drawPercentage => (draw * 100).round();
  
  /// Yüzde cinsinden deplasman olasılığı
  int get awayPercentage => (away * 100).round();
}