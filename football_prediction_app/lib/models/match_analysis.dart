import 'package:json_annotation/json_annotation.dart';

part 'match_analysis.g.dart';

@JsonSerializable()
class MatchAnalysis {
  @JsonKey(name: 'head_to_head')
  final HeadToHeadStats headToHead;
  
  @JsonKey(name: 'team_form')
  final TeamFormStats teamForm;
  
  @JsonKey(name: 'goal_stats')
  final GoalStats goalStats;
  
  @JsonKey(name: 'interesting_facts')
  final List<String> interestingFacts;
  
  @JsonKey(name: 'key_stats')
  final KeyStats keyStats;

  const MatchAnalysis({
    required this.headToHead,
    required this.teamForm,
    required this.goalStats,
    required this.interestingFacts,
    required this.keyStats,
  });

  factory MatchAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MatchAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$MatchAnalysisToJson(this);
}

@JsonSerializable()
class HeadToHeadStats {
  @JsonKey(name: 'total_matches')
  final int totalMatches;
  
  @JsonKey(name: 'home_wins')
  final int homeWins;
  
  @JsonKey(name: 'away_wins')
  final int awayWins;
  
  @JsonKey(name: 'draws')
  final int draws;
  
  @JsonKey(name: 'last_5_results')
  final List<String> last5Results;
  
  @JsonKey(name: 'avg_goals_per_match')
  final double avgGoalsPerMatch;

  const HeadToHeadStats({
    required this.totalMatches,
    required this.homeWins,
    required this.awayWins,
    required this.draws,
    required this.last5Results,
    required this.avgGoalsPerMatch,
  });

  factory HeadToHeadStats.fromJson(Map<String, dynamic> json) =>
      _$HeadToHeadStatsFromJson(json);

  Map<String, dynamic> toJson() => _$HeadToHeadStatsToJson(this);
}

@JsonSerializable()
class TeamFormStats {
  @JsonKey(name: 'home_team')
  final TeamForm homeTeam;
  
  @JsonKey(name: 'away_team')
  final TeamForm awayTeam;

  const TeamFormStats({
    required this.homeTeam,
    required this.awayTeam,
  });

  factory TeamFormStats.fromJson(Map<String, dynamic> json) =>
      _$TeamFormStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TeamFormStatsToJson(this);
}

@JsonSerializable()
class TeamForm {
  @JsonKey(name: 'last_5_matches')
  final List<String> last5Matches; // W, L, D
  
  @JsonKey(name: 'goals_scored_last_5')
  final int goalsScoredLast5;
  
  @JsonKey(name: 'goals_conceded_last_5')
  final int goalsConcededLast5;
  
  @JsonKey(name: 'clean_sheets_last_10')
  final int cleanSheetsLast10;
  
  @JsonKey(name: 'matches_with_both_teams_scoring')
  final int matchesWithBothTeamsScoring;
  
  @JsonKey(name: 'avg_goals_per_match')
  final double avgGoalsPerMatch;

  const TeamForm({
    required this.last5Matches,
    required this.goalsScoredLast5,
    required this.goalsConcededLast5,
    required this.cleanSheetsLast10,
    required this.matchesWithBothTeamsScoring,
    required this.avgGoalsPerMatch,
  });

  factory TeamForm.fromJson(Map<String, dynamic> json) =>
      _$TeamFormFromJson(json);

  Map<String, dynamic> toJson() => _$TeamFormToJson(this);
}

@JsonSerializable()
class GoalStats {
  @JsonKey(name: 'matches_over_2_5_goals')
  final int matchesOver25Goals;
  
  @JsonKey(name: 'matches_under_2_5_goals')
  final int matchesUnder25Goals;
  
  @JsonKey(name: 'both_teams_to_score_percentage')
  final double bothTeamsToScorePercentage;
  
  @JsonKey(name: 'first_half_goals_avg')
  final double firstHalfGoalsAvg;
  
  @JsonKey(name: 'second_half_goals_avg')
  final double secondHalfGoalsAvg;

  const GoalStats({
    required this.matchesOver25Goals,
    required this.matchesUnder25Goals,
    required this.bothTeamsToScorePercentage,
    required this.firstHalfGoalsAvg,
    required this.secondHalfGoalsAvg,
  });

  factory GoalStats.fromJson(Map<String, dynamic> json) =>
      _$GoalStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GoalStatsToJson(this);
}

@JsonSerializable()
class KeyStats {
  @JsonKey(name: 'home_team_strength')
  final double homeTeamStrength;
  
  @JsonKey(name: 'away_team_strength')
  final double awayTeamStrength;
  
  @JsonKey(name: 'home_advantage')
  final double homeAdvantage;
  
  @JsonKey(name: 'motivation_factor')
  final String motivationFactor;
  
  @JsonKey(name: 'weather_impact')
  final String weatherImpact;

  const KeyStats({
    required this.homeTeamStrength,
    required this.awayTeamStrength,
    required this.homeAdvantage,
    required this.motivationFactor,
    required this.weatherImpact,
  });

  factory KeyStats.fromJson(Map<String, dynamic> json) =>
      _$KeyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$KeyStatsToJson(this);
}
