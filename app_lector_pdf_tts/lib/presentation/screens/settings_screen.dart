import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/providers.dart";

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Text("Ajustes", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text("Velocidad de lectura: ${s.speed.toStringAsFixed(2)}x"),
        Slider(value: s.speed, min: 0.75, max: 2.0, onChanged: (v) => n.update(speed: v)),
        Text("Tono: ${s.pitch.toStringAsFixed(2)}"),
        Slider(value: s.pitch, min: 0.5, max: 2.0, onChanged: (v) => n.update(pitch: v)),
        SwitchListTile(title: const Text("Tema oscuro de la app"), value: s.dark, onChanged: (v) => n.update(dark: v)),
        const ListTile(title: Text("App Lector PDF & TTS"), subtitle: Text("v1.0.0 · Procesamiento 100 % local")),
      ]),
    );
  }
}
