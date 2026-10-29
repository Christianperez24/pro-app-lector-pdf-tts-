import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/providers.dart";
import "viewer_screen.dart";

String fmtSize(int b) => b > 1048576 ? "${(b / 1048576).toStringAsFixed(1)} MB" : "${(b / 1024).round()} KB";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  String q = "";

  Future<void> _import() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["pdf"]);
    final path = r?.files.single.path;
    if (path == null) return;
    final doc = await ref.read(repoProvider).import(path);
    ref.read(docsProvider.notifier).add(doc);
    if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ViewerScreen(doc: doc)));
  }

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(docsProvider).where((d) => d.name.toLowerCase().contains(q.toLowerCase())).toList();
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(hintText: "Buscar archivo...", leading: const Icon(Icons.search), onChanged: (v) => setState(() => q = v)),
          ),
          Expanded(
            child: docs.isEmpty
                ? const Center(child: Text("Importa un PDF para empezar"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final d = docs[i];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf, size: 32),
                          title: Text(d.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text("Leído ${(d.progress * 100).round()}% · ${fmtSize(d.size)}"),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewerScreen(doc: d))),
                        ),
                      );
                    }),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _import, icon: const Icon(Icons.add), label: const Text("Importar")),
    );
  }
}
