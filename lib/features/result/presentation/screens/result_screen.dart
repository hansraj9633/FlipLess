import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/ads_provider.dart';
import '../../../../core/services/adaptive_banner_ad_widget.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule interstitial ad trigger 3 seconds after screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerDelayedInterstitial();
    });
  }

  Future<void> _triggerDelayedInterstitial() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    // Safely request to show preloaded ad via Riverpod AdsProvider
    ref.read(adsProvider.notifier).showInterstitial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Performance'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: Color(0xff22c55e),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Performance Summary',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Review your correct items, negative marks deducted, time utilized, and AI explanations.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Adaptive Banner Ad displayed above action buttons
          const AdaptiveBannerAdWidget(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Home Dashboard'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
