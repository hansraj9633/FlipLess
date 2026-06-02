import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/question_answer_model.dart';
import '../providers/practice_state_provider.dart';

// AUDIO HOOKS (Ready for audio drop-in)
class PracticeAudioHooks {
  static void onAnswerSelected() {
    print('[AUDIO TRIGGER] Answer Selected');
    // Implement audio player trigger here
  }

  static void onQuestionChanged() {
    print('[AUDIO TRIGGER] Question Changed');
    // Implement audio player trigger here
  }

  static void onSessionSubmitted() {
    print('[AUDIO TRIGGER] Session Submitted');
    // Implement audio player trigger here
  }
}

/// 1. PRACTICE HEADER
class PracticeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String subject;
  final String topic;
  final int timeRemaining;
  final bool isStopwatch;
  final VoidCallback onBackPressed;
  final VoidCallback onMorePressed;

  const PracticeHeader({
    super.key,
    required this.subject,
    required this.topic,
    required this.timeRemaining,
    required this.isStopwatch,
    required this.onBackPressed,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Elegant back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              onBackPressed();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // TIMER PILL WIDGET
        TimerWidget(seconds: timeRemaining, isStopwatch: isStopwatch),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            onMorePressed();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 2. TIMER WIDGET
class TimerWidget extends StatelessWidget {
  final int seconds;
  final bool isStopwatch;

  const TimerWidget({
    super.key,
    required this.seconds,
    required this.isStopwatch,
  });

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int remainingSeconds = totalSeconds % 60;

    final String minStr = minutes.toString().padLeft(2, '0');
    final String secStr = remainingSeconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hrStr = hours.toString().padLeft(2, '0');
      return '$hrStr:$minStr:$secStr';
    } else {
      return '$minStr:$secStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStopwatch ? Icons.play_arrow_rounded : Icons.access_time_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            _formatDuration(seconds),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. PROGRESS SECTION
class ProgressCard extends StatelessWidget {
  final int currentNumber;
  final int totalQuestions;
  final double progressPercent;

  const ProgressCard({
    super.key,
    required this.currentNumber,
    required this.totalQuestions,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    final int completedPercent = (progressPercent * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $currentNumber of $totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$completedPercent% Completed',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progressPercent),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. PREMIUM ANSWER SELECTION OPTION CARD (FOR MCQ & TRUE/FALSE)
class AnswerOptionCard extends StatefulWidget {
  final String label;
  final String value;
  final bool isSelected;
  final bool isMCQStyle;
  final VoidCallback onTap;

  const AnswerOptionCard({
    super.key,
    required this.label,
    required this.value,
    required this.isSelected,
    this.isMCQStyle = true,
    required this.onTap,
  });

  @override
  State<AnswerOptionCard> createState() => _AnswerOptionCardState();
}

class _AnswerOptionCardState extends State<AnswerOptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        PracticeAudioHooks.onAnswerSelected();
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
          padding: const EdgeInsets.symmetric(all: 20),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.border,
              width: widget.isSelected ? 2.2 : 1.2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: widget.isMCQStyle
              ? Stack(
                  children: [
                    // Letter Label top-left
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ),
                    
                    // Small Checkmark top-right
                    if (widget.isSelected)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      
                    // Clean line in bottom half
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Container(
                          width: double.infinity,
                          height: 2,
                          color: widget.isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.border,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.isSelected ? AppColors.primary : AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 22,
                      )
                    else
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                      )
                  ],
                ),
        ),
      ),
    );
  }
}

/// 5. QUESTION PALETTE BOTTOM SHEET
class QuestionPaletteSheet extends StatelessWidget {
  final List<QuestionAnswerModel> answers;
  final int currentIndex;
  final Function(int) onQuestionSelected;

