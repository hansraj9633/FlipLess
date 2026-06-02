import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/create_session_provider.dart';

/// 1. QUESTION TYPE CHIP WITH SCALE ANIMATION & HAPTICS
class QuestionTypeChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionTypeChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<QuestionTypeChip> createState() => _QuestionTypeChipState();
}

class _QuestionTypeChipState extends State<QuestionTypeChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 100ms scale animation as requested: "Scale 1.00 -> 0.97 -> 1.00"
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        // Trigger Light feedback
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? AppColors.background : AppColors.textPrimary,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// 2. ADVANCED SETTINGS COLLAPSIBLE/EXPANDABLE SECTION
class AdvancedSettingsSection extends ConsumerWidget {
  const AdvancedSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createSessionProvider);
    final notifier = ref.read(createSessionProvider.notifier);

    return Column(
      children: [
        // Collapsible Header Card
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              notifier.toggleAdvancedExpanded();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.settings,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Advanced Settings',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: state.isAdvancedExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Expanded fields with height transition
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            height: state.isAdvancedExpanded ? null : 0,
            padding: state.isAdvancedExpanded ? const EdgeInsets.only(top: 16) : EdgeInsets.zero,
            child: state.isAdvancedExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Marks per correct
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Marks Per Correct',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: state.marksPerCorrect.toString(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: '1',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final doubleValue = double.tryParse(val) ?? 1.0;
                                    notifier.updateMarksPerCorrect(doubleValue);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Negative marking
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Negative Marking',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: state.negativeMarking.toString(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final doubleValue = double.tryParse(val) ?? 0.0;
                                    notifier.updateNegativeMarking(doubleValue);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Timer Options Dropdown
                      const Text(
                        'Timer',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.timerOption,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                            items: <String>[
                              'No Timer',
                              '15 min',
                              '30 min',
                              '45 min',
                              '60 min',
                              '90 min',
                              '120 min',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(color: AppColors.textPrimary)),
                              );
                            }).toList(),
                            onChanged: (String? val) {
                              if (val != null) {
                                notifier.updateTimerOption(val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Auto Save Draft Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Auto Save Draft',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Switch(
                            value: state.autoSaveDraft,
                            activeColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withOpacity(0.3),
                            inactiveThumbColor: AppColors.textSecondary,
                            inactiveTrackColor: AppColors.border,
                            onChanged: (_) {
                              notifier.toggleAutoSaveDraft();
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// 3. SESSION PREVIEW CARD WITH CUSTOM DASHED BORDERS & TRANSITIONS
class SessionPreviewCard extends ConsumerWidget {
  const SessionPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createSessionProvider);

    return CustomPaint(
      painter: DashedBorderPainter(color: AppColors.border, radius: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'SESSION PREVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Column 1
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewItem(
                        label: 'Subject',
                        value: state.subject.trim().isEmpty ? '-' : state.subject,
                      ),
                      const SizedBox(height: 16),
                      _buildPreviewItem(
                        label: 'Types',
                        value: state.questionTypes.isEmpty
                            ? '-'
                            : state.questionTypes.join(', '),
                        valueColor: state.questionTypes.isEmpty ? AppColors.error : AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Column 2
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewItem(
                        label: 'Questions',
                        value: state.questionCount.toString(),
                      ),
                      const SizedBox(height: 16),
                      _buildPreviewItem(
                        label: 'Timer',
                        value: state.timerOption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Helper painter to draw smooth dashed borders
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    double distance = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

/// 4. CONTINUE BUTTON WITH COMPRESSION TAP ANIMATION & ADVANCED HAPTICS
class ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const ContinueButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Smooth compression tap animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          _controller.reverse();
          // Medium tactile impact when pressed
          HapticFeedback.mediumImpact();
          widget.onPressed();
        }
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.background,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
import 'dart:ui';
