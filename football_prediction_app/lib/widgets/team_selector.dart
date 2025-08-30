import 'package:flutter/material.dart';
import '../models/team.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class TeamSelector extends StatelessWidget {
  final String label;
  final String? selectedTeam;
  final List<Team> teams;
  final Function(String?) onTeamSelected;
  final String? otherSelectedTeam; // Diğer seçili takımı kontrol için

  const TeamSelector({
    super.key,
    required this.label,
    required this.selectedTeam,
    required this.teams,
    required this.onTeamSelected,
    this.otherSelectedTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppConstants.captionFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (selectedTeam != null) ...[
            _buildSelectedTeam(),
            const SizedBox(height: AppConstants.smallPadding),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showTeamPicker(context),
              icon: Icon(
                selectedTeam != null ? Icons.edit : Icons.add,
                color: AppColors.textPrimary,
              ),
              label: Text(
                selectedTeam != null ? 'Değiştir' : 'Takım Seç',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTeam() {
    final team = teams.firstWhere((t) => t.name == selectedTeam);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Image.network(
              Team.getTeamLogoUrl(team.name),
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Logo yüklenemezse varsayılan futbol ikonu
                return Icon(
                  Icons.sports_soccer,
                  size: 40,
                  color: AppColors.primary,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  ),
                );
              },



            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  team.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppConstants.bodyFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (team.displayName != team.name)
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppConstants.smallFontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),



          IconButton(
            onPressed: () => onTeamSelected(null),
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showTeamPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.largeBorderRadius),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$label Seçin',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppConstants.headingFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final isDisabled = team.name == otherSelectedTeam;
                  
                  return Card(
                    color: isDisabled 
                        ? AppColors.surface.withOpacity(0.5)
                        : AppColors.surface,
                    margin: const EdgeInsets.symmetric(
                      vertical: AppConstants.smallPadding / 2,
                      horizontal: AppConstants.smallPadding,
                    ),
                    child: ListTile(
                      enabled: !isDisabled,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDisabled 
                              ? AppColors.textHint.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            team.emoji,
                            style: TextStyle(
                              fontSize: 20,
                              color: isDisabled ? AppColors.textHint : null,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        team.displayName,
                        style: TextStyle(
                          color: isDisabled ? AppColors.textHint : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: team.displayName != team.name
                          ? Text(
                              team.name,
                              style: TextStyle(
                                color: isDisabled ? AppColors.textHint : AppColors.textSecondary,
                                fontSize: AppConstants.smallFontSize,
                              ),
                            )
                          : null,
                      trailing: isDisabled
                          ? const Icon(
                              Icons.block,
                              color: AppColors.textHint,
                            )
                          : selectedTeam == team.name
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                )
                              : null,
                      onTap: isDisabled
                          ? null
                          : () {
                              onTeamSelected(team.name);
                              Navigator.pop(context);
                            },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
