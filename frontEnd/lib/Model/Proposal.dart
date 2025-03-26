class Proposal {
  final String address;
  final String title;
  final String description;
  final int views;
  final DateTime proposalDate;

  Proposal({
    required this.address,
    required this.title,
    required this.description,
    required this.views,
    required this.proposalDate,
  });

  factory Proposal.fromMap(Map<String, dynamic> map) {
    return Proposal(
      address: map['address'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      views: map['views'] as int,
      proposalDate: map['date'] as DateTime,
    );
  }
}