  const QuestionPaletteSheet({
    super.key,
    required this.answers,
    required this.currentIndex,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      mainAxisSize: MainAxisSize.min,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Drag Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Question Palette',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Legends Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLegendItem(color: AppColors.primary, label: 'Answered'),
                const SizedBox(width: 14),
                _buildLegendItem(color: AppColors.border, label: 'Unanswered', borderOnly: true),
                const SizedBox(width: 14),
                _buildLegendItem(color: AppColors.warning, label: 'Review'),
                const SizedBox(width: 14),
                _buildLegendItem(color: AppColors.primary, label: 'Current', borderOnly: true, customBorder: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Numbers Grid
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: answers.length,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, idx) {
                final answer = answers[idx];
                final isCurrent = idx == currentIndex;
                final isAnswered = answer.studentAnswer != null && answer.studentAnswer!.isNotEmpty;
                final isReview = answer.isMarkedForReview;

                Color bgColor = Colors.transparent;
                Color borderColor = AppColors.border;
                Color textColor = AppColors.textSecondary;
                
                if (isAnswered) {
                  bgColor = AppColors.primary;
                  borderColor = AppColors.primary;
                  textColor = AppColors.background;
                }
                
                if (isReview) {
                  bgColor = AppColors.warning;
                  borderColor = AppColors.warning;
                  textColor = AppColors.background;
                }
                
                if (isCurrent) {
                  borderColor = AppColors.primary;
                  if (!isAnswered && !isReview) {
                    textColor = AppColors.primary;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    PracticeAudioHooks.onQuestionChanged();
                    onQuestionSelected(idx);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: isCurrent ? 2.5 : 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: (isCurrent || isAnswered || isReview) ? FontWeight.bold : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool borderOnly = false,
    bool customBorder = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: borderOnly ? Colors.transparent : color,
            border: borderOnly
                ? Border.all(
                    color: customBorder ? AppColors.primary : AppColors.border,
                    width: customBorder ? 2.5 : 1.2,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 6. BOTTOM CONTROLS
class BottomNavigationControls extends StatefulWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final bool hasPrevious;
  final bool isLastQuestion;
  final int currentNumber;
  final int totalQuestions;

  const BottomNavigationControls({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.hasPrevious,
    required this.isLastQuestion,
    required this.currentNumber,
    required this.totalQuestions,
  });

  @override
  State<BottomNavigationControls> createState() => _BottomNavigationControlsState();
}

class _BottomNavigationControlsState extends State<BottomNavigationControls> with TickerProviderStateMixin {
  late AnimationController _prevController;
  late AnimationController _nextController;
  late Animation<double> _prevScale;
  late Animation<double> _nextScale;

  @override
  void initState() {
    super.initState();
    _prevController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _nextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    _prevScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _prevController, curve: Curves.easeInOut),
    );
    _nextScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _nextController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _prevController.dispose();
    _nextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button with compression animation
            Expanded(
              child: Opacity(
                opacity: widget.hasPrevious ? 1.0 : 0.3,
                child: GestureDetector(
                  onTapDown: (_) {
                    if (widget.hasPrevious) _prevController.forward();
                  },
                  onTapUp: (_) {
                    if (widget.hasPrevious) {
                      _prevController.reverse();
                      HapticFeedback.lightImpact();
                      PracticeAudioHooks.onQuestionChanged();
                      widget.onPrevious();
                    }
                  },
                  onTapCancel: () {
                    _prevController.reverse();
                  },
                  child: ScaleTransition(
                    scale: _prevScale,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Question Counter in center
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.currentNumber}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${widget.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Next / Submit Button
            Expanded(
              child: GestureDetector(
                onTapDown: (_) {
                  _nextController.forward();
                },
                onTapUp: (_) {
                  _nextController.reverse();
                  if (widget.isLastQuestion) {
                    HapticFeedback.mediumImpact();
                    PracticeAudioHooks.onSessionSubmitted();
                    widget.onSubmit();
                  } else {
                    HapticFeedback.lightImpact();
                    PracticeAudioHooks.onQuestionChanged();
                    widget.onNext();
                  }
                },
                onTapCancel: () {
                  _nextController.reverse();
                },
                child: ScaleTransition(
                  scale: _nextScale,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.isLastQuestion ? AppColors.success : AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isLastQuestion ? AppColors.success : AppColors.primary).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.isLastQuestion ? 'Submit' : 'Next',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                      ),
                    ),
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
