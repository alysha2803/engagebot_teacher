import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/engagebot_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Simple in-screen state — no separate provider needed for a placeholder.
// ─────────────────────────────────────────────────────────────────────────────

class _Recommendation {
  final String id;
  final String classLabel; // 'Overall' or a class code
  final String title;
  final String body;
  final String category; // 'Engagement' | 'Behaviour' | 'Attention' | 'Pacing'
  final String impact; // 'High' | 'Medium' | 'Low'
  bool saved = false;
  bool ignored = false;

  _Recommendation({
    required this.id,
    required this.classLabel,
    required this.title,
    required this.body,
    required this.category,
    required this.impact,
  });
}

final List<_Recommendation> _sampleRecs = [
  _Recommendation(
    id: 'r1',
    classLabel: 'Overall',
    title: 'Introduce more peer discussion breaks',
    body:
        'Engagement drops by ~18% after 20 continuous minutes of direct instruction. '
        'Short 3-minute peer discussion intervals every 20 minutes could sustain attention through the full lesson.',
    category: 'Engagement',
    impact: 'High',
  ),
  _Recommendation(
    id: 'r2',
    classLabel: 'F4S1',
    title: 'Vary question difficulty in F4S1',
    body:
        '6 students in this class are consistently in "distracted" status within the first 10 minutes. '
        'Starting with a low-stakes warm-up question before scaling difficulty may re-anchor attention.',
    category: 'Attention',
    impact: 'High',
  ),
  _Recommendation(
    id: 'r3',
    classLabel: 'F4S2',
    title: 'Reduce slide density for F4S2',
    body:
        'Slides with more than 5 bullet points correlate with a 12% drop in engagement for this class. '
        'Consider splitting dense slides or using visual diagrams instead.',
    category: 'Pacing',
    impact: 'Medium',
  ),
  _Recommendation(
    id: 'r4',
    classLabel: 'F5S1',
    title: 'Acknowledge top-engaged students in F5S1',
    body:
        '4 students maintain above-90% engagement consistently. Recognising their participation '
        'could serve as a positive model for the rest of the class.',
    category: 'Behaviour',
    impact: 'Medium',
  ),
  _Recommendation(
    id: 'r5',
    classLabel: 'Overall',
    title: 'Schedule complex topics in Period 2–3',
    body:
        'Engagement data across all classes shows a peak between 8:10 and 9:30. '
        'Scheduling cognitively demanding topics in this window may improve retention.',
    category: 'Pacing',
    impact: 'High',
  ),
  _Recommendation(
    id: 'r6',
    classLabel: 'F5S2',
    title: 'Use movement-based activities in F5S2',
    body:
        'F5S2 shows significantly lower engagement (avg 54%) compared to other classes. '
        'Incorporating a short physical activity or group rotation exercise may help reset focus.',
    category: 'Engagement',
    impact: 'Medium',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AIRecommendationScreen extends ConsumerStatefulWidget {
  const AIRecommendationScreen({super.key});

  @override
  ConsumerState<AIRecommendationScreen> createState() =>
      _AIRecommendationScreenState();
}

class _AIRecommendationScreenState
    extends ConsumerState<AIRecommendationScreen> {
  late List<_Recommendation> _recs;
  String _selectedFilter = 'All';
  bool _isGenerating = false;

  static const _filters = ['All', 'Overall', 'F4S1', 'F4S2', 'F5S1', 'F5S2'];

  @override
  void initState() {
    super.initState();
    _recs = List.of(_sampleRecs);
  }

  List<_Recommendation> get _visible {
    final base = _recs.where((r) => !r.ignored).toList();
    if (_selectedFilter == 'All') return base;
    return base.where((r) => r.classLabel == _selectedFilter).toList();
  }

  int get _savedCount => _recs.where((r) => r.saved).length;
  int get _ignoredCount => _recs.where((r) => r.ignored).length;
  int get _pendingCount =>
      _recs.where((r) => !r.saved && !r.ignored).length;

  void _save(String id) =>
      setState(() => _recs.firstWhere((r) => r.id == id).saved = true);

  void _ignore(String id) =>
      setState(() => _recs.firstWhere((r) => r.id == id).ignored = true);

  void _unsave(String id) =>
      setState(() => _recs.firstWhere((r) => r.id == id).saved = false);

  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isGenerating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Recommendations refreshed'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final th = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () =>
              EngagebotDrawer.maybeOf(context)?.openDrawer(),
        ),
        title: const Text(
          'AI Insights',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : const Icon(Icons.refresh_rounded,
                    color: AppColors.primaryGreen),
            tooltip: 'Refresh recommendations',
            onPressed: _isGenerating ? null : _generate,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary stats ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _StatChip(
                    label: 'Pending',
                    value: _pendingCount,
                    color: AppColors.warningAmber),
                const SizedBox(width: 8),
                _StatChip(
                    label: 'Saved',
                    value: _savedCount,
                    color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                _StatChip(
                    label: 'Ignored',
                    value: _ignoredCount,
                    color: AppColors.textMuted),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Class filter chips ──────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _selectedFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryGreen
                          : th.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryGreen
                            : th.dividerColor,
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : th.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: th.dividerColor),

          // ── Recommendation cards ────────────────────────────────────────
          Expanded(
            child: visible.isEmpty
                ? _EmptyState(filter: _selectedFilter)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final rec = visible[i];
                      return _RecommendationCard(
                        rec: rec,
                        onSave: rec.saved
                            ? () => _unsave(rec.id)
                            : () => _save(rec.id),
                        onIgnore: () => _ignore(rec.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recommendation card
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final _Recommendation rec;
  final VoidCallback onSave;
  final VoidCallback onIgnore;

  const _RecommendationCard({
    required this.rec,
    required this.onSave,
    required this.onIgnore,
  });

  Color _categoryColor(String cat) => switch (cat) {
        'Engagement' => AppColors.primaryGreen,
        'Attention' => AppColors.liveRed,
        'Behaviour' => AppColors.warningAmber,
        _ => const Color(0xFF3D8B7F),
      };

  Color _impactColor(String impact) => switch (impact) {
        'High' => AppColors.liveRed,
        'Medium' => AppColors.warningAmber,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final catColor = _categoryColor(rec.category);
    final impColor = _impactColor(rec.impact);
    final isOverall = rec.classLabel == 'Overall';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: rec.saved
            ? AppColors.primaryGreen.withValues(alpha: 0.06)
            : th.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rec.saved
              ? AppColors.primaryGreen.withValues(alpha: 0.35)
              : th.dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: category chip + class badge + impact dot
            Row(
              children: [
                // Category pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rec.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Class badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOverall
                        ? th.colorScheme.onSurface.withValues(alpha: 0.08)
                        : AppColors.sageLighter,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rec.classLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOverall
                          ? th.colorScheme.onSurface.withValues(alpha: 0.55)
                          : AppColors.primaryGreen,
                    ),
                  ),
                ),
                const Spacer(),
                // Impact indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: impColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${rec.impact} impact',
                  style: TextStyle(fontSize: 11, color: impColor),
                ),
                if (rec.saved) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.bookmark,
                      size: 15, color: AppColors.primaryGreen),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              rec.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: th.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            // Body
            Text(
              rec.body,
              style: TextStyle(
                fontSize: 13,
                color: th.colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.55,
              ),
            ),

            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onIgnore,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          th.colorScheme.onSurface.withValues(alpha: 0.55),
                      side: BorderSide(color: th.dividerColor),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Ignore',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: rec.saved
                          ? AppColors.primaryGreen.withValues(alpha: 0.15)
                          : AppColors.primaryGreen,
                      foregroundColor: rec.saved
                          ? AppColors.primaryGreen
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      rec.saved ? 'Saved ✓' : 'Save',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_outlined,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2)),
          const SizedBox(height: 14),
          Text(
            filter == 'All'
                ? 'No pending recommendations'
                : 'No recommendations for $filter',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the refresh button to generate new insights.',
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}
