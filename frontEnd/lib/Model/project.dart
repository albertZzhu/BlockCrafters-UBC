class Project {
  final String name;
  final String imageUrl;
  final String descriptionCid;
  final double goal;
  final double raised;
  final DateTime deadline;
  final String status;

  Project({
    required this.name,
    required this.imageUrl,
    required this.descriptionCid,
    required this.goal,
    required this.raised,
    required this.deadline,
    required this.status,
  });
}
