import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/observation_model.dart';
import '../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile Header Card
// ─────────────────────────────────────────────────────────────────────────────
class ProfileHeaderCard extends StatelessWidget {
  final StudentProfile profile;

  const ProfileHeaderCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: context.colorAvatarBg,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0] : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: context.colorOnCard,
                        ),
                      ),
                    ),
                    SageChip(
                      label: profile.engagementLabel,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  '${profile.className} · ${profile.subject}',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colorSubtle,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.trending_up,
                        size: 14, color: AppColors.successGreen),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.avgEngagement}% Avg',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colorOnCard,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer_outlined,
                        size: 14, color: AppColors.warningAmber),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.flags} Flags',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colorOnCard,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Engagement Timeline Card (fl_chart)
// ─────────────────────────────────────────────────────────────────────────────

class EngagementTimelineCard extends StatelessWidget {
  final List<EngagementPoint> timeline;

  const EngagementTimelineCard({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final borderColor = context.colorBorder;
    final mutedColor = context.colorMuted;

    // Need at least 2 points to draw a line.
    final points = timeline.length >= 2 ? timeline : <EngagementPoint>[];
    final spots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    // Show a label every ~12 samples (≈ 1 minute at 5s interval).
    final labelStep = (points.length / 6).ceil().clamp(1, 999);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Timeline',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colorOnCard,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            points.isEmpty
                ? 'No session data recorded yet'
                : 'Latest session · ${points.length} samples',
            style: TextStyle(fontSize: 12, color: context.colorSubtle),
          ),
          const SizedBox(height: 16),

          if (points.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Run a droid session to see the timeline',
                  style: TextStyle(color: context.colorMuted, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: borderColor, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 30,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 ||
                              idx >= points.length ||
                              idx % labelStep != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            points[idx].timeLabel,
                            style: TextStyle(fontSize: 9, color: mutedColor),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primaryGreen,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.25),
                            AppColors.primaryGreen.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Engagement Level Card
// ─────────────────────────────────────────────────────────────────────────────

class EngagementLevelCard extends StatelessWidget {
  final int avgEngagement;
  final String engagementLabel;

  const EngagementLevelCard({
    super.key,
    required this.avgEngagement,
    required this.engagementLabel,
  });

  Color _levelColor() {
    if (avgEngagement >= 65) return AppColors.successGreen;
    if (avgEngagement >= 35) return AppColors.warningAmber;
    return AppColors.liveRed;
  }

  @override
  Widget build(BuildContext context) {
    final col = _levelColor();
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Big percentage circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: col.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$avgEngagement%',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: col,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Engagement Level',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorSubtle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  engagementLabel,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnCard,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: avgEngagement / 100,
                    backgroundColor: context.colorBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(col),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Analytics Card — pose, expression, EAR, MAR
// ─────────────────────────────────────────────────────────────────────────────

class SessionAnalyticsCard extends StatelessWidget {
  final Map<String, int> poseDistribution;
  final Map<String, int> expressionDistribution;
  final double avgEAR;
  final double avgMAR;

  const SessionAnalyticsCard({
    super.key,
    required this.poseDistribution,
    required this.expressionDistribution,
    required this.avgEAR,
    required this.avgMAR,
  });

  static const _poseOrder = ['forward', 'down', 'side', 'away'];
  static const _exprOrder = ['attentive', 'neutral', 'drowsy', 'yawning'];

  static const _poseLabel = {
    'forward': 'Looking Forward',
    'down': 'Looking Down',
    'side': 'Looking Side',
    'away': 'Looking Away',
  };
  static const _exprLabel = {
    'attentive': 'Attentive',
    'neutral': 'Neutral',
    'drowsy': 'Drowsy',
    'yawning': 'Yawning',
  };

  Color _poseColor(String pose) => switch (pose) {
        'forward' => AppColors.successGreen,
        'down' => AppColors.warningAmber,
        'side' => const Color(0xFFED8936),
        _ => AppColors.liveRed,
      };

  Color _exprColor(String expr) => switch (expr) {
        'attentive' => AppColors.successGreen,
        'neutral' => AppColors.primaryGreen,
        'drowsy' => AppColors.warningAmber,
        _ => AppColors.liveRed,
      };

  @override
  Widget build(BuildContext context) {
    final earLabel = avgEAR >= 0.28
        ? 'Eyes Open'
        : avgEAR >= 0.22
            ? 'Partially Closed'
            : 'Drowsy';
    final marLabel = avgMAR >= 0.5
        ? 'Yawning'
        : avgMAR >= 0.25
            ? 'Mouth Open'
            : 'Normal';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Analytics',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colorOnCard,
            ),
          ),
          const SizedBox(height: 14),

          // Head Pose
          Text(
            'HEAD POSE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.colorMuted,
            ),
          ),
          const SizedBox(height: 8),
          ..._poseOrder
              .where((k) => (poseDistribution[k] ?? 0) > 0)
              .map((k) => _AnalyticsBar(
                    label: _poseLabel[k] ?? k,
                    value: poseDistribution[k] ?? 0,
                    color: _poseColor(k),
                  )),

          const SizedBox(height: 14),

          // Expression
          Text(
            'FACIAL EXPRESSION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.colorMuted,
            ),
          ),
          const SizedBox(height: 8),
          ..._exprOrder
              .where((k) => (expressionDistribution[k] ?? 0) > 0)
              .map((k) => _AnalyticsBar(
                    label: _exprLabel[k] ?? k,
                    value: expressionDistribution[k] ?? 0,
                    color: _exprColor(k),
                  )),

          const SizedBox(height: 14),

          // EAR / MAR row
          Text(
            'EYE & MOUTH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.colorMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Avg EAR',
                  value: avgEAR.toStringAsFixed(2),
                  sub: earLabel,
                  color: avgEAR >= 0.22
                      ? AppColors.successGreen
                      : AppColors.warningAmber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  label: 'Avg MAR',
                  value: avgMAR.toStringAsFixed(2),
                  sub: marLabel,
                  color: avgMAR < 0.5
                      ? AppColors.successGreen
                      : AppColors.liveRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _AnalyticsBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.colorSubtle),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: context.colorBorder,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$value%',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: context.colorMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(sub,
              style: TextStyle(fontSize: 10, color: context.colorSubtle)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric Chips Row
// ─────────────────────────────────────────────────────────────────────────────
class MetricChipsRow extends StatelessWidget {
  final int focusDepth;
  final int collaboration;

  const MetricChipsRow({
    super.key,
    required this.focusDepth,
    required this.collaboration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricChip(
            icon: Icons.language_outlined,
            label: 'Focus Depth',
            value: focusDepth,
            barColor: AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricChip(
            icon: Icons.chat_bubble_outline,
            label: 'Collaboration',
            value: collaboration,
            barColor: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color barColor;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: context.colorMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colorSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$value%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.colorOnCard,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: context.colorBorder,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Droid Insight Card
// ─────────────────────────────────────────────────────────────────────────────

class DroidInsightCard extends StatelessWidget {
  final String insightText;

  const DroidInsightCard({super.key, required this.insightText});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        context.isDark ? const Color(0xFF1E2B1A) : AppColors.sageLighter;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Droid Insight',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.colorOnCard,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$insightText"',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: context.colorSubtle,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Observation Filter Chips
// ─────────────────────────────────────────────────────────────────────────────
class ObservationFilterChips extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onSelect;

  const ObservationFilterChips({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_outlined,
                size: 14, color: AppColors.warningAmber),
            const SizedBox(width: 6),
            Text(
              'Active Observations',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.colorOnCard,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final isActive = filter == activeFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryGreen
                          : context.colorCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primaryGreen
                            : context.colorBorder,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : context.colorOnCard,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Observation Card
// ─────────────────────────────────────────────────────────────────────────────
class ObservationCard extends StatelessWidget {
  final ObservationModel observation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ObservationCard({
    super.key,
    required this.observation,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SageChip(label: observation.category),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 11, color: context.colorMuted),
                  const SizedBox(width: 3),
                  Text(
                    observation.timestamp,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colorMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            observation.text,
            style: TextStyle(
              fontSize: 13,
              color: context.colorSubtle,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onDelete,
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.liveRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Observation Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class AddEditObservationSheet extends StatefulWidget {
  final ObservationModel? existing;
  final void Function(ObservationModel obs) onSave;

  const AddEditObservationSheet({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<AddEditObservationSheet> createState() =>
      _AddEditObservationSheetState();
}

class _AddEditObservationSheetState
    extends State<AddEditObservationSheet> {
  late final TextEditingController _textController;
  String _selectedCategory = 'Academic';
  final _categories = ['Academic', 'Behavior', 'Participation', 'Teamwork'];

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.existing?.text ?? '');
    if (widget.existing != null) {
      _selectedCategory = widget.existing!.category;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _save() {
    if (_textController.text.trim().isEmpty) return;
    final obs = ObservationModel(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      timestamp: widget.existing?.timestamp ?? 'Just now',
      text: _textController.text.trim(),
    );
    widget.onSave(obs);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Edit Observation' : 'Add Observation',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.colorOnCard,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.colorOnCard,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : context.colorBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : context.colorSubtle,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Note',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.colorOnCard,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your observation here...',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Save Changes' : 'Add Note'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
