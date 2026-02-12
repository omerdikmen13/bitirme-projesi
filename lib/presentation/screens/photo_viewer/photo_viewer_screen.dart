import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/constants/constants.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List<File> photos;
  final List<AssetEntity>? assets;
  final int initialIndex;
  
  const PhotoViewerScreen({
    super.key,
    required this.photos,
    this.assets,
    this.initialIndex = 0,
  });
  
  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isFavorite = false;
  bool _showControls = true;
  bool _didDelete = false;
  bool _isZoomed = false;
  List<String> _labels = [];
  late List<File> _photos;
  late List<AssetEntity>? _assets;
  
  final DatabaseHelper _db = DatabaseHelper.instance;
  final TransformationController _transformController = TransformationController();
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _photos = List.from(widget.photos);
    _assets = widget.assets != null ? List.from(widget.assets!) : null;
    _checkFavorite();
    _loadLabels();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _transformController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
  
  Future<void> _checkFavorite() async {
    if (_photos.isEmpty) return;
    final isFav = await _db.isFavorite(_photos[_currentIndex].path);
    if (mounted) setState(() => _isFavorite = isFav);
  }
  
  Future<void> _loadLabels() async {
    if (_photos.isEmpty) return;
    final path = _photos[_currentIndex].path;
    final labels = await _db.getLabelsForPhoto(path);
    if (mounted) {
      setState(() => _labels = labels);
    }
  }
  
  Future<void> _toggleFavorite() async {
    final path = _photos[_currentIndex].path;
    
    if (_isFavorite) {
      await _db.removeFromFavorites(path);
      _showSnackBar(AppStrings.removedFromFavorites);
    } else {
      await _db.addToFavorites(path);
      _showSnackBar(AppStrings.addedToFavorites);
    }
    
    setState(() => _isFavorite = !_isFavorite);
  }
  
  Future<void> _deletePhoto() async {
    final file = _photos[_currentIndex];
    final path = file.path;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Fotoğrafı Sil', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Bu fotoğraf çöp kutusuna taşınacak.',
          style: TextStyle(color: AppColors.textSecondary),
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
    
    if (confirmed == true) {
      await _db.moveToTrash(path);
      
      _showSnackBar('Çöp kutusuna taşındı');
      _didDelete = true;
      
      if (_photos.length <= 1) {
        Navigator.pop(context, _didDelete); 
        return;
      }
      
      setState(() {
        _photos.removeAt(_currentIndex);
        if (_assets != null && _currentIndex < _assets!.length) {
          _assets!.removeAt(_currentIndex);
        }
        if (_currentIndex >= _photos.length) {
          _currentIndex = _photos.length - 1;
        }
        _checkFavorite();
        _loadLabels();
        _pageController.jumpToPage(_currentIndex);
      });
    }
  }

  Future<void> _addToAlbum() async {
    final albums = await _db.getAllAlbums();
    
    if (albums.isEmpty) {
      _showSnackBar(AppStrings.noAlbums);
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Text(
                'Albüme Ekle',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return ListTile(
                    leading: const Icon(Icons.photo_album, color: AppColors.primary),
                    title: Text(album.name, style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () async {
                      Navigator.pop(context);
                      await _addPhotoToAlbumOp(album.id!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhotoToAlbumOp(int albumId) async {
    try {
      final path = _photos[_currentIndex].path;
      
      await _db.addPhotoToAlbum(albumId, path);
      _showSnackBar('Albüme eklendi');
      
    } catch (e) {
      debugPrint('Album add error: $e');
      _showSnackBar('Hata: Albüme eklenemedi');
    }
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }
  
  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }
  
  void _resetZoom() {
    _transformController.value = Matrix4.identity();
    _isZoomed = false;
  }
  
  void _toggleZoom() {
    setState(() {
      if (_isZoomed) {
        _transformController.value = Matrix4.identity();
        _isZoomed = false;
      } else {
        _transformController.value = Matrix4.identity()..scale(2.5);
        _isZoomed = true;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Fotoğraf bulunamadı', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _didDelete);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onTap: _toggleControls,
              onDoubleTap: _toggleZoom,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _photos.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _checkFavorite();
                  _loadLabels();
                  _resetZoom();
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    transformationController: index == _currentIndex 
                        ? _transformController 
                        : null,
                    minScale: 1.0,
                    maxScale: 5.0,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: Center(
                      child: Image.file(
                        _photos[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context, _didDelete),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Text(
                            '${_currentIndex + 1} / ${_photos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                           const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            if (_showControls && _labels.isNotEmpty)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Etiketler (tıkla ve ara):',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _labels.map((label) => GestureDetector(
                          onTap: () {
                            Navigator.pop(context, {'searchLabel': label});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                            label: 'Favori',
                            color: _isFavorite ? AppColors.favorite : Colors.white,
                            onTap: _toggleFavorite,
                          ),
                          
                          _ActionButton(
                            icon: Icons.add_to_photos_outlined,
                            label: 'Albüme Ekle',
                            color: Colors.white,
                            onTap: _addToAlbum,
                          ),
                          
                          _ActionButton(
                            icon: Icons.delete_outline,
                            label: 'Sil',
                            color: Colors.white,
                            onTap: _deletePhoto,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
