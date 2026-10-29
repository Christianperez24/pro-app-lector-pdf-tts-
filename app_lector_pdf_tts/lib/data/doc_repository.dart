import "dart:convert";
import "dart:io";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../domain/doc.dart";

class DocRepository {
  static const _k = "recents";
  Future<List<Doc>> load() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_k) ?? []).map((s) => Doc.fromJson(jsonDecode(s))).where((d) => File(d.path).existsSync()).toList();
  }

  Future<void> save(List<Doc> l) async =>
      (await SharedPreferences.getInstance()).setStringList(_k, l.map((d) => jsonEncode(d.toJson())).toList());

  /// Copia el archivo al almacenamiento privado de la app (el cache del picker es temporal).
  Future<Doc> import(String src) async {
    final dir = Directory("${(await getApplicationDocumentsDirectory()).path}/docs")..createSync(recursive: true);
    final name = src.split(Platform.pathSeparator).last;
    final f = await File(src).copy("${dir.path}/$name");
    return Doc(f.path, name, await f.length());
  }
}
