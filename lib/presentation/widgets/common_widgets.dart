import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class PhotoThumbnail extends StatelessWidget {
  final File file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? scorePercent;
  final bool isSelected;
  final bool showSelection;
  
  const PhotoThumbnail({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
    this.scorePercent,
    this.isSelected = false,
    this.showSelection = false,
  });
  
  Color _getScoreColor(int percent) {
    if (percent >= 70) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 3)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              file,
              fit: BoxFit.cover,
              cacheWidth: AppDimensions.thumbnailSize,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surface,
                child: const Icon(Icons.broken_image, color: AppColors.textTertiary),
              ),
            ),
            
            if (showSelection)
              Positioned(
                top: AppDimensions.paddingS,
                left: AppDimensions.paddingS,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.white70,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            
            if (scorePercent != null)
              Positioned(
                top: AppDimensions.paddingS,
                right: AppDimensions.paddingS,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getScoreColor(scorePercent!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '%$scorePercent',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DateHeader extends StatelessWidget {
  final String date;
  final int count;
  
  const DateHeader({
    super.key,
    required this.date,
    required this.count,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$count fotoğraf',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimensions.iconXXL, color: AppColors.textTertiary),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppDimensions.paddingXL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  const LoadingIndicator({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class ProcessingIndicator extends StatelessWidget {
  final int current;
  final int total;
  final String? message;
  
  const ProcessingIndicator({
    super.key,
    required this.current,
    required this.total,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingS,
      ),
      color: AppColors.primary.withOpacity(0.15),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message ?? '${AppStrings.labeling} $current/$total',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
