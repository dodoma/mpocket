class TeachPoint {
  int a;
  int b;

  TeachPoint(this.a, this.b);

  factory TeachPoint.fromList(List<dynamic> list) {
    return TeachPoint(list[0], list[1]);
  }

  List<int> toList() => [a, b];
}


class TeachNote {
  final String id;
  final List<TeachPoint> points;

  TeachNote({required this.id, required this.points});

  factory TeachNote.fromJson(Map<String, dynamic> json) {
    String id = json.keys.first;
    List<TeachPoint> pts = (json[id] as List)
        .map((item) => TeachPoint.fromList(item))
        .toList();
    return TeachNote(id: id, points: pts);
  }

  Map<String, dynamic> toJson() => {
    id: points.map((p) => p.toList()).toList(),
  };
}
