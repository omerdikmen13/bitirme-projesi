class LabelModel {
  final int? id;
  final String name;
  final String? nameTr;
  final String? category;
  final DateTime createdAt;

  LabelModel({
    this.id,
    required this.name,
    this.nameTr,
    this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory LabelModel.fromMap(Map<String, dynamic> map) {
    return LabelModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      nameTr: map['name_tr'] as String?,
      category: map['category'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_tr': nameTr,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'LabelModel(id: $id, name: $name)';
}

class PhotoLabelModel {
  final int photoId;
  final int labelId;
  final double confidence;
  final DateTime createdAt;
  final String? labelName;

  PhotoLabelModel({
    required this.photoId,
    required this.labelId,
    required this.confidence,
    DateTime? createdAt,
    this.labelName,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PhotoLabelModel.fromMap(Map<String, dynamic> map) {
    return PhotoLabelModel(
      photoId: map['photo_id'] as int,
      labelId: map['label_id'] as int,
      confidence: (map['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      labelName: map['label_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photo_id': photoId,
      'label_id': labelId,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
