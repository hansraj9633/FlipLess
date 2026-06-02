import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_service.dart';

class AdsServiceImpl implements AdsService {
  bool _initialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  // Key-value counters for ad impression tracking (Analytics)
  int _bannerImpressions = 0;
  int _interstitialImpressions = 0;
  int _interstitialShown = 0;
  int _interstitialFailed = 0;

  // Configurable Ad Unit IDs
  static String get bannerAdUnitId {
    const fromEnv = String.fromEnvironment('BANNER_AD_UNIT_ID', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Android Test Banner Ad unit
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get interstitialAdUnitId {
    const fromEnv = String.fromEnvironment('INTERSTITIAL_AD_UNIT_ID', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Android Test Interstitial Ad unit
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  int get bannerImpressions => _bannerImpressions;
  int get interstitialImpressions => _interstitialImpressions;
  int get interstitialShown => _interstitialShown;
  int get interstitialFailed => _interstitialFailed;

  void incrementBannerImpressions() {
    _bannerImpressions++;
    print('AdsAnalytics [BANNER]: Banner impression tracked. Total: $_bannerImpressions');
  }

  void incrementInterstitialImpressions() {
    _interstitialImpressions++;
    print('AdsAnalytics [INTERSTITIAL]: Interstitial impression tracked. Total: $_interstitialImpressions');
  }

  void incrementInterstitialShown() {
    _interstitialShown++;
    print('AdsAnalytics [INTERSTITIAL]: Interstitial shown tracked. Total: $_interstitialShown');
  }

  void incrementInterstitialFailed() {
    _interstitialFailed++;
    print('AdsAnalytics [INTERSTITIAL]: Interstitial failed tracked. Total: $_interstitialFailed');
  }

  @override
  bool get areAdsEnabled => true;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      print('Google Mobile Ads successfully initialized.');
    } catch (e) {
      print('Failed to initialize Google Mobile Ads SDK: $e');
    }
  }

  @override
  Future<void> loadBannerAd(String adUnitId) async {
    print('BannerAd requested loading for unit ID: $adUnitId');
  }

  @override
  Future<void> loadInterstitialAd(String adUnitId) async {
    if (_isInterstitialLoading) {
      print('Interstitial ad load already in progress.');
      return;
    }
    _isInterstitialLoading = true;
    print('Preloading interstitial ad for unit: $adUnitId');

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialLoading = false;
            incrementInterstitialImpressions();
            print('Interstitial ad loaded successfully.');

            _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                incrementInterstitialShown();
                print('Interstitial ad displayed full screen.');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('Interstitial ad dismissed by the user.');
                ad.dispose();
                _interstitialAd = null;
                // Preload in background for the next workflow completion
                loadInterstitialAd(adUnitId);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                incrementInterstitialFailed();
                print('Interstitial ad failed to show full screen: $error');
                ad.dispose();
                _interstitialAd = null;
                // Preload again in background
                loadInterstitialAd(adUnitId);
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _isInterstitialLoading = false;
            incrementInterstitialFailed();
            print('Interstitial ad failed to load: ${error.message} (code: ${error.code})');
          },
        ),
      );
    } catch (e) {
      _isInterstitialLoading = false;
      print('Exception preloading interstitial ad: $e');
    }
  }

  @override
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      print('No interstitial ad is cached yet. Triggering reload in background...');
      await loadInterstitialAd(interstitialAdUnitId);
      return;
    }
    try {
      await _interstitialAd!.show();
    } catch (e) {
      incrementInterstitialFailed();
      print('Error displaying cached interstitial ad: $e');
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    print('AdsService: Disposed interstitial ad cache.');
  }
}
