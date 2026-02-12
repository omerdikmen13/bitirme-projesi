import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';
import '../photo_viewer/photo_viewer_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(String label)? onLabelSearch;
  
  const FavoritesScreen({super.key, this.onLabelSearch});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<PhotoModel> _favorites = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    try {
      _favorites = await _db.getFavoritePhotos();
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  
  void _openPhotoViewer(int index) async {
    final files = _favorites.map((p) => File(p.filePath)).toList();
    
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photos: files,
          initialIndex: index,
        ),
      ),
    );
    
    if (result is Map && result.containsKey('searchLabel')) {
      final label = result['searchLabel'] as String;
      if (widget.onLabelSearch != null) {
        widget.onLabelSearch!(label);
      }
    }
    else if (result == true) {
      _loadFavorites();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    
    if (_favorites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        title: AppStrings.noFavorites,
        subtitle: 'Fotoğrafları favorilere ekleyerek buradan erişebilirsiniz.',
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingXS),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppDimensions.gridCrossAxisCount,
          crossAxisSpacing: AppDimensions.gridSpacing,
          mainAxisSpacing: AppDimensions.gridSpacing,
        ),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final photo = _favorites[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              PhotoThumbnail(
                file: File(photo.filePath),
                onTap: () => _openPhotoViewer(index),
              ),
              Positioned(
                top: AppDimensions.paddingS,
                right: AppDimensions.paddingS,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.favorite,
                    size: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
