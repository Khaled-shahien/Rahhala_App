import 'package:flutter_tts/flutter_tts.dart';

/// Service wrapping [FlutterTts] for trip navigation voice guidance.
///
/// Extracted from [_FullScreenDayRouteMapState] to keep TTS concerns
/// separate from map/widget logic and to improve testability.
class TripNavigationVoiceService {
  TripNavigationVoiceService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _isConfigured = false;

  /// Configure TTS engine parameters.
  ///
  /// Safe to call multiple times; configuration happens only once.
  Future<void> configure({
    double speechRate = 0.46,
    double volume = 1.0,
    double pitch = 1.0,
    String language = 'en-US',
  }) async {
    if (_isConfigured) return;
    await _tts.setSpeechRate(speechRate);
    await _tts.setVolume(volume);
    await _tts.setPitch(pitch);
    await _tts.setLanguage(language);
    _isConfigured = true;
  }

  /// Speak the given [text] after stopping any current speech.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stop any current speech output.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Release TTS resources.
  ///
  /// Call this when the navigation screen is disposed.
  void dispose() {
    _tts.stop();
    // TODO: Consider calling _tts.shutdown() if deeper cleanup is needed.
  }
}
