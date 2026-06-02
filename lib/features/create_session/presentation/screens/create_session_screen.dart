import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/create_session_provider.dart';
import '../widgets/create_session_form.dart';
import '../widgets/create_session_widgets.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Screen entry animation: Fade + Slide Up, 250ms as specified
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    _animationController.forward();
    
    // Reset state when opening the screen to ensure fresh form, or keep loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createSessionProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final notifier = ref.read(createSessionProvider.notifier);
    
    final sessionId = await notifier.createSession();
    if (sessionId != null) {
      // Success feedback haptics!
      HapticFeedback.vibrate();

      if (mounted) {
        // Show success SnackBar or action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Practice session created successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Navigate to Practice Screen
        context.go('/practice');
      }
    } else {
      // Validation failure or error state
      HapticFeedback.vibrate(); // alert-like feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please fix configuration errors'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Create Session',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive width limiter for larger screens (tablets/foldables)
            final double maxWidth = constraints.maxWidth > 600 ? 550 : double.infinity;
            
            return Center(
              child: SizedBox(
                width: maxWidth,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App Subtitle / Introduction
                          const Padding(
                            padding: EdgeInsets.only(bottom: 24.0, left: 4.0),
                            child: Text(
                              'Set up your practice session in under a minute.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          
                          // Form with standard options (Subject, Topic, Questions, Types)
                          const CreateSessionForm(),
                          const SizedBox(height: 16),
                          
                          // Advanced settings collapsible selector
                          const AdvancedSettingsSection(),
                          const SizedBox(height: 20),
                          
                          // Dash-bordered Live Session Preview Card
                          const SessionPreviewCard(),
                          const SizedBox(height: 24),
                          
                          // Main large continue action
                          ContinueButton(
                            onPressed: _handleContinue,
                            isLoading: state.isSaving,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
