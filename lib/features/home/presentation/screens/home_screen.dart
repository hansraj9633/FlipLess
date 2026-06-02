import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/sessions_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';

import '../../../../core/services/adaptive_banner_ad_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _breathingController;
  late Animation<double> _breathingScale;

  // Animation controller for count-up stats
  late AnimationController _statsController;
  late Animation<double> _accuracyAnim;
  late Animation<double> _sessionsAnim;
  late Animation<double> _questionsAnim;
  late Animation<double> _studyTimeAnim;

  @override
  void initState() {
    super.initState();

    // 1. Entry Transition (250ms Fade + Slide Up)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(parent: _entryController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    // 2. FAB Breathing / Pulse Animation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _breathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));

    // 3. Stats Count-up Animations
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _accuracyAnim = Tween<double>(begin: 0, end: 78).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic),
    );
    _sessionsAnim = Tween<double>(begin: 0, end: 125).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic),
    );
    _questionsAnim = Tween<double>(begin: 0, end: 3421).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic),
    );
    _studyTimeAnim = Tween<double>(begin: 0, end: 81).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic),
    );

    // Run animations
    _entryController.forward();
    _statsController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _breathingController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  void _triggerHapticLight() {
    HapticFeedback.lightImpact();
  }

  void _triggerHapticMedium() {
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final settingsVal = ref.watch(settingsProvider);
    final sessionsVal = ref.watch(sessionsProvider);

    final String studentName = settingsVal.when(
      data: (settings) => settings.studentName,
      loading: () => 'Hans',
      error: (_, __) => 'Hans',
    );

    final String greetingText = _getGreeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 100.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HEADER SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Circular avatar
                              GestureDetector(
                                onTap: _triggerHapticLight,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.menu_book_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'FlipLess',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppTheme.fontFamilyName,
                                ),
                              ),
                            ],
                          ),
                          // Notification bell icon
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _triggerHapticLight();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No new notifications yet!'),
                                    backgroundColor: AppColors.surface,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.textPrimary,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. GREETING SECTION
                      Text(
                        '$greetingText, $studentName \u{1F44B}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ready to tackle your learning goals today?',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. STATISTICS CARD (2x2 Grid)
                      _buildStatsCard(),
                      const SizedBox(height: 32),

                      // 4. DRAFT SESSIONS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Draft Sessions',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Notification dot
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _triggerHapticLight();
                              // Actions or navigating
                            },
                            child: const Text(
                              'View all',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.semibold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Draft Cards Render from provider
                      sessionsVal.when(
                        data: (sessions) {
                          final drafts = sessions.where((s) => s.status == 'practicing').toList();
                          if (drafts.isEmpty) {
                            return _buildEmptyState();
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: drafts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final draft = drafts[index];
                              // Assign mockup icon based on index or name
                              final IconData icon = index == 0
                                  ? Icons.science_outlined
                                  : Icons.history_edu_outlined;
                              // Match exact percentage for simulation or count
                              final double progress = index == 0 ? 0.45 : 0.12;
                              return _buildDraftCard(
                                title: draft.subject,
                                progress: progress,
                                icon: icon,
                                routePath: '/practice',
                              );
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        error: (_, __) => _buildEmptyState(),
                      ),
                      const SizedBox(height: 24),

                      // 5. ADVERTISEMENT PLACEHOLDER
                      _buildAdPlaceholder(),
                      const SizedBox(height: 28),

                      // 6. RECENT ACTIVITY SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _triggerHapticLight();
                              context.go('/history');
                            },
                            child: const Text(
                              'Full History',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.semibold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recent Activity Card Layout
                      _buildRecentActivityLayout(),
                    ],
                  ),
                ),

                // 7. CREATE SESSION FLOATING BUTTON
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: ScaleTransition(
                      scale: _breathingScale,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Material(
                            color: AppColors.primary,
                            child: InkWell(
                              onTap: () {
                                _triggerHapticMedium();
                                context.go('/create-session');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: AppColors.background,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create Session',
                                      style: TextStyle(
                                        color: AppColors.background,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        ),
      ),
    );
  }

  // Get current greeting based on local time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildStatsCard() {
    return AnimatedBuilder(
      animation: _statsController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.largeRadiusVal),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Accuracy
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCURACY',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${_accuracyAnim.value.toInt()}%',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.trending_up,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Linear slider/progress bar
                        Container(
                          width: 120,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _accuracyAnim.value / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sessions
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SESSIONS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_sessionsAnim.value.toInt()}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '+12 this week',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Questions
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUESTIONS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatQuestions(_questionsAnim.value.toInt()),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Lifetime items',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Study Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STUDY TIME',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_studyTimeAnim.value.toInt()}h',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Deep focus flow',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatQuestions(int value) {
    if (value >= 1000) {
      final whole = value ~/ 1000;
      final rem = value % 1000;
      return '$whole,${rem.toString().padLeft(3, '0')}';
    }
    return value.toString();
  }

  Widget _buildDraftCard({
    required String title,
    required double progress,
    required IconData icon,
    required String routePath,
  }) {
    return _PressableScale(
      onTap: () {
        _triggerHapticLight();
        context.go(routePath);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            // Subject icon circular/rounded container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Subject progress info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Progress bar animating
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            color: AppColors.primary,
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.library_books_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          const Text(
            'No active sessions.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.semibold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _triggerHapticMedium();
              context.go('/create-session');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Create Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdPlaceholder() {
    return const AdaptiveBannerAdWidget();
  }

  Widget _buildRecentActivityLayout() {
    // 5 activities mirroring the design
    final activities = [
      _ActivityItem('Calculus III', 'Vector Fields', '92%', true),
      _ActivityItem('Organic Chem', 'Alkanes', '74%', false),
      _ActivityItem('Algorithms', 'Graph Theory', '88%', false),
      _ActivityItem('Ethics', 'Utilitarianism', '100%', true),
      _ActivityItem('Microbiology', 'Cell Wall', '62%', false),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: [
          // Table header
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'SUBJECT',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'SCORE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),

          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final act = activities[index];
              return _PressableScale(
                onTap: () {
                  _triggerHapticLight();
                  context.go('/result');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Left info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act.subject,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              act.topic,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Score
                      Text(
                        act.score,
                        style: TextStyle(
                          color: act.isA1 ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String subject;
  final String topic;
  final String score;
  final bool isA1; // high-level accuracy (e.g. 92%+ represents key/primary highlights)

  _ActivityItem(this.subject, this.topic, this.score, this.isA1);
}

// Reusable scale button wrapper as requested "Card tap: Scale 1.00 -> 0.98 -> 1.00"
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
