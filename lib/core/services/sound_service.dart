abstract class SoundService {
  /// Plays audio cue when an answer is marked correct.
  Future<void> playSuccessSound();

  /// Plays audio cue when an answer is marked incorrect.
  Future<void> playFailureSound();

  /// Plays a general chime when a session finishes.
  Future<void> playSessionCompletedSound();
}
