import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Card showing AI-generated teaching recommendation.
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
    final bgColor = context.isDark
        ? const Color(0xFF1E2B1A)
        : AppColors.sageLighter;
    final iconBg = context.isDark
        ? const Color(0xFF253020)
        : AppColors.sageLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
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
                  color: iconBg,
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

          _buildHighlightedText(context, text, highlightWord),
          const SizedBox(height: 10),

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

  Widget _buildHighlightedText(
      BuildContext context, String fullText, String keyword) {
    final subtleColor = context.colorSubtle;
    final lowerText = fullText.toLowerCase();
    final lowerKw = keyword.toLowerCase();
    final startIdx = lowerText.indexOf(lowerKw);

    if (startIdx == -1) {
      return Text(
        fullText,
        style: TextStyle(fontSize: 13, color: subtleColor, height: 1.5),
      );
    }

    final before = fullText.substring(0, startIdx);
    final highlighted =
        fullText.substring(startIdx, startIdx + keyword.length);
    final after = fullText.substring(startIdx + keyword.length);

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 13, color: subtleColor, height: 1.5),
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
