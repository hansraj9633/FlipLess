import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ads_service_impl.dart';

enum AdsStatus {
  uninitialized,
  initializing,
  initialized,
  loadingAd,
  readyAd,
  failed,
}

class AdsState {
  final AdsStatus status;
  final String? errorMessage;
  final int bannerImpressionsCount;
  final int interstitialImpressionsCount;
  final int interstitialShownCount;
  final int interstitialFailedCount;
  final bool hasShownInterstitialForCurrentSession;

  const AdsState({
    required this.status,
    this.errorMessage,
    this.bannerImpressionsCount = 0,
    this.interstitialImpressionsCount = 0,
    this.interstitialShownCount = 0,
    this.interstitialFailedCount = 0,
    this.hasShownInterstitialForCurrentSession = false,
  });

  AdsState copyWith({
    AdsStatus? status,
    String? errorMessage,
    int? bannerImpressionsCount,
    int? interstitialImpressionsCount,
    int? interstitialShownCount,
    int? interstitialFailedCount,
    bool? hasShownInterstitialForCurrentSession,
  }) {
    return AdsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      bannerImpressionsCount: bannerImpressionsCount ?? this.bannerImpressionsCount,
      interstitialImpressionsCount: interstitialImpressionsCount ?? this.interstitialImpressionsCount,
      interstitialShownCount: interstitialShownCount ?? this.interstitialShownCount,
      interstitialFailedCount: interstitialFailedCount ?? this.interstitialFailedCount,
      hasShownInterstitialForCurrentSession: hasShownInterstitialForCurrentSession ?? this.hasShownInterstitialForCurrentSession,
    );
  }
}

class AdsNotifier extends StateNotifier<AdsState> {
  final AdsServiceImpl _adsService;

  AdsNotifier(this._adsService) : super(const AdsState(status: AdsStatus.uninitialized)) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(status: AdsStatus.initializing);
    try {
      await _adsService.initialize();
      state = state.copyWith(
        status: AdsStatus.initialized,
        bannerImpressionsCount: _adsService.bannerImpressions,
        interstitialImpressionsCount: _adsService.interstitialImpressions,
        interstitialShownCount: _adsService.interstitialShown,
        interstitialFailedCount: _adsService.interstitialFailed,
      );
      // Preload interstitial right away
      await loadInterstitial();
    } catch (e) {
      state = state.copyWith(
        status: AdsStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadInterstitial() async {
    state = state.copyWith(status: AdsStatus.loadingAd);
    try {
      await _adsService.loadInterstitialAd(AdsServiceImpl.interstitialAdUnitId);
      _syncMetrics(AdsStatus.readyAd);
    } catch (e) {
      _syncMetrics(AdsStatus.failed, errorMessage: e.toString());
    }
  }

  Future<void> showInterstitial() async {
    if (state.hasShownInterstitialForCurrentSession) {
      print('AdsNotifier: Skip interstitial ad. Limit: max 1 per session.');
      return;
    }
    try {
      await _adsService.showInterstitialAd();
      state = state.copyWith(hasShownInterstitialForCurrentSession: true);
      _syncMetrics(state.status);
    } catch (e) {
      _syncMetrics(state.status, errorMessage: e.toString());
    }
  }

  void resetSessionAdFlag() {
    state = state.copyWith(hasShownInterstitialForCurrentSession: false);
    print('AdsNotifier: Session reset. Ready to request 1 new interstitial ad.');
  }

  void recordBannerImpression() {
    _adsService.incrementBannerImpressions();
    _syncMetrics(state.status);
  }

  void _syncMetrics(AdsStatus currentStatus, {String? errorMessage}) {
    state = state.copyWith(
      status: currentStatus,
      errorMessage: errorMessage,
      bannerImpressionsCount: _adsService.bannerImpressions,
      interstitialImpressionsCount: _adsService.interstitialImpressions,
      interstitialShownCount: _adsService.interstitialShown,
      interstitialFailedCount: _adsService.interstitialFailed,
    );
  }
}

final adsServiceProvider = Provider<AdsServiceImpl>((ref) {
  final impl = AdsServiceImpl();
  ref.onDispose(() {
    impl.dispose();
  });
  return impl;
});

final adsProvider = StateNotifierProvider<AdsNotifier, AdsState>((ref) {
  final service = ref.watch(adsServiceProvider);
  return AdsNotifier(service);
});
