import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/database/database_helper.dart';
import '../../widgets/widgets.dart';
import '../photo_viewer/photo_viewer_screen.dart';

class PersonsScreen extends StatefulWidget {
  final Function(String label)? onLabelSearch;
  
  const PersonsScreen({super.key, this.onLabelSearch});

  @override
  State<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _faces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaces();
  }

  Future<void> _loadFaces() async {
    setState(() => _isLoading = true);
    
    try {
      _faces = await _db.getAllFacesGroupedByPhoto();
    } catch (e) {
      debugPrint('Yüzler yükleme hatası: $e');
      _faces = [];
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openPhotoViewer(int index) async {
    final photos = _faces.map((f) => File(f['photo_path'] as String)).toList();
    
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photos: photos,
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
      _loadFaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_faces.isEmpty) {
      return const EmptyState(
        icon: Icons.face,
        title: 'Henüz Yüz Yok',
        subtitle: 'Fotoğraflarınız tarandığında\nyüzler burada görünecek.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFaces,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                const Icon(Icons.face, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_faces.length} kişi',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppDimensions.gridSpacing,
                mainAxisSpacing: AppDimensions.gridSpacing,
              ),
              itemCount: _faces.length,
              itemBuilder: (context, index) {
                final face = _faces[index];
                final photoPath = face['photo_path'] as String;

                return GestureDetector(
                  onTap: () => _openPhotoViewer(index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    child: Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
