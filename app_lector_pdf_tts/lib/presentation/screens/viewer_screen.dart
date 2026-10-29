import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:syncfusion_flutter_pdfviewer/pdfviewer.dart";
import "../../core/theme.dart";
import "../../data/pdf_utils.dart";
import "../../data/tts_service.dart";
import "../../domain/doc.dart";
import "../providers/providers.dart";

enum ReadMode { light, sepia, dark }

class ViewerScreen extends ConsumerStatefulWidget {
  final Doc doc;
  const ViewerScreen({super.key, required this.doc});
  @override
  ConsumerState<ViewerScreen> createState() => _ViewerState();
}

class _ViewerState extends ConsumerState<ViewerScreen> {
  final _pdf = PdfViewerController();
  ReadMode _mode = ReadMode.light;
  String? _text;
  bool _loading = false;
  int _pages = 1;
  late final _tts = ref.read(ttsProvider);

  @override
  void dispose() {
    _tts.stop(); // sin servicio en primer plano aún: se detiene al salir
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_tts.state.value == TtsState.playing) return _tts.pause();
    final s = ref.read(settingsProvider);
    if (_text == null) {
      setState(() => _loading = true);
      _text = await extractText(widget.doc.path);
      if (mounted) setState(() => _loading = false);
    }
    if (_text!.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Este PDF no tiene texto (¿escaneado?).")));
      }
      return;
    }
    await _tts.play(_text!, s.speed, s.pitch);
  }

  List<double> get _matrix => switch (_mode) { ReadMode.light => kIdentity, ReadMode.sepia => kSepia, ReadMode.dark => kInvert };

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            tooltip: "Modo de lectura",
            icon: Icon(switch (_mode) { ReadMode.light => Icons.light_mode, ReadMode.sepia => Icons.coffee, ReadMode.dark => Icons.dark_mode }),
            onPressed: () => setState(() => _mode = ReadMode.values[(_mode.index + 1) % 3]),
          ),
        ],
      ),
      body: ColorFiltered(
        colorFilter: ColorFilter.matrix(_matrix),
        child: SfPdfViewer.file(
          File(widget.doc.path),
          controller: _pdf,
          onDocumentLoaded: (d) {
            _pages = d.document.pages.count;
            _pdf.jumpToPage((widget.doc.progress * _pages).round().clamp(1, _pages));
          },
          onPageChanged: (d) => ref.read(docsProvider.notifier).setProgress(widget.doc.path, d.newPageNumber / _pages),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Row(children: [
            ValueListenableBuilder(
              valueListenable: _tts.state,
              builder: (_, st, __) => _loading
                  ? const SizedBox(width: 56, height: 56, child: Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator()))
                  : IconButton.filled(iconSize: 32, onPressed: _toggle, icon: Icon(st == TtsState.playing ? Icons.pause : Icons.play_arrow)),
            ),
            IconButton(iconSize: 28, onPressed: _tts.stop, icon: const Icon(Icons.stop)),
            const Spacer(),
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: speeds
                      .map((v) => Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: ChoiceChip(
                              label: Text("${v}x"),
                              selected: s.speed == v,
                              onSelected: (_) async {
                                await ref.read(settingsProvider.notifier).update(speed: v);
                                if (_tts.state.value == TtsState.playing) {
                                  await _tts.pause();
                                  await _toggle();
                                }
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
