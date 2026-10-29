import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../data/pdf_utils.dart";
import "../providers/providers.dart";

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});
  @override
  ConsumerState<ToolsScreen> createState() => _ToolsState();
}

class _ToolsState extends ConsumerState<ToolsScreen> {
  String? _busy;

  Future<String?> _pick() async =>
      (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["pdf"]))?.files.single.path;

  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _images() async {
    final p = await _pick();
    if (p == null) return;
    try {
      final dir = await exportPagesAsImages(p, (d, t) => setState(() => _busy = "Exportando páginas $d/$t"));
      _msg("Guardado en ${dir.path}");
    } catch (e) {
      _msg("Error: $e");
    }
    setState(() => _busy = null);
  }

  Future<void> _audio() async {
    final p = await _pick();
    if (p == null) return;
    setState(() => _busy = "Generando audio...");
    try {
      final s = ref.read(settingsProvider);
      final text = await extractText(p);
      final n = await ref.read(ttsProvider).exportAudio(text, p.split("/").last.replaceAll(".pdf", ""), s.speed, s.pitch);
      _msg("Se generaron $n archivos WAV (almacenamiento del motor TTS).");
    } catch (e) {
      _msg("Error: $e");
    }
    setState(() => _busy = null);
  }

  @override
  Widget build(BuildContext context) {
    Widget tool(IconData i, String t, String d, VoidCallback f) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(contentPadding: const EdgeInsets.all(16), leading: Icon(i, size: 36), title: Text(t), subtitle: Text(d), onTap: _busy == null ? f : null),
        );
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Text("Herramientas", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        tool(Icons.image_outlined, "Extraer imágenes", "Exporta cada página del PDF como PNG de alta resolución", _images),
        tool(Icons.audiotrack_outlined, "Texto a audio", "Convierte el PDF en archivos de audio (Android)", _audio),
        if (_busy != null) Padding(padding: const EdgeInsets.all(16), child: Column(children: [const LinearProgressIndicator(), const SizedBox(height: 8), Text(_busy!)])),
      ]),
    );
  }
}
