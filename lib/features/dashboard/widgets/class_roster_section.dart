import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/student_model.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Card containing the 3-column student avatar grid with status dots.
// TODO: Replace with live droid roster data
class ClassRosterSection extends StatelessWidget {
  final List<StudentModel> students;
  final int onlineCount;
  final void Function(StudentModel student) onStudentTap;
  final void Function(StudentModel updated) onStudentEdited;

  const ClassRosterSection({
    super.key,
    required this.students,
    required this.onlineCount,
    required this.onStudentTap,
    required this.onStudentEdited,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colorOnCard,
                ),
                children: [
                  const TextSpan(text: 'Class Roster '),
                  TextSpan(
                    text: '· $onlineCount Online',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: context.colorSubtle,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Auto-refreshing',
              style: TextStyle(fontSize: 11, color: context.colorMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Avatar grid card
        AppCard(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: students.length + 1,
            itemBuilder: (context, index) {
              if (index == students.length) {
                return _ManageCell(
                  students: students,
                  onStudentEdited: onStudentEdited,
                );
              }
              return _StudentAvatarTile(
                student: students[index],
                onTap: () => onStudentTap(students[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Student avatar tile
// ─────────────────────────────────────────────────────────────────────────────

class _StudentAvatarTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentAvatarTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: context.colorAvatarBg,
                child: Text(
                  student.name.isNotEmpty ? student.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: -2,
                child: StatusDot(status: student.status, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            student.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.colorOnCard,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manage cell
// ─────────────────────────────────────────────────────────────────────────────

class _ManageCell extends StatelessWidget {
  final List<StudentModel> students;
  final void Function(StudentModel updated) onStudentEdited;

  const _ManageCell({
    required this.students,
    required this.onStudentEdited,
  });

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditStudentsSheet(
        students: students,
        onStudentEdited: onStudentEdited,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colorBorder, width: 2),
              color: context.colorBg,
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Students bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditStudentsSheet extends StatefulWidget {
  final List<StudentModel> students;
  final void Function(StudentModel updated) onStudentEdited;

  const _EditStudentsSheet({
    required this.students,
    required this.onStudentEdited,
  });

  @override
  State<_EditStudentsSheet> createState() => _EditStudentsSheetState();
}

class _EditStudentsSheetState extends State<_EditStudentsSheet> {
  late List<StudentModel> _students;

  @override
  void initState() {
    super.initState();
    _students = List.of(widget.students);
  }

  void _handleEdit(StudentModel updated) {
    setState(() {
      _students =
          _students.map((s) => s.id == updated.id ? updated : s).toList();
    });
    widget.onStudentEdited(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorCard,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Text(
                'Edit Students',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.colorOnCard,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Done',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          Divider(height: 8, color: context.colorBorder),
          const SizedBox(height: 4),

          ..._students.map(
            (student) => _StudentEditRow(
              student: student,
              onEdit: _handleEdit,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual row inside the edit sheet
// ─────────────────────────────────────────────────────────────────────────────

class _StudentEditRow extends StatelessWidget {
  final StudentModel student;
  final void Function(StudentModel updated) onEdit;

  const _StudentEditRow({required this.student, required this.onEdit});

  void _openEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditStudentDialog(
        student: student,
        onSave: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNote =
        student.statusNote != null && student.statusNote!.isNotEmpty;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: context.colorAvatarBg,
        child: Text(
          student.name.isNotEmpty ? student.name[0] : '?',
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        student.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: context.colorOnCard,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusLabel(student.status),
            style: TextStyle(
              fontSize: 12,
              color: _statusColor(student.status),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasNote)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Note: ${student.statusNote}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colorMuted,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined,
            color: AppColors.primaryGreen, size: 20),
        onPressed: () => _openEditDialog(context),
      ),
    );
  }

  String _statusLabel(String status) =>
      status[0].toUpperCase() + status.substring(1);

  Color _statusColor(String status) => switch (status) {
        'engaged' => AppColors.successGreen,
        'distracted' => AppColors.warningAmber,
        'flagged' => AppColors.liveRed,
        _ => AppColors.textMuted,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit student dialog
// ─────────────────────────────────────────────────────────────────────────────

class _EditStudentDialog extends StatefulWidget {
  final StudentModel student;
  final void Function(StudentModel updated) onSave;

  const _EditStudentDialog({required this.student, required this.onSave});

  @override
  State<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  late String _selectedStatus;

  static const _statuses = ['engaged', 'distracted', 'flagged'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _noteController =
        TextEditingController(text: widget.student.statusNote ?? '');
    _selectedStatus = widget.student.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color _chipColor(String status) => switch (status) {
        'engaged' => AppColors.successGreen,
        'distracted' => AppColors.warningAmber,
        'flagged' => AppColors.liveRed,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Edit Student',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: context.colorOnCard,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primaryGreen),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.colorSubtle,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _statuses.map((s) {
              final selected = _selectedStatus == s;
              final color = _chipColor(s);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedStatus = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? color
                              : context.colorBorder,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        s[0].toUpperCase() + s.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: selected
                              ? color
                              : context.colorMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Reason / Note (optional)',
              hintText: 'e.g. Distracted during group activity',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primaryGreen),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel',
              style: TextStyle(color: context.colorSubtle)),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            final note = _noteController.text.trim();
            widget.onSave(
              widget.student.copyWith(
                name: name,
                status: _selectedStatus,
                statusNote: note.isEmpty ? null : note,
              ),
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
