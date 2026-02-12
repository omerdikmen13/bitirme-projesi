import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  static Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    _database ??= await _initDB('smart_gallery_v2.db');
    return _database!;
  }
  
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    
    debugPrint('Veritabanı konumu: $path');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }
  
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL UNIQUE,
        file_name TEXT NOT NULL,
        width INTEGER,
        height INTEGER,
        size_bytes INTEGER,
        date_taken TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        deleted_at TEXT
      )
    ''');
    
    await db.execute('CREATE INDEX idx_photos_date ON photos(date_taken DESC)');
    await db.execute('CREATE INDEX idx_photos_favorite ON photos(is_favorite)');
    await db.execute('CREATE INDEX idx_photos_deleted ON photos(is_deleted)');
    
    await db.execute('''
      CREATE TABLE labels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        name_tr TEXT,
        category TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_labels_name ON labels(name)');
    await db.execute('CREATE INDEX idx_labels_name_tr ON labels(name_tr)');
    
    await db.execute('''
      CREATE TABLE photo_labels (
        photo_id INTEGER NOT NULL,
        label_id INTEGER NOT NULL,
        confidence REAL NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (photo_id, label_id),
        FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE,
        FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_photo_labels_photo ON photo_labels(photo_id)');
    await db.execute('CREATE INDEX idx_photo_labels_label ON photo_labels(label_id)');
    
    await db.execute('''
      CREATE TABLE albums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        cover_photo_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (cover_photo_id) REFERENCES photos(id) ON DELETE SET NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE album_photos (
        album_id INTEGER NOT NULL,
        photo_id INTEGER NOT NULL,
        added_at TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        PRIMARY KEY (album_id, photo_id),
        FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE,
        FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_album_photos_album ON album_photos(album_id)');
    
    await _createFaceTables(db);
  }
  
  Future<void> _createFaceTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        thumbnail_path TEXT,
        photo_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS faces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        photo_path TEXT NOT NULL,
        person_id INTEGER,
        bounding_box TEXT NOT NULL,
        face_data TEXT,
        is_face_scanned INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_faces_photo ON faces(photo_path)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_faces_person ON faces(person_id)');
    
    debugPrint(' Yüz tabloları oluşturuldu');
  }
  
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint(' Veritabanı yükseltiliyor: v$oldVersion -> v$newVersion');
    
    if (oldVersion < 2) {
      await _createFaceTables(db);
    }
  }
  
  Future<int> insertFace({
    required String filePath,
    required Map<String, dynamic> boundingBox,
    Map<String, dynamic>? faceData,
    int? personId,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    return await db.insert('faces', {
      'photo_path': filePath,
      'person_id': personId,
      'bounding_box': boundingBox.toString(),
      'face_data': faceData?.toString(),
      'created_at': now,
    });
  }
  
  Future<List<Map<String, dynamic>>> getFacesForPhoto(String filePath) async {
    final db = await database;
    return await db.query(
      'faces',
      where: 'photo_path = ?',
      whereArgs: [filePath],
    );
  }
  
  Future<bool> isPhotoFaceScanned(String filePath) async {
    final db = await database;
    final result = await db.query(
      'faces',
      where: 'photo_path = ?',
      whereArgs: [filePath],
      limit: 1,
    );
    return result.isNotEmpty;
  }
  
  Future<int> getFaceCountForPhoto(String filePath) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM faces WHERE photo_path = ?',
      [filePath],
    );
    return result.first['count'] as int? ?? 0;
  }
  
  Future<List<Map<String, dynamic>>> getAllFacesGroupedByPhoto() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT f.photo_path, COUNT(*) as face_count, f.created_at
      FROM faces f
      LEFT JOIN photos p ON f.photo_path = p.file_path
      WHERE p.is_deleted = 0 OR p.id IS NULL
      GROUP BY f.photo_path
      ORDER BY f.created_at DESC
    ''');
  }
  
  Future<void> clearAllLabels() async {
    final db = await database;
    await db.delete('photo_labels');
    await db.delete('labels');
    debugPrint(' Tüm etiketler temizlendi');
  }
  
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('faces');
    await db.delete('persons');
    await db.delete('photo_labels');
    await db.delete('labels');
    await db.delete('album_photos');
    await db.delete('albums');
    await db.delete('photos');
    debugPrint('🗑️ Tüm veriler temizlendi');
  }
  
  Future<int> insertPhoto(PhotoModel photo) async {
    final db = await database;
    return await db.insert(
      'photos',
      photo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<PhotoModel?> getPhotoByPath(String filePath) async {
    final db = await database;
    final maps = await db.query(
      'photos',
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
    
    if (maps.isEmpty) return null;
    return PhotoModel.fromMap(maps.first);
  }
  
  Future<PhotoModel?> getPhotoById(int id) async {
    final db = await database;
    final maps = await db.query(
      'photos',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return PhotoModel.fromMap(maps.first);
  }
  
  Future<List<PhotoModel>> getAllPhotos({int? limit, int? offset}) async {
    final db = await database;
    final maps = await db.query(
      'photos',
      where: 'is_deleted = 0',
      orderBy: 'date_taken DESC, created_at DESC',
      limit: limit,
      offset: offset,
    );
    
    return maps.map((m) => PhotoModel.fromMap(m)).toList();
  }
  
  Future<bool> hasPhoto(String filePath) async {
    final db = await database;
    final result = await db.query(
      'photos',
      columns: ['id'],
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
    return result.isNotEmpty;
  }
  
  Future<void> addToFavorites(String filePath) async {
    final db = await database;
    await db.update(
      'photos',
      {'is_favorite': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
  }
  
  Future<void> removeFromFavorites(String filePath) async {
    final db = await database;
    await db.update(
      'photos',
      {'is_favorite': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
  }
  
  Future<bool> isFavorite(String filePath) async {
    final db = await database;
    final result = await db.query(
      'photos',
      columns: ['is_favorite'],
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
    if (result.isEmpty) return false;
    return result.first['is_favorite'] == 1;
  }
  
  Future<List<PhotoModel>> getFavoritePhotos() async {
    final db = await database;
    final maps = await db.query(
      'photos',
      where: 'is_favorite = 1 AND is_deleted = 0',
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => PhotoModel.fromMap(m)).toList();
  }
  
  Future<void> moveToTrash(String filePath) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final existing = await db.query(
      'photos',
      columns: ['id'],
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
    
    if (existing.isEmpty) {
      final fileName = filePath.split('/').last;
      await db.insert('photos', {
        'file_path': filePath,
        'file_name': fileName,
        'created_at': now,
        'updated_at': now,
        'is_deleted': 1,
        'deleted_at': now,
      });
      debugPrint(' Fotoğraf eklendi ve çöpe taşındı: $fileName');
    } else {
      await db.update(
        'photos',
        {
          'is_deleted': 1,
          'deleted_at': now,
          'updated_at': now,
        },
        where: 'file_path = ?',
        whereArgs: [filePath],
      );
      debugPrint(' Fotoğraf çöpe taşındı: $filePath');
    }
  }
  
  Future<void> restoreFromTrash(String filePath) async {
    final db = await database;
    await db.update(
      'photos',
      {
        'is_deleted': 0,
        'deleted_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
  }
  
  Future<void> permanentlyDelete(String filePath) async {
    final db = await database;
    await db.delete(
      'photos',
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
  }
  
  Future<void> updatePhotoPath(String oldPath, String newPath) async {
    final db = await database;
    await db.update(
      'photos',
      {
        'file_path': newPath,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'file_path = ?',
      whereArgs: [oldPath],
    );
    debugPrint(' Path güncellendi: $oldPath -> $newPath');
  }
  
  Future<List<PhotoModel>> getTrashPhotos() async {
    final db = await database;
    final maps = await db.query(
      'photos',
      where: 'is_deleted = 1',
      orderBy: 'deleted_at DESC',
    );
    return maps.map((m) => PhotoModel.fromMap(m)).toList();
  }
  
  Future<bool> isPhotoDeleted(String filePath) async {
    final db = await database;
    
    final fileName = filePath.split('/').last;
    
    var result = await db.query(
      'photos',
      columns: ['is_deleted'],
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
    
    if (result.isEmpty) {
      result = await db.query(
        'photos',
        columns: ['is_deleted'],
        where: 'file_path LIKE ?',
        whereArgs: ['%$fileName'],
      );
    }
    
    if (result.isEmpty) return false;
    return result.first['is_deleted'] == 1;
  }
  
  Future<int> getOrCreateLabel(String name, {String? nameTr, String? category}) async {
    final db = await database;
    
    final existing = await db.query(
      'labels',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name.toLowerCase()],
    );
    
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    
    return await db.insert('labels', {
      'name': name.toLowerCase(),
      'name_tr': nameTr,
      'category': category,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> addLabelToPhoto(int photoId, int labelId, double confidence) async {
    final db = await database;
    await db.insert(
      'photo_labels',
      {
        'photo_id': photoId,
        'label_id': labelId,
        'confidence': confidence,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<PhotoLabelModel>> getPhotoLabels(int photoId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT pl.*, l.name as label_name
      FROM photo_labels pl
      JOIN labels l ON pl.label_id = l.id
      WHERE pl.photo_id = ?
      ORDER BY pl.confidence DESC
    ''', [photoId]);
    
    return maps.map((m) => PhotoLabelModel.fromMap(m)).toList();
  }
  
  Future<List<String>> getLabelsForPhoto(String filePath) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT l.name
      FROM labels l
      JOIN photo_labels pl ON l.id = pl.label_id
      JOIN photos p ON pl.photo_id = p.id
      WHERE p.file_path = ?
      ORDER BY pl.confidence DESC
    ''', [filePath]);
    
    return maps.map((m) => m['name'] as String).toList();
  }
  
  Future<bool> hasLabels(String filePath) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM photo_labels pl
      JOIN photos p ON pl.photo_id = p.id
      WHERE p.file_path = ?
    ''', [filePath]);
    
    return (result.first['count'] as int) > 0;
  }
  
  Future<void> saveLabels(String filePath, List<Map<String, dynamic>> labels) async {
    var photo = await getPhotoByPath(filePath);
    int photoId;
    
    if (photo == null) {
      final fileName = filePath.split('/').last;
      photoId = await insertPhoto(PhotoModel(
        filePath: filePath,
        fileName: fileName,
        dateTaken: DateTime.now(),
      ));
    } else {
      photoId = photo.id!;
    }
    
    for (final label in labels) {
      final labelName = label['label'] as String;
      final confidence = (label['confidence'] as num).toDouble();
      
      final labelId = await getOrCreateLabel(labelName);
      
      await addLabelToPhoto(photoId, labelId, confidence);
    }
  }
  
  Future<List<Map<String, dynamic>>> searchByLabel(String query) async {
    final db = await database;
    final normalizedQuery = query.toLowerCase().trim();
    
    if (normalizedQuery.isEmpty) return [];
    
    final maps = await db.rawQuery('''
      SELECT p.file_path as path, pl.confidence as confidence, l.name as label
      FROM photos p
      JOIN photo_labels pl ON p.id = pl.photo_id
      JOIN labels l ON pl.label_id = l.id
      WHERE p.is_deleted = 0 
        AND l.name LIKE ?
        AND pl.confidence >= 0.6
      ORDER BY pl.confidence DESC
    ''', ['%$normalizedQuery%']);
    
    final uniqueResults = <String, Map<String, dynamic>>{};
    for (final result in maps) {
      final path = result['path'] as String;
      if (!uniqueResults.containsKey(path)) {
        uniqueResults[path] = {
          'path': path,
          'confidence': result['confidence'],
          'label': result['label'],
        };
      }
    }
    
    final sortedResults = uniqueResults.values.toList()
      ..sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    
    debugPrint(' Arama "$normalizedQuery": ${sortedResults.length} sonuç');
    
    return sortedResults;
  }
  
  Future<int> createAlbum(String name, {String? description}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('albums', {
      'name': name,
      'description': description,
      'created_at': now,
      'updated_at': now,
    });
  }
  
  Future<List<AlbumModel>> getAllAlbums() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT a.*, 
             COUNT(ap.photo_id) as photo_count,
             (SELECT p.file_path FROM photos p WHERE p.id = a.cover_photo_id) as cover_photo_path
      FROM albums a
      LEFT JOIN album_photos ap ON a.id = ap.album_id
      GROUP BY a.id
      ORDER BY a.updated_at DESC
    ''');
    
    return maps.map((m) => AlbumModel.fromMap(m)).toList();
  }
  
  Future<void> addPhotoToAlbum(int albumId, String filePath) async {
    final db = await database;
    
    final photo = await getPhotoByPath(filePath);
    if (photo == null || photo.id == null) return;
    
    await db.insert(
      'album_photos',
      {
        'album_id': albumId,
        'photo_id': photo.id,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    
    await db.update(
      'albums',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [albumId],
    );
  }
  
  Future<List<PhotoModel>> getAlbumPhotos(int albumId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*
      FROM photos p
      JOIN album_photos ap ON p.id = ap.photo_id
      WHERE ap.album_id = ? AND p.is_deleted = 0
      ORDER BY ap.sort_order, ap.added_at DESC
    ''', [albumId]);
    
    return maps.map((m) => PhotoModel.fromMap(m)).toList();
  }
  
  Future<void> deleteAlbum(int albumId) async {
    final db = await database;
    await db.delete('albums', where: 'id = ?', whereArgs: [albumId]);
  }
  
  Future<void> removePhotoFromAlbum(int albumId, int photoId) async {
    final db = await database;
    await db.delete(
      'album_photos',
      where: 'album_id = ? AND photo_id = ?',
      whereArgs: [albumId, photoId],
    );
  }
  
  Future<void> setAlbumCover(int albumId, int photoId) async {
    final db = await database;
    await db.update(
      'albums',
      {
        'cover_photo_id': photoId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [albumId],
    );
  }
}
