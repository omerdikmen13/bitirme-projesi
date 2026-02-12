class AlbumModel {
  final int? id;
  final String name;
  final String? description;
  final int? coverPhotoId;
  final String? coverPhotoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int photoCount;

  AlbumModel({
    this.id,
    required this.name,
    this.description,
    this.coverPhotoId,
    this.coverPhotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.photoCount = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AlbumModel.fromMap(Map<String, dynamic> map) {
    return AlbumModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverPhotoId: map['cover_photo_id'] as int?,
      coverPhotoPath: map['cover_photo_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      photoCount: map['photo_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'cover_photo_id': coverPhotoId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AlbumModel copyWith({
    int? id,
    String? name,
    String? description,
    int? coverPhotoId,
    String? coverPhotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? photoCount,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPhotoId: coverPhotoId ?? this.coverPhotoId,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      photoCount: photoCount ?? this.photoCount,
    );
  }

  @override
  String toString() => 'AlbumModel(id: $id, name: $name, photoCount: $photoCount)';
}
