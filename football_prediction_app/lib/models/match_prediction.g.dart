// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchPrediction _$MatchPredictionFromJson(Map<String, dynamic> json) =>
    MatchPrediction(
      success: json['success'] as bool,
      match: Match.fromJson(json['match'] as Map<String, dynamic>),
      prediction: Prediction.fromJson(
        json['prediction'] as Map<String, dynamic>,
      ),
      timestamp: json['timestamp'] as String?,
      detailedAnalysis: json['detailed_analysis'] == null
          ? null
          : MatchAnalysis.fromJson(
              json['detailed_analysis'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MatchPredictionToJson(MatchPrediction instance) =>
    <String, dynamic>{
      'success': instance.success,
      'match': instance.match,
      'prediction': instance.prediction,
      'timestamp': instance.timestamp,
      'detailed_analysis': instance.detailedAnalysis,
    };

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
  homeTeam: json['home_team'] as String,
  awayTeam: json['away_team'] as String,
);

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
  'home_team': instance.homeTeam,
  'away_team': instance.awayTeam,
};

Prediction _$PredictionFromJson(Map<String, dynamic> json) => Prediction(
  homeGoals: (json['home_goals'] as num).toInt(),
  awayGoals: (json['away_goals'] as num).toInt(),
  result: json['result'] as String,
  resultText: json['result_text'] as String?,
  probabilities: Probabilities.fromJson(
    json['probabilities'] as Map<String, dynamic>,
  ),
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{
      'home_goals': instance.homeGoals,
      'away_goals': instance.awayGoals,
      'result': instance.result,
      'result_text': instance.resultText,
      'probabilities': instance.probabilities,
      'confidence': instance.confidence,
    };

Probabilities _$ProbabilitiesFromJson(Map<String, dynamic> json) =>
    Probabilities(
      home: (json['home'] as num).toDouble(),
      draw: (json['draw'] as num).toDouble(),
      away: (json['away'] as num).toDouble(),
    );

Map<String, dynamic> _$ProbabilitiesToJson(Probabilities instance) =>
    <String, dynamic>{
      'home': instance.home,
      'draw': instance.draw,
      'away': instance.away,
    };
