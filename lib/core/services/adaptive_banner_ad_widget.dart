import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_service_impl.dart';
import 'ads_provider.dart';

class AdaptiveBannerAdWidget extends ConsumerStatefulWidget {
  const AdaptiveBannerAdWidget({super.key});

  @override
  ConsumerState<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends ConsumerState<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  AdSize? _adaptiveAdSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdaptiveBanner();
  }

  Future<void> _loadAdaptiveBanner() async {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Get the anchored adaptive banner size
    final AdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      screenWidth.truncate()
    );

    if (size == null) {
      print('AdaptiveBannerAdWidget: Failed to retrieve adaptive size.');
      return;
    }

    if (!mounted) return;

    setState(() {
      _adaptiveAdSize = size;
      _isAdLoaded = false;
    });

    _bannerAd?.dispose();

    _bannerAd = BannerAd(
      adUnitId: AdsServiceImpl.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isAdLoaded = true;
          });
          // Update analytics and state metrics inside AdsProvider
          ref.read(adsProvider.notifier).recordBannerImpression();
          print('AdaptiveBannerAdWidget: Banner ad loaded successfully.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('AdaptiveBannerAdWidget: Failed to load: ${error.message} - Code: ${error.code}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _bannerAd = null;
            });
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || _adaptiveAdSize == null) {
      return Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff5b8cff)),
          ),
        ),
      );
    }

    return Container(
      width: _adaptiveAdSize!.width.toDouble(),
      height: _adaptiveAdSize!.height.toDouble(),
      alignment: Alignment.center,
      child: _isAdLoaded
          ? AdWidget(ad: _bannerAd!)
          : Container(
              color: Colors.transparent,
              child: const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff5b8cff)),
                ),
              ),
            ),
    );
  }
}
