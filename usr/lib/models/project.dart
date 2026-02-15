class Project {
  final String name;
  List<String> history;
  String summary;

  Project({
    required this.name,
    required this.history,
    required this.summary,
  });

  // Convertir en JSON (simulation pour le stockage GitHub)
  Map<String, dynamic> toJson() {
    return {
      'historique': history,
      'resume': summary,
    };
  }

  // Créer à partir de JSON
  factory Project.fromJson(String name, Map<String, dynamic> json) {
    return Project(
      name: name,
      history: List<String>.from(json['historique'] ?? []),
      summary: json['resume'] ?? "",
    );
  }
}
