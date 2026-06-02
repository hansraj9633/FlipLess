import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/ads_provider.dart';

class VerifyAnswersScreen extends ConsumerWidget {
  const VerifyAnswersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Answer Keys'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fact_check_outlined,
                size: 80,
                color: Color(0xff5b8cff),
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Answer Alignment',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter actual correct letters or options from the book backend to run alignment.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go('/evaluation'),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Preload interstitial before generating result to ensure high reliability
                      ref.read(adsProvider.notifier).resetSessionAdFlag();
                      ref.read(adsProvider.notifier).loadInterstitial();
                      
                      context.go('/result');
                    },
                    child: const Text('Generate Result'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
