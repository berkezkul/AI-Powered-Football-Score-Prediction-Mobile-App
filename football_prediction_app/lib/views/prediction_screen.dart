import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../view_models/prediction_view_model.dart';
import '../widgets/team_selector.dart';
import '../widgets/prediction_card.dart';
import '../widgets/detailed_analysis_widget.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: AppConstants.mediumAnimationDuration),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // ViewModel'i başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewModel();
    });
  }

  Future<void> _initializeViewModel() async {
    final viewModel = context.read<PredictionViewModel>();
    await viewModel.checkApiHealth();
    await viewModel.loadTeams();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Consumer<PredictionViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.state == PredictionState.loading && viewModel.teams.isEmpty) {
                      return _buildLoadingScreen();
                    }

                    if (viewModel.hasError && viewModel.teams.isEmpty) {
                      return _buildErrorScreen(viewModel.errorMessage ?? 'Bilinmeyen hata');
                    }

                    return _buildMainContent(viewModel);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white, //AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/logos/premier_league_logo.png',
                    width: 40,
                    height: 40,

                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: AppConstants.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppConstants.appSubtitle,
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: AppConstants.captionFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<PredictionViewModel>(
                  builder: (context, viewModel, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: viewModel.isApiHealthy
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            viewModel.isApiHealthy
                                ? Icons.check_circle
                                : Icons.error,
                            color: viewModel.isApiHealthy
                                ? AppColors.success
                                : AppColors.error,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            viewModel.isApiHealthy ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: viewModel.isApiHealthy
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: AppConstants.smallFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Takımlar yükleniyor...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppConstants.bodyFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Bir Hata Oluştu',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: AppConstants.headingFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              error,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppConstants.bodyFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton.icon(
              onPressed: () => _initializeViewModel(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                  vertical: AppConstants.defaultPadding,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(PredictionViewModel viewModel) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            _buildTeamSelection(viewModel),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildActionButtons(viewModel),
            const SizedBox(height: AppConstants.defaultPadding),
            PredictionCard(
              prediction: viewModel.prediction,
              isLoading: viewModel.isLoading && viewModel.prediction == null,
              homeTeam: viewModel.getTeamByName(viewModel.selectedHomeTeam ?? ''),
              awayTeam: viewModel.getTeamByName(viewModel.selectedAwayTeam ?? ''),
            ),
            
            // Detaylı analiz bölümü
            if (viewModel.prediction != null && 
                viewModel.prediction!.detailedAnalysis != null &&
                !viewModel.isLoading) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              DetailedAnalysisWidget(
                analysis: viewModel.prediction!.detailedAnalysis!,
                homeTeam: viewModel.selectedHomeTeam!,
                awayTeam: viewModel.selectedAwayTeam!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelection(PredictionViewModel viewModel) {
    return Row(
      children: [
        // Ev sahibi takım seçimi
        Expanded(
          child: TeamSelector(
            label: 'Ev Sahibi',
            selectedTeam: viewModel.selectedHomeTeam,
            teams: viewModel.teamObjects,
            onTeamSelected: viewModel.selectHomeTeam,
            otherSelectedTeam: viewModel.selectedAwayTeam,
          ),
        ),
        
        // Değiştir butonu
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.smallPadding),
          child: Column(
            children: [
              const SizedBox(height: 40), // Label yüksekliği için boşluk
              IconButton(
                onPressed: viewModel.canPredict ? viewModel.swapTeams : null,
                icon: const Icon(Icons.swap_horiz),
                color: AppColors.secondary,
                iconSize: 28,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Deplasman takım seçimi
        Expanded(
          child: TeamSelector(
            label: 'Deplasman',
            selectedTeam: viewModel.selectedAwayTeam,
            teams: viewModel.teamObjects,
            onTeamSelected: viewModel.selectAwayTeam,
            otherSelectedTeam: viewModel.selectedHomeTeam,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(PredictionViewModel viewModel) {
    return Row(
      children: [
        // Tahmin al butonu
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: viewModel.canPredict && !viewModel.isLoading
                ? viewModel.getPrediction
                : null,
            icon: viewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                    ),
                  )
                : const Icon(Icons.psychology),
            label: Text(
              viewModel.isLoading ? 'Hesaplanıyor...' : 'Tahmin Al',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppConstants.defaultPadding),
        
        // Rastgele seç butonu
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.teams.isNotEmpty && !viewModel.isLoading
                ? viewModel.selectRandomTeams
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textSecondary,
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
            child: const Icon(Icons.shuffle),
          ),
        ),
        
        const SizedBox(width: AppConstants.smallPadding),
        
        // Temizle butonu
        Expanded(
          child: ElevatedButton(
            onPressed: (viewModel.selectedHomeTeam != null || 
                      viewModel.selectedAwayTeam != null || 
                      viewModel.prediction != null) && !viewModel.isLoading
                ? viewModel.clearSelections
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.2),
              foregroundColor: AppColors.error,
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
            child: const Icon(Icons.clear),
          ),
        ),
      ],
    );
  }
}
