import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../data/doc_repository.dart";
import "../../data/tts_service.dart";
import "../../domain/doc.dart";

final repoProvider = Provider((_) => DocRepository());

final ttsProvider = Provider((ref) {
  final s = TtsService()..init();
  ref.onDispose(s.dispose);
  return s;
});

class Settings {
  final double speed, pitch;
  final bool dark;
  const Settings({this.speed = 1.0, this.pitch = 1.0, this.dark = false});
  Settings copy({double? speed, double? pitch, bool? dark}) =>
      Settings(speed: speed ?? this.speed, pitch: pitch ?? this.pitch, dark: dark ?? this.dark);
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(const Settings()) {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = Settings(speed: p.getDouble("speed") ?? 1.0, pitch: p.getDouble("pitch") ?? 1.0, dark: p.getBool("dark") ?? false);
  }

  Future<void> update({double? speed, double? pitch, bool? dark}) async {
    state = state.copy(speed: speed, pitch: pitch, dark: dark);
    final p = await SharedPreferences.getInstance();
    await p.setDouble("speed", state.speed);
    await p.setDouble("pitch", state.pitch);
    await p.setBool("dark", state.dark);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((_) => SettingsNotifier());

class DocsNotifier extends StateNotifier<List<Doc>> {
  final DocRepository repo;
  DocsNotifier(this.repo) : super([]) {
    repo.load().then((l) => state = l);
  }
  void add(Doc d) {
    state = [d, ...state.where((x) => x.path != d.path)].take(20).toList();
    repo.save(state);
  }

  void setProgress(String path, double p) {
    state = [for (final d in state) d.path == path ? d.withProgress(p) : d];
    repo.save(state);
  }
}

final docsProvider = StateNotifierProvider<DocsNotifier, List<Doc>>((ref) => DocsNotifier(ref.read(repoProvider)));
