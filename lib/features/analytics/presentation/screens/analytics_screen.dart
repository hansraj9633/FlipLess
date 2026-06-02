import 'package:flutter/material.dart';
import '../../../../core/services/adaptive_banner_ad_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Analytics'),
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
                        Icons.analytics,
                        size: 80,
                        color: Color(0xff5b8cff),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Skill Growth Analytics',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Visually trace accurate trends, speed analytics per book page, and subject weak spots.',
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
          const AdaptiveBannerAdWidget(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
