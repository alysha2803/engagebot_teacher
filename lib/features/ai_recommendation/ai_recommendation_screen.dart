import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/engagebot_scaffold.dart';
import '../dashboard/providers/dashboard_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class _Recommendation {
  final String id;
  final String classLabel; // 'Overall' or an actual class code
  final String title;
  final String body;
  final String category; // 'Engagement' | 'Behaviour' | 'Attention' | 'Pacing'
  final String impact;   // 'High' | 'Medium' | 'Low'
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

// ─────────────────────────────────────────────────────────────────────────────
// Sample recommendation builder — keyed to actual class codes
// ─────────────────────────────────────────────────────────────────────────────

// Per-class recommendation templates. CLASS is replaced with the real code.
const _kTemplates = [
  {
    'category': 'Attention',
    'impact': 'High',
    'title': 'Vary question difficulty in CLASS',
    'body':
        'Several students in CLASS are consistently in "distracted" status within '
            'the first 10 minutes. Starting with a low-stakes warm-up question before '
            'scaling difficulty may re-anchor attention early in the lesson.',
  },
  {
    'category': 'Pacing',
    'impact': 'Medium',
    'title': 'Reduce slide density for CLASS',
    'body':
        'Slides with more than 5 bullet points correlate with a 12% drop in engagement '
            'in CLASS. Consider splitting dense slides or replacing them with visual '
            'diagrams to keep the class focused.',
  },
  {
    'category': 'Behaviour',
    'impact': 'Medium',
    'title': 'Acknowledge top-engaged students in CLASS',
    'body':
        'Several students in CLASS maintain above-90% engagement consistently. '
            'Recognising their participation publicly could serve as a positive model '
            'and motivate peers who are less focused.',
  },
  {
    'category': 'Engagement',
    'impact': 'Medium',
    'title': 'Add movement-based activities in CLASS',
    'body':
        'CLASS shows a lower average engagement compared to your other classes. '
            'Incorporating a short physical activity or group rotation exercise near '
            'the mid-point of the lesson may help reset focus.',
  },
  {
    'category': 'Attention',
    'impact': 'Low',
    'title': 'Review seating arrangement in CLASS',
    'body':
        'Flagged students in CLASS tend to cluster in the same area. A simple '
            'rearrangement that alternates high- and low-engagement students may '
            'improve peer-influence dynamics and reduce off-task incidents.',
  },
];

List<_Recommendation> _buildSampleRecs(List<String> classCodes) {
  final recs = <_Recommendation>[
    _Recommendation(
      id: 'r_ov1',
      classLabel: 'Overall',
      title: 'Introduce peer discussion breaks',
      body: 'Engagement drops by ~18% after 20 continuous minutes of direct '
          'instruction. Short 3-minute peer discussion intervals every 20 minutes '
          'could sustain attention through the full lesson across all your classes.',
      category: 'Engagement',
      impact: 'High',
    ),
    _Recommendation(
      id: 'r_ov2',
      classLabel: 'Overall',
      title: 'Schedule complex topics in Period 2–3',
      body: 'Engagement data across all your classes shows a peak between 8:10 and '
          '9:30. Scheduling cognitively demanding topics in this window may improve '
          'retention and reduce the number of flagged students.',
      category: 'Pacing',
      impact: 'High',
    ),
  ];

  for (int i = 0; i < classCodes.length; i++) {
    final code = classCodes[i];
    final t = _kTemplates[i % _kTemplates.length];
    recs.add(_Recommendation(
      id: 'r_cls_$i',
      classLabel: code,
      title: (t['title']!).replaceAll('CLASS', code),
      body: (t['body']!).replaceAll('CLASS', code),
      category: t['category']!,
      impact: t['impact']!,
    ));
  }

  return recs;
}

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
  List<_Recommendation> _recs = [];
  List<String> _lastCodes = [];
  String _selectedFilter = 'All';
  bool _isGenerating = false;

  // Rebuild recs when the teacher's class list changes (e.g. after Firebase
  // load or after switching accounts).
  void _syncRecs(List<String> codes) {
    if (codes.join('|') == _lastCodes.join('|')) return;
    _lastCodes = codes;
    _recs = _buildSampleRecs(codes);
    // Reset filter if it no longer exists in the new class list.
    final validFilters = {'All', 'Overall', ...codes};
    if (!validFilters.contains(_selectedFilter)) _selectedFilter = 'All';
  }

  List<_Recommendation> get _visible {
    final base = _recs.where((r) => !r.ignored).toList();
    if (_selectedFilter == 'All') return base;
    return base.where((r) => r.classLabel == _selectedFilter).toList();
  }

  int get _savedCount => _recs.where((r) => r.saved).length;
  int get _ignoredCount => _recs.where((r) => r.ignored).length;
  int get _pendingCount => _recs.where((r) => !r.saved && !r.ignored).length;

  void _save(String id) =>
      setState(() => _recs.firstWhere((r) => r.id == id).saved = true);
  void _unsave(String id) =>
      setState(() => _recs.firstWhere((r) => r.id == id).saved = false);
  void _ignore(String id) =>
      setState(() => _recs.firstWhere((r) => r.id == id).ignored = true);

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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the class list from the same provider as the Dashboard so both
    // screens always reflect the same teacher account.
    final classes =
        ref.watch(dashboardProvider.select((s) => s.classes));
    final codes = classes.map((c) => c.code).toList();

    // Mutate _recs inline (safe: only runs when codes actually change).
    _syncRecs(codes);

    final filters = ['All', 'Overall', ...codes];
    final visible = _visible;
    final th = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => EngagebotDrawer.maybeOf(context)?.openDrawer(),
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
          // ── Summary stat chips ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _StatChip(
                    label: 'Pending',
                    value: _pendingCount,
                    color: AppColors.warningAmber),
                _StatChip(
                    label: 'Saved',
                    value: _savedCount,
                    color: AppColors.primaryGreen),
                _StatChip(
                    label: 'Ignored',
                    value: _ignoredCount,
                    color: AppColors.textMuted),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Class filter chips — built from dashboardProvider.classes ───
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = filters[i];
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
                        color: selected
                            ? Colors.white
                            : th.colorScheme.onSurface,
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
            // Header row: category pill + class badge + impact indicator
            Row(
              children: [
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

            Text(
              rec.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: th.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              rec.body,
              style: TextStyle(
                fontSize: 13,
                color: th.colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.55,
              ),
            ),

            const SizedBox(height: 14),

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
                      foregroundColor:
                          rec.saved ? AppColors.primaryGreen : Colors.white,
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
