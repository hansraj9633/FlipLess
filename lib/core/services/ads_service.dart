abstract class AdsService {
  /// Initializes Google Mobile Ads SDK.
  Future<void> initialize();

  /// Loads and caches banner, interstitial, or rewarded ads.
  Future<void> loadBannerAd(String adUnitId);
  Future<void> loadInterstitialAd(String adUnitId);

  /// Displays interstitial ads between workflow screens (e.g. Session Completion).
  Future<void> showInterstitialAd();

  /// Returns true if ads are enabled (or based on dynamic configuration).
  bool get areAdsEnabled;
}
