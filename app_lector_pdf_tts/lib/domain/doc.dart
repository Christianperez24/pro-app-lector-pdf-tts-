class Doc {
  final String path, name;
  final int size;
  final double progress; // 0..1
  const Doc(this.path, this.name, this.size, [this.progress = 0]);
  Doc withProgress(double p) => Doc(path, name, size, p);
  Map<String, dynamic> toJson() => {"p": path, "n": name, "s": size, "r": progress};
  factory Doc.fromJson(Map<String, dynamic> j) => Doc(j["p"], j["n"], j["s"], (j["r"] as num).toDouble());
}
