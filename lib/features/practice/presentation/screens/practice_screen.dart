import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/sessions_provider.dart';
import '../providers/practice_state_provider.dart';
import '../widgets/practice_widgets.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _fadeSlideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controls Integer text inputs
  final TextEditingController _integerInputController = TextEditingController();
  final FocusNode _integerFocusNode = FocusNode();

  // Multi-type selection holder (MCQ / TF / Integer toggle)
  String _activeQuestionTypeOverride = 'MCQ';

  @override
  void initState() {
    super.initState();
    
    // 1. Screen transit animations: Fade + Slide Up 250ms
    _fadeSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeOutQuad,
    ));

    _fadeSlideController.forward();

    // 2. Start tick timer interval update logic (every 1 second)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        ref.read(practiceStateProvider.notifier).tickTimer();
      }
    });

    // 3. Fallback/Auto-resume check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initOrResumeSession();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeSlideController.dispose();
    _integerInputController.dispose();
    _integerFocusNode.dispose();
    super.dispose();
  }

  /// Locate practicing sessions and restore state
  Future<void> _initOrResumeSession() async {
    final state = ref.read(practiceStateProvider);
    if (state != null) {
      _initializeInputTextForQuestion(state.currentQuestionIndex);
      return; // Already initialized correctly
    }

    // Try finding the first active draft session
    final sessionsAsync = ref.read(sessionsProvider);
    String? fallbackSessionId;
    sessionsAsync.whenData((list) {
      final active = list.where((s) => s.status == 'practicing' || s.status == 'draft').toList();
      if (active.isNotEmpty) {
        fallbackSessionId = active.first.sessionId;
      }
    });

    if (fallbackSessionId != null) {
      final success = await ref.read(practiceStateProvider.notifier).loadOrResumeSession(fallbackSessionId!);
      if (success && mounted) {
        final newState = ref.read(practiceStateProvider);
        if (newState != null) {
          _initializeInputTextForQuestion(newState.currentQuestionIndex);
        }
      }
    } else {
      // In case we navigated without starting, let's auto-setup a demo session so we never crash!
      ref.read(practiceStateProvider.notifier).startSession(
        sessionId: 'session_demo_fluid_mechanics',
        subject: 'Fluid Mechanics',
        topic: 'Open Channel Flow',
        totalQuestions: 50,
        durationMinutes: 32, // Countdown 32 mins
      );
      final newState = ref.read(practiceStateProvider);
      if (newState != null) {
        _initializeInputTextForQuestion(newState.currentQuestionIndex);
      }
    }
  }

  /// Keeps soft-keyboard input text synced with model state
  void _initializeInputTextForQuestion(int index) {
    final state = ref.read(practiceStateProvider);
    if (state == null) return;
    
    final answer = state.answers[index].studentAnswer;
    _integerInputController.text = answer ?? '';
    
    // Choose selected input mode override
    final sessionsAsync = ref.read(sessionsProvider);
    List<String> types = ['MCQ'];
    
    sessionsAsync.whenData((list) {
      try {
        final s = list.firstWhere((x) => x.sessionId == state.sessionId);
        types = s.questionTypes;
      } catch (_) {}
    });

    if (types.isNotEmpty) {
      // Seq or toggle
      if (types.contains('MCQ')) {
        _activeQuestionTypeOverride = 'MCQ';
      } else if (types.contains('True/False') || types.contains('True / False')) {
        _activeQuestionTypeOverride = 'True / False';
      } else if (types.contains('Integer')) {
        _activeQuestionTypeOverride = 'Integer';
      } else {
        _activeQuestionTypeOverride = types.first;
      }
    }
  }

  void _showQuestionPalette() {
    final state = ref.read(practiceStateProvider);
    if (state == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return QuestionPaletteSheet(
          answers: state.answers,
          currentIndex: state.currentQuestionIndex,
          onQuestionSelected: (index) {
            ref.read(practiceStateProvider.notifier).selectQuestion(index);
            _initializeInputTextForQuestion(index);
          },
        );
      },
    );
  }

  /// Save answers local draft option
  Future<void> _handleExit({required bool saveDraft}) async {
    final state = ref.read(practiceStateProvider);
    if (state == null) {
      context.go('/');
      return;
    }

    if (saveDraft) {
      // Save and set status to 'practicing'
      await ref.read(sessionsProvider.notifier).updateStatus(state.sessionId, 'practicing');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Practice session progress saved as draft.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/');
      }
    } else {
      // Discard and delete session completely
      final repo = ref.read(sessionRepositoryProvider);
      await repo.deleteSession(state.sessionId);
      await ref.read(sessionsProvider.notifier).loadSessions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session discarded successfully.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/');
      }
    }
  }

  /// System native Back or Top Back press
  Future<bool> _onWillPop() async {
    final state = ref.read(practiceStateProvider);
    if (state == null) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Save draft or close?',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Keep your changes as a draft for later, continue practice, or discard this session completely?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            // LEFT Discard Button
            TextButton(
              onPressed: () => Navigator.pop(context, 'discard'),
              child: const Text('Discard', style: TextStyle(color: AppColors.error)),
            ),
            
            // CENTER Continue Button
            TextButton(
              onPressed: () => Navigator.pop(context, 'continue'),
              child: const Text('Continue', style: TextStyle(color: AppColors.primary)),
            ),
            
            // RIGHT Save Draft Box
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, 'save'),
              child: const Text('Save Draft', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (result == 'save') {
      await _handleExit(saveDraft: true);
      return true;
    } else if (result == 'discard') {
      await _handleExit(saveDraft: false);
      return true;
    }
    return false;
  }

  /// Submit Session action on the last question index
  Future<void> _handleSubmitSession() async {
    final state = ref.read(practiceStateProvider);
    if (state == null) return;

    // Confirm session submission dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Submit Session?',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to finish and submit your answers for evaluation?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(practiceStateProvider.notifier).completeSession();
      if (mounted) {
        // Submit Session -> Evaluation Method Screen passing Session ID query parameter
        context.go('/evaluation?sessionId=${state.sessionId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceStateProvider);

    if (state == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final double progressPercent = state.totalQuestions > 0 
        ? state.currentQuestionIndex / state.totalQuestions 
        : 0.0;
        
    final currentQuestion = state.answers[state.currentQuestionIndex];
    final selectedAnswer = currentQuestion.studentAnswer;
    final isMarkedForReview = currentQuestion.isMarkedForReview;

    // Get active question session allowed styles
    final sessionsAsync = ref.watch(sessionsProvider);
    List<String> allowedTypes = ['MCQ'];
    sessionsAsync.whenData((list) {
      try {
        final s = list.firstWhere((x) => x.sessionId == state.sessionId);
        allowedTypes = s.questionTypes;
      } catch (_) {}
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // 1. TOP HEADER APP BAR
        appBar: PracticeHeader(
          subject: state.subject,
          topic: state.topic,
          timeRemaining: state.timeRemaining,
          isStopwatch: state.isStopwatch,
          onBackPressed: () async {
            final pop = await _onWillPop();
            if (pop && mounted) {
              Navigator.of(context).maybePop();
            }
          },
          onMorePressed: () {
            // Context menu bottom dialog
            showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.class_outlined, color: AppColors.textPrimary),
                        title: const Text('Reset Question Input', style: TextStyle(color: AppColors.textPrimary)),
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(practiceStateProvider.notifier).clearAnswer();
                          _integerInputController.clear();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.save_outlined, color: AppColors.primary),
                        title: const Text('Save Draft & Exit', style: TextStyle(color: AppColors.primary)),
                        onTap: () {
                          Navigator.pop(context);
                          _handleExit(saveDraft: true);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: AppColors.error),
                        title: const Text('Discard Session', style: TextStyle(color: AppColors.error)),
                        onTap: () {
                          Navigator.pop(context);
                          _handleExit(saveDraft: false);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        
        // 2. MAIN WORKSPACE / COLUMN SIZER
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth > 600 ? 550 : double.infinity;
              
              return Center(
                child: SizedBox(
                  width: maxWidth,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          
                          // 3. PROGRESS ROW
                          ProgressCard(
                            currentNumber: state.currentQuestionIndex + 1,
                            totalQuestions: state.totalQuestions,
                            progressPercent: progressPercent,
                          ),
                          const SizedBox(height: 24),
                          
                          // 4. BIG NUMBER BOX PANEL
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.35, 0.0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuad)),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  key: ValueKey<int>(state.currentQuestionIndex),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Glowing orange flag corner decoration
                                      if (isMarkedForReview)
                                        Positioned(
                                          top: 16,
                                          right: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning.withOpacity(0.15),
                                              border: Border.all(color: AppColors.warning, width: 1.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.flag_rounded, size: 14, color: AppColors.warning),
                                                SizedBox(width: 4),
                                                Text(
                                                  'REVIEW',
                                                  style: TextStyle(
                                                    color: AppColors.warning,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      
                                      Center(
                                        child: Text(
                                          '${state.currentQuestionIndex + 1}',
                                          style: const TextStyle(
                                            fontSize: 120,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xff1d232c), // Dark transparent grey matching image
                                            letterSpacing: -2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // 5. INPUT REGION (CHIPS / LABELS + SELECT INPUT AREA)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Subtitle Headers (Review + Select Your Answer)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'SELECT YOUR ANSWER',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMuted,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    
                                    // Mark for Review Trigger
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        ref.read(practiceStateProvider.notifier).toggleReview();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isMarkedForReview ? AppColors.warning.withOpacity(0.12) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isMarkedForReview ? AppColors.warning : AppColors.border,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isMarkedForReview ? Icons.flag_rounded : Icons.flag_outlined,
                                              size: 14,
                                              color: isMarkedForReview ? AppColors.warning : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Review',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isMarkedForReview ? AppColors.warning : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Optional Inline Type Selector (if session supports multiple inputs)
                                if (allowedTypes.length > 1) ...[
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: allowedTypes.map<Widget>((type) {
                                        final isSel = _activeQuestionTypeOverride == type;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                                          child: ChoiceChip(
                                            label: Text(type),
                                            selected: isSel,
                                            backgroundColor: AppColors.surface,
                                            selectedColor: AppColors.primary,
                                            labelStyle: TextStyle(
                                              color: isSel ? AppColors.background : AppColors.textSecondary,
                                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 12,
                                            ),
                                            side: BorderSide(
                                              color: isSel ? AppColors.primary : AppColors.border,
                                            ),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            onSelected: (_) {
                                              HapticFeedback.lightImpact();
                                              setState(() {
                                                _activeQuestionTypeOverride = type;
                                              });
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                          
                          // 6. DETAILED OPTION CARD STACK WITH FLOATING PALETTE OVERLAY
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // SELECT INPUT CONTAINER
                                  Positioned.fill(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: _buildAnswerSelectionUI(
                                        _activeQuestionTypeOverride,
                                        selectedAnswer,
                                      ),
                                    ),
                                  ),
                                  
                                  // PORTABLE PALETTE LAUNCHER FLAGGED GRID
                                  Positioned(
                                    bottom: 0,
                                    right: 4,
                                    child: FloatingActionButton(
                                      mini: true,
                                      backgroundColor: AppColors.surface,
                                      foregroundColor: AppColors.textPrimary,
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                        side: const BorderSide(color: AppColors.border, width: 1.5),
                                      ),
                                      onPressed: _showQuestionPalette,
                                      child: const Icon(Icons.grid_view_rounded, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // 7. BOTTOM NAVIGATION BAR BUTTONS CONTROLS
                          BottomNavigationControls(
                            currentNumber: state.currentQuestionIndex + 1,
                            totalQuestions: state.totalQuestions,
                            hasPrevious: state.currentQuestionIndex > 0,
                            isLastQuestion: state.currentQuestionIndex == state.totalQuestions - 1,
                            onPrevious: () {
                              ref.read(practiceStateProvider.notifier).previousQuestion();
                              _initializeInputTextForQuestion(state.currentQuestionIndex - 1);
                            },
                            onNext: () {
                              ref.read(practiceStateProvider.notifier).nextQuestion();
                              _initializeInputTextForQuestion(state.currentQuestionIndex + 1);
                            },
                            onSubmit: _handleSubmitSession,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Factory render selector depending on input type
  Widget _buildAnswerSelectionUI(String type, String? answer) {
    if (type == 'True / False' || type == 'True/False') {
      return Column(
        children: [
          const SizedBox(height: 12),
          AnswerOptionCard(
            label: 'TRUE',
            value: 'True',
            isMCQStyle: false,
            isSelected: answer == 'True',
            onTap: () => ref.read(practiceStateProvider.notifier).saveAnswer('True'),
          ),
          const SizedBox(height: 16),
          AnswerOptionCard(
            label: 'FALSE',
            value: 'False',
            isMCQStyle: false,
            isSelected: answer == 'False',
            onTap: () => ref.read(practiceStateProvider.notifier).saveAnswer('False'),
          ),
        ],
      );
    } else if (type == 'Integer') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: _integerInputController,
              focusNode: _integerFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1.0,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*$')),
              ],
              decoration: InputDecoration(
                hintText: 'Enter Answer',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                ),
              ),
              onChanged: (val) {
                ref.read(practiceStateProvider.notifier).saveAnswer(val.trim());
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Supports absolute integers or signed values.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    } else {
      // DEFAULT MCQ: 2x2 grid options
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: [
            AnswerOptionCard(
              label: 'A',
              value: 'A',
              isSelected: answer == 'A',
              onTap: () => ref.read(practiceStateProvider.notifier).saveAnswer('A'),
            ),
            AnswerOptionCard(
              label: 'B',
              value: 'B',
              isSelected: answer == 'B',
              onTap: () => ref.read(practiceStateProvider.notifier).saveAnswer('B'),
            ),
            AnswerOptionCard(
              label: 'C',
              value: 'C',
              isSelected: answer == 'C',
              onTap: () => ref.read(practiceStateProvider.notifier).saveAnswer('C'),
            ),
            AnswerOptionCard(
              label: 'D',
              value: 'D',
              isSelected: answer == 'D',
              onTap: () => ref.read(practiceStateProvider.notifier).saveAnswer('D'),
            ),
          ],
        ),
      );
    }
  }
}
