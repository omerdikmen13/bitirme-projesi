import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';
import '../photo_viewer/photo_viewer_screen.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<AlbumModel> _albums = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }
  
  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);
    
    try {
      _albums = await _db.getAllAlbums();
    } catch (e) {
      debugPrint('Load albums error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _createAlbum() async {
    final nameController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Yeni Albüm',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Albüm adı',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Oluştur', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      await _db.createAlbum(result);
      _showSnackBar(AppStrings.albumCreated);
      _loadAlbums();
    }
  }
  
  Future<void> _deleteAlbum(AlbumModel album) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Albümü Sil', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '"${album.name}" albümü silinecek. Fotoğraflar silinmeyecek.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && album.id != null) {
      await _db.deleteAlbum(album.id!);
      _showSnackBar('Albüm silindi');
      _loadAlbums();
    }
  }
  
  void _openAlbum(AlbumModel album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumDetailScreen(album: album),
      ),
    ).then((_) => _loadAlbums());
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createAlbum,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Albüm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: _albums.isEmpty
              ? EmptyState(
                  icon: Icons.photo_album,
                  title: AppStrings.noAlbums,
                  action: ElevatedButton.icon(
                    onPressed: _createAlbum,
                    icon: const Icon(Icons.add),
                    label: const Text('Albüm Oluştur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.paddingM,
                    mainAxisSpacing: AppDimensions.paddingM,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    final album = _albums[index];
                    return _buildAlbumCard(album);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildAlbumCard(AlbumModel album) {
    return GestureDetector(
      onTap: () => _openAlbum(album),
      onLongPress: () => _deleteAlbum(album),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusL),
                  ),
                ),
                child: album.coverPhotoPath != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.radiusL),
                        ),
                        child: Image.file(
                          File(album.coverPhotoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.folder,
                            size: AppDimensions.iconXL,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.folder,
                        size: AppDimensions.iconXL,
                        color: AppColors.primary,
                      ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${album.photoCount} fotoğraf',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumDetailScreen extends StatefulWidget {
  final AlbumModel album;
  
  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<PhotoModel> _photos = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }
  
  Future<void> _loadPhotos() async {
    if (widget.album.id == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      _photos = await _db.getAlbumPhotos(widget.album.id!);
    } catch (e) {
      debugPrint('Load album photos error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  
  void _openPhotoViewer(int index) async {
    final files = _photos.map((p) => File(p.filePath)).toList();
    
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photos: files,
          initialIndex: index,
        ),
      ),
    );
    
    if (result == true) {
      _loadPhotos();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          widget.album.name,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _photos.isEmpty
              ? const EmptyState(
                  icon: Icons.photo,
                  title: 'Bu albümde fotoğraf yok',
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingXS),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppDimensions.gridCrossAxisCount,
                    crossAxisSpacing: AppDimensions.gridSpacing,
                    mainAxisSpacing: AppDimensions.gridSpacing,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    return PhotoThumbnail(
                      file: File(photo.filePath),
                      onTap: () => _openPhotoViewer(index),
                    );
                  },
                ),
    );
  }
}
