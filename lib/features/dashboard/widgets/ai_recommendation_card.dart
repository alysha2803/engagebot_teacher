import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Sage-background card showing AI-generated teaching recommendation.
// TODO: Replace with droid AI recommendation API
class AIRecommendationCard extends StatelessWidget {
  final String text;
  final String highlightWord;
  final String actionLabel;
  final VoidCallback? onApply;

  const AIRecommendationCard({
    super.key,
    required this.text,
    required this.highlightWord,
    required this.actionLabel,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sageLighter,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI RECOMMENDATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.bolt,
                size: 18,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Body text with highlighted keyword
          _buildHighlightedText(text, highlightWord),
          const SizedBox(height: 10),

          // Action link
          GestureDetector(
            onTap: onApply,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$actionLabel ›',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a RichText that highlights [keyword] inside [fullText].
  Widget _buildHighlightedText(String fullText, String keyword) {
    final lowerText = fullText.toLowerCase();
    final lowerKw = keyword.toLowerCase();
    final startIdx = lowerText.indexOf(lowerKw);

    if (startIdx == -1) {
      return Text(
        fullText,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      );
    }

    final before = fullText.substring(0, startIdx);
    final highlighted = fullText.substring(startIdx, startIdx + keyword.length);
    final after = fullText.substring(startIdx + keyword.length);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: highlighted,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryGreen,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
