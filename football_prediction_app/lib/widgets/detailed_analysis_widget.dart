import 'package:flutter/material.dart';
import '../models/match_analysis.dart';
import '../models/team.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class DetailedAnalysisWidget extends StatelessWidget {
  final MatchAnalysis analysis;
  final String homeTeam;
  final String awayTeam;

  const DetailedAnalysisWidget({
    super.key,
    required this.analysis,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 8 : AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Head-to-Head Stats
          _buildHeadToHeadStats(),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Team Form Comparison
          _buildTeamFormComparison(),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Goal Statistics
          _buildGoalStatistics(),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Interesting Facts
          _buildInterestingFacts(),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Key Statistics
          _buildKeyStatistics(),
          
          const SizedBox(height: AppConstants.defaultPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.largeBorderRadius),
          topRight: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.analytics,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          const Text(
            'Detaylı Maç Analizi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppConstants.headingFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'AI Analizi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadToHeadStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Karşılaşma Geçmişi (Son ${analysis.headToHead.totalMatches} Maç)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppConstants.bodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // H2H Stats Grid - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 350) {
                // Small screen: Stack vertically
                return Column(
                  children: [
                    _buildStatCard(
                      '${analysis.headToHead.homeWins}',
                      'Ev Sahibi Galibiyeti',
                      AppColors.success,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.headToHead.draws}',
                            'Beraberlik',
                            AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.headToHead.awayWins}',
                            'Deplasman\nGalibiyeti',
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Large screen: Side by side
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '${analysis.headToHead.homeWins}',
                        'Ev Sahibi\nGalibiyeti',
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '${analysis.headToHead.draws}',
                        'Beraberlik',
                        AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '${analysis.headToHead.awayWins}',
                        'Deplasman\nGalibiyeti',
                        AppColors.error,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Average Goals
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ortalama Gol Sayısı:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppConstants.smallFontSize,
                  ),
                ),
                Text(
                  '${analysis.headToHead.avgGoalsPerMatch.toStringAsFixed(1)} gol/maç',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppConstants.smallFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Last 5 Results
          if (analysis.headToHead.last5Results.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'Son 5 Karşılaşma:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppConstants.smallFontSize,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: analysis.headToHead.last5Results.map((result) {
                Color color;
                switch (result) {
                  case 'H':
                    color = AppColors.success;
                    break;
                  case 'D':
                    color = AppColors.warning;
                    break;
                  case 'A':
                    color = AppColors.error;
                    break;
                  default:
                    color = AppColors.textSecondary;
                }
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      result,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamFormComparison() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Takım Formu (Son 5 Maç)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppConstants.bodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 320) {
                // Very small screen: Stack vertically
                return Column(
                  children: [
                    _buildTeamFormCard(homeTeam, analysis.teamForm.homeTeam, true),
                    const SizedBox(height: 12),
                    _buildTeamFormCard(awayTeam, analysis.teamForm.awayTeam, false),
                  ],
                );
              } else {
                // Normal screen: Side by side
                return Row(
                  children: [
                    Expanded(
                      child: _buildTeamFormCard(homeTeam, analysis.teamForm.homeTeam, true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTeamFormCard(awayTeam, analysis.teamForm.awayTeam, false),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeamFormCard(String teamName, TeamForm form, bool isHome) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVerySmall = constraints.maxWidth < 140;
        final logoSize = isVerySmall ? 24.0 : 32.0;
        final fontSize = isVerySmall ? 10.0 : 11.0;
        final padding = isVerySmall ? 8.0 : 12.0;
        
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            border: Border.all(
              color: isHome ? AppColors.success : AppColors.error,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Team Logo and Name - Responsive
              if (!isVerySmall) ...[
                Row(
                  children: [
                    SizedBox(
                      width: logoSize,
                      height: logoSize,
                      child: Image.network(
                        Team.getTeamLogoUrl(teamName),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.sports_soccer,
                            size: logoSize - 8,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        teamName.length > 8 ? teamName.substring(0, 8) + '..' : teamName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding),
              ] else ...[
                // Very small screen: Center logo only
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Image.network(
                    Team.getTeamLogoUrl(teamName),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.sports_soccer,
                        size: logoSize - 6,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teamName.length > 6 ? teamName.substring(0, 6) : teamName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
              ],
          
              // Last 5 Match Results - Responsive
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: form.last5Matches.map((result) {
                  Color color;
                  String label;
                  switch (result) {
                    case 'W':
                      color = AppColors.success;
                      label = 'G';
                      break;
                    case 'L':
                      color = AppColors.error;
                      label = 'M';
                      break;
                    case 'D':
                      color = AppColors.warning;
                      label = 'B';
                      break;
                    default:
                      color = AppColors.textSecondary;
                      label = '?';
                  }
                  
                  final circleSize = isVerySmall ? 20.0 : 24.0;
                  
                  return Container(
                    margin: EdgeInsets.only(right: isVerySmall ? 2 : 4),
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(circleSize / 2),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isVerySmall ? 8 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              SizedBox(height: padding),
          
              // Stats - Responsive
              if (!isVerySmall) ...[
                _buildFormStat('Attığı Gol', '${form.goalsScoredLast5}'),
                _buildFormStat('Yediği Gol', '${form.goalsConcededLast5}'),
                _buildFormStat('Gol Ort.', '${form.avgGoalsPerMatch.toStringAsFixed(1)}'),
                _buildFormStat('Temiz Sayfa', '${form.cleanSheetsLast10}/10'),
              ] else ...[
                // Very small screen: Show only essential stats
                _buildFormStat('Gol', '${form.goalsScoredLast5}-${form.goalsConcededLast5}'),
                _buildFormStat('Ort.', '${form.avgGoalsPerMatch.toStringAsFixed(1)}'),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_score, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Gol İstatistikleri',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppConstants.bodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                // Small screen: 2x2 grid
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.matchesOver25Goals}',
                            '2.5+ Gol',
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.matchesUnder25Goals}',
                            '2.5- Gol',
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.bothTeamsToScorePercentage.toStringAsFixed(0)}%',
                            'Karş. Gol',
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.firstHalfGoalsAvg.toStringAsFixed(1)}',
                            '1. Yarı',
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Large screen: 2x2 grid with larger cards
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.matchesOver25Goals}',
                            '2.5+ Gol',
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.matchesUnder25Goals}',
                            '2.5- Gol',
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.bothTeamsToScorePercentage.toStringAsFixed(0)}%',
                            'Karşılıklı Gol',
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            '${analysis.goalStats.firstHalfGoalsAvg.toStringAsFixed(1)}',
                            '1. Yarı Ort.',
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestingFacts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'İlginç Gerçekler',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppConstants.bodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          ...analysis.interestingFacts.map((fact) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fact,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppConstants.smallFontSize,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildKeyStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Anahtar İstatistikler',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppConstants.bodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Team Strength Comparison
          _buildStrengthComparison(),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Other factors
          _buildFactorCard('Ev Sahibi Avantajı', 
            '${(analysis.keyStats.homeAdvantage * 100).toStringAsFixed(0)}%'),
          _buildFactorCard('Motivasyon Faktörü', analysis.keyStats.motivationFactor),
          _buildFactorCard('Hava Durumu Etkisi', analysis.keyStats.weatherImpact),
        ],
      ),
    );
  }

  Widget _buildStrengthComparison() {
    final homeStrength = analysis.keyStats.homeTeamStrength;
    final awayStrength = analysis.keyStats.awayTeamStrength;
    final maxStrength = homeStrength > awayStrength ? homeStrength : awayStrength;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Column(
        children: [
          const Text(
            'Takım Güç Karşılaştırması',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppConstants.smallFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Home Team Strength
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  homeTeam.length > 8 ? homeTeam.substring(0, 8) : homeTeam,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: homeStrength / 100,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${homeStrength.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Away Team Strength
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  awayTeam.length > 8 ? awayTeam.substring(0, 8) : awayTeam,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: awayStrength / 100,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.error),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${awayStrength.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactorCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppConstants.smallFontSize,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppConstants.smallFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
