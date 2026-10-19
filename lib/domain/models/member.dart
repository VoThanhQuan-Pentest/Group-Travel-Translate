class Member {
  final String id;
  final String name;
  final bool isTreasurer;
  final bool isActive;

  const Member({
    required this.id,
    required this.name,
    this.isTreasurer = false,
    this.isActive = true,
  });

  Member copyWith({
    String? id,
    String? name,
    bool? isTreasurer,
    bool? isActive,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      isTreasurer: isTreasurer ?? this.isTreasurer,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isTreasurer': isTreasurer,
        'isActive': isActive,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        name: json['name'] as String,
        isTreasurer: json['isTreasurer'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          isTreasurer == other.isTreasurer &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(id, name, isTreasurer, isActive);
}
