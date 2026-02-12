class PhotoModel {
  final int? id;
  final String filePath;
  final String fileName;
  final int? width;
  final int? height;
  final int? sizeBytes;
  final DateTime? dateTaken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isDeleted;
  final DateTime? deletedAt;

  PhotoModel({
    this.id,
    required this.filePath,
    required this.fileName,
    this.width,
    this.height,
    this.sizeBytes,
    this.dateTaken,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      width: map['width'] as int?,
      height: map['height'] as int?,
      sizeBytes: map['size_bytes'] as int?,
      dateTaken: map['date_taken'] != null 
          ? DateTime.tryParse(map['date_taken'] as String) 
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isFavorite: (map['is_favorite'] as int?) == 1,
      isDeleted: (map['is_deleted'] as int?) == 1,
      deletedAt: map['deleted_at'] != null 
          ? DateTime.tryParse(map['deleted_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_path': filePath,
      'file_name': fileName,
      'width': width,
      'height': height,
      'size_bytes': sizeBytes,
      'date_taken': dateTaken?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  PhotoModel copyWith({
    int? id,
    String? filePath,
    String? fileName,
    int? width,
    int? height,
    int? sizeBytes,
    DateTime? dateTaken,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      dateTaken: dateTaken ?? this.dateTaken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  String get dateGroup {
    final date = dateTaken ?? createdAt;
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  String toString() => 'PhotoModel(id: $id, fileName: $fileName)';
}
