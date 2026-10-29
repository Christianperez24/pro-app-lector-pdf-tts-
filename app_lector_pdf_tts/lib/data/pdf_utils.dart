import "dart:io";
import "package:flutter/foundation.dart";
import "package:path_provider/path_provider.dart";
import "package:pdfx/pdfx.dart" as px;
import "package:syncfusion_flutter_pdf/pdf.dart";

String _extract(String path) {
  final d = PdfDocument(inputBytes: File(path).readAsBytesSync());
  final t = PdfTextExtractor(d).extractText();
  d.dispose();
  return t;
}

/// Extrae el texto en un Isolate para no bloquear la UI.
Future<String> extractText(String path) => compute(_extract, path);

/// Renderiza cada página a PNG (alta resolución), una a una, sin picos de memoria.
Future<Directory> exportPagesAsImages(String path, void Function(int done, int total) onProgress) async {
  final base = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
  final name = path.split("/").last.replaceAll(".pdf", "");
  final out = Directory("${base.path}/appLector/$name")..createSync(recursive: true);
  final doc = await px.PdfDocument.openFile(path);
  for (var i = 1; i <= doc.pagesCount; i++) {
    final page = await doc.getPage(i);
    final img = await page.render(width: page.width * 2, height: page.height * 2, format: px.PdfPageImageFormat.png);
    await page.close();
    if (img != null) await File("${out.path}/pagina_${i.toString().padLeft(3, "0")}.png").writeAsBytes(img.bytes);
    onProgress(i, doc.pagesCount);
  }
  await doc.close();
  return out;
}
