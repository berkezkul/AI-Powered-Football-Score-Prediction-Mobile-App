// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchAnalysis _$MatchAnalysisFromJson(Map<String, dynamic> json) =>
    MatchAnalysis(
      headToHead: HeadToHeadStats.fromJson(
        json['head_to_head'] as Map<String, dynamic>,
      ),
      teamForm: TeamFormStats.fromJson(
        json['team_form'] as Map<String, dynamic>,
      ),
      goalStats: GoalStats.fromJson(json['goal_stats'] as Map<String, dynamic>),
      interestingFacts: (json['interesting_facts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keyStats: KeyStats.fromJson(json['key_stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MatchAnalysisToJson(MatchAnalysis instance) =>
    <String, dynamic>{
      'head_to_head': instance.headToHead,
      'team_form': instance.teamForm,
      'goal_stats': instance.goalStats,
      'interesting_facts': instance.interestingFacts,
      'key_stats': instance.keyStats,
    };

HeadToHeadStats _$HeadToHeadStatsFromJson(Map<String, dynamic> json) =>
    HeadToHeadStats(
      totalMatches: (json['total_matches'] as num).toInt(),
      homeWins: (json['home_wins'] as num).toInt(),
      awayWins: (json['away_wins'] as num).toInt(),
      draws: (json['draws'] as num).toInt(),
      last5Results: (json['last_5_results'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      avgGoalsPerMatch: (json['avg_goals_per_match'] as num).toDouble(),
    );

Map<String, dynamic> _$HeadToHeadStatsToJson(HeadToHeadStats instance) =>
    <String, dynamic>{
      'total_matches': instance.totalMatches,
      'home_wins': instance.homeWins,
      'away_wins': instance.awayWins,
      'draws': instance.draws,
      'last_5_results': instance.last5Results,
      'avg_goals_per_match': instance.avgGoalsPerMatch,
    };

TeamFormStats _$TeamFormStatsFromJson(Map<String, dynamic> json) =>
    TeamFormStats(
      homeTeam: TeamForm.fromJson(json['home_team'] as Map<String, dynamic>),
      awayTeam: TeamForm.fromJson(json['away_team'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamFormStatsToJson(TeamFormStats instance) =>
    <String, dynamic>{
      'home_team': instance.homeTeam,
      'away_team': instance.awayTeam,
    };

TeamForm _$TeamFormFromJson(Map<String, dynamic> json) => TeamForm(
  last5Matches: (json['last_5_matches'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  goalsScoredLast5: (json['goals_scored_last_5'] as num).toInt(),
  goalsConcededLast5: (json['goals_conceded_last_5'] as num).toInt(),
  cleanSheetsLast10: (json['clean_sheets_last_10'] as num).toInt(),
  matchesWithBothTeamsScoring: (json['matches_with_both_teams_scoring'] as num)
      .toInt(),
  avgGoalsPerMatch: (json['avg_goals_per_match'] as num).toDouble(),
);

Map<String, dynamic> _$TeamFormToJson(TeamForm instance) => <String, dynamic>{
  'last_5_matches': instance.last5Matches,
  'goals_scored_last_5': instance.goalsScoredLast5,
  'goals_conceded_last_5': instance.goalsConcededLast5,
  'clean_sheets_last_10': instance.cleanSheetsLast10,
  'matches_with_both_teams_scoring': instance.matchesWithBothTeamsScoring,
  'avg_goals_per_match': instance.avgGoalsPerMatch,
};

GoalStats _$GoalStatsFromJson(Map<String, dynamic> json) => GoalStats(
  matchesOver25Goals: (json['matches_over_2_5_goals'] as num).toInt(),
  matchesUnder25Goals: (json['matches_under_2_5_goals'] as num).toInt(),
  bothTeamsToScorePercentage: (json['both_teams_to_score_percentage'] as num)
      .toDouble(),
  firstHalfGoalsAvg: (json['first_half_goals_avg'] as num).toDouble(),
  secondHalfGoalsAvg: (json['second_half_goals_avg'] as num).toDouble(),
);

Map<String, dynamic> _$GoalStatsToJson(GoalStats instance) => <String, dynamic>{
  'matches_over_2_5_goals': instance.matchesOver25Goals,
  'matches_under_2_5_goals': instance.matchesUnder25Goals,
  'both_teams_to_score_percentage': instance.bothTeamsToScorePercentage,
  'first_half_goals_avg': instance.firstHalfGoalsAvg,
  'second_half_goals_avg': instance.secondHalfGoalsAvg,
};

KeyStats _$KeyStatsFromJson(Map<String, dynamic> json) => KeyStats(
  homeTeamStrength: (json['home_team_strength'] as num).toDouble(),
  awayTeamStrength: (json['away_team_strength'] as num).toDouble(),
  homeAdvantage: (json['home_advantage'] as num).toDouble(),
  motivationFactor: json['motivation_factor'] as String,
  weatherImpact: json['weather_impact'] as String,
);

Map<String, dynamic> _$KeyStatsToJson(KeyStats instance) => <String, dynamic>{
  'home_team_strength': instance.homeTeamStrength,
  'away_team_strength': instance.awayTeamStrength,
  'home_advantage': instance.homeAdvantage,
  'motivation_factor': instance.motivationFactor,
  'weather_impact': instance.weatherImpact,
};
