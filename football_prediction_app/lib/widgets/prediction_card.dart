import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/match_prediction.dart';
import '../models/team.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class PredictionCard extends StatelessWidget {
  final MatchPrediction? prediction;
  final bool isLoading;
  final Team? homeTeam;
  final Team? awayTeam;

  const PredictionCard({
    super.key,
    this.prediction,
    this.isLoading = false,
    this.homeTeam,
    this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    if (prediction == null) {
      return _buildEmptyCard();
    }

    return _buildPredictionCard();
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          SpinKitPulse(
            color: AppColors.primary,
            size: 60,
          ),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'AI Tahmini Hesaplanıyor...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppConstants.bodyFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.smallPadding),
          Text(
            'Bu işlem birkaç saniye sürebilir',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppConstants.captionFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.sports_soccer,
            color: AppColors.textSecondary,
            size: 48,
          ),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Maç Tahmini',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppConstants.bodyFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.smallPadding),
          Text(
            'İki takım seçip tahmin almak için butona basın',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppConstants.captionFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard() {
    final pred = prediction!;
    
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildScorePrediction(),
          _buildProbabilities(),
          _buildConfidence(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.psychology,
            color: AppColors.secondary,
            size: 24,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          const Expanded(
            child: Text(
              'AI Tahmin Sonucu',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppConstants.headingFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              prediction!.prediction.confidenceLevel,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: AppConstants.smallFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePrediction() {
    final pred = prediction!.prediction;
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Row(
            children: [
              // Ev sahibi takım
              Expanded(
                child: Column(
                  children: [
                    if (homeTeam != null) ...[
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            homeTeam!.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        homeTeam!.displayName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppConstants.captionFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Skor
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                  vertical: AppConstants.defaultPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      pred.scoreText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding / 2),
                    Text(
                      pred.resultDisplayText,
                      style: TextStyle(
                        color: _getResultColor(pred.result),
                        fontSize: AppConstants.smallFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Deplasman takım
              Expanded(
                child: Column(
                  children: [
                    if (awayTeam != null) ...[
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            awayTeam!.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        awayTeam!.displayName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppConstants.captionFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilities() {
    final probs = prediction!.prediction.probabilities;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Olasılıklar',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppConstants.captionFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildProbabilityBar('Ev Sahibi', probs.homePercentage, AppColors.homeWin),
          const SizedBox(height: AppConstants.smallPadding / 2),
          _buildProbabilityBar('Beraberlik', probs.drawPercentage, AppColors.draw),
          const SizedBox(height: AppConstants.smallPadding / 2),
          _buildProbabilityBar('Deplasman', probs.awayPercentage, AppColors.awayWin),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(String label, int percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppConstants.smallFontSize,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        SizedBox(
          width: 35,
          child: Text(
            '%$percentage',
            style: TextStyle(
              color: color,
              fontSize: AppConstants.smallFontSize,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidence() {
    final confidence = prediction!.prediction.confidence;
    final confidencePercentage = (confidence * 100).round();
    
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: _getConfidenceColor(confidence),
            size: 20,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            'Güven Düzeyi: %$confidencePercentage',
            style: TextStyle(
              color: _getConfidenceColor(confidence),
              fontSize: AppConstants.captionFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'H':
        return AppColors.homeWin;
      case 'D':
        return AppColors.draw;
      case 'A':
        return AppColors.awayWin;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return AppColors.success;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}
