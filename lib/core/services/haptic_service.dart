abstract class HapticService {
  /// Generates light tactile impact for scroll updates or subtle taps.
  Future<void> triggerLightImpact();

  /// Generates medium/heavy tactile feedback for correct answers or correct/incorrect feedback toggles.
  Future<void> triggerMediumImpact();

  /// Generates explicit success/notification vibrations on session completions.
  Future<void> triggerSuccessFeedback();
  Future<void> triggerFailureFeedback();
}
