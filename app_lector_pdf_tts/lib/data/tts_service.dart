import "package:flutter/foundation.dart";
import "package:flutter_tts/flutter_tts.dart";

enum TtsState { idle, playing, paused, stopped }

/// Envuelve el motor TTS nativo (Android TextToSpeech / AVSpeech).
class TtsService {
  final _tts = FlutterTts();
  final state = ValueNotifier(TtsState.idle);
  List<String> _chunks = [];
  int _i = 0;

  Future<void> init() async {
    await _tts.setLanguage("es-ES");
    await _tts.setVolume(1.0);
    await _tts.awaitSynthCompletion(true);
    _tts.setCompletionHandler(() {
      if (state.value == TtsState.playing) {
        _i++;
        _next();
      }
    });
    _tts.setErrorHandler((_) => state.value = TtsState.stopped);
  }

  // El motor Android limita ~4000 caracteres por llamada: se parte por frases.
  static List<String> split(String t, [int max = 3000]) {
    final out = <String>[];
    final buf = StringBuffer();
    for (final s in t.replaceAll(RegExp(r"\s+"), " ").split(RegExp(r"(?<=[.!?])\s"))) {
      if (buf.length + s.length > max && buf.isNotEmpty) {
        out.add(buf.toString());
        buf.clear();
      }
      buf.write("$s ");
    }
    if (buf.isNotEmpty) out.add(buf.toString());
    return out;
  }

  Future<void> configure(double speed, double pitch) async {
    await _tts.setSpeechRate((speed / 2).clamp(0.05, 1.0)); // 1.0x ≈ 0.5 en flutter_tts
    await _tts.setPitch(pitch);
  }

  Future<void> play(String text, double speed, double pitch) async {
    await configure(speed, pitch);
    if (state.value != TtsState.paused) {
      _chunks = split(text);
      _i = 0;
    }
    state.value = TtsState.playing;
    _next();
  }

  Future<void> _next() async {
    if (_i >= _chunks.length) {
      _i = 0;
      state.value = TtsState.idle;
      return;
    }
    await _tts.speak(_chunks[_i]);
  }

  Future<void> pause() async {
    state.value = TtsState.paused;
    await _tts.stop();
  }

  Future<void> stop() async {
    state.value = TtsState.stopped;
    _i = 0;
    await _tts.stop();
  }

  /// Exporta a archivos WAV (solo Android). Devuelve cuántos archivos generó.
  Future<int> exportAudio(String text, String base, double speed, double pitch) async {
    await configure(speed, pitch);
    final parts = split(text);
    for (var n = 0; n < parts.length; n++) {
      await _tts.synthesizeToFile(parts[n], "${base}_${(n + 1).toString().padLeft(3, "0")}.wav");
    }
    return parts.length;
  }

  void dispose() => _tts.stop();
}
