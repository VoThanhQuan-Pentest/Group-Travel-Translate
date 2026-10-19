class Stage {
  final String id;
  final String name;
  final int order;
  final String? description;

  const Stage({
    required this.id,
    required this.name,
    required this.order,
    this.description,
  });

  Stage copyWith({
    String? id,
    String? name,
    int? order,
    String? description,
  }) {
    return Stage(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order': order,
        'description': description,
      };

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
        id: json['id'] as String,
        name: json['name'] as String,
        order: json['order'] as int,
        description: json['description'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          order == other.order;

  @override
  int get hashCode => Object.hash(id, name, order);
}
