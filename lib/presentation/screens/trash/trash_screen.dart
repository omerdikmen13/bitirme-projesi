import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/constants/constants.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<PhotoModel> _trashItems = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTrash();
  }
  
  Future<void> _loadTrash() async {
    setState(() => _isLoading = true);
    
    try {
      _trashItems = await _db.getTrashPhotos();
    } catch (e) {
      debugPrint('Load trash error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  
  void _showTrashOptions(PhotoModel photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                image: DecorationImage(
                  image: FileImage(File(photo.filePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.restore, color: AppColors.success),
              title: const Text(
                'Geri Yükle',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _restorePhoto(photo);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text(
                'Kalıcı Olarak Sil',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _permanentlyDeletePhoto(photo);
              },
            ),
            
            const SizedBox(height: AppDimensions.paddingL),
          ],
        ),
      ),
    );
  }
  
  Future<void> _restorePhoto(PhotoModel photo) async {
    await _db.restoreFromTrash(photo.filePath);
    _showSnackBar(AppStrings.restored);
    _loadTrash();
  }
  
  Future<void> _permanentlyDeletePhoto(PhotoModel photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Kalıcı Olarak Sil',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Bu fotoğraf kalıcı olarak silinecek ve geri getirilemeyecek.',
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
    
    if (confirmed != true) return;
    
    _showSnackBar('Asset aranıyor...', isError: false);
    
    bool isDeleted = false;
    String debugInfo = '';

    try {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      
      if (albums.isEmpty) {
        debugInfo = 'Albüm yok!';
      } else {
        String? assetIdToDelete;
        
        AssetPathEntity? verisetAlbum;
        for (final album in albums) {
          if (album.name.toLowerCase().contains('veriseti')) {
            verisetAlbum = album;
            break;
          }
        }
        
        final targetAlbum = verisetAlbum ?? albums.firstWhere((a) => a.isAll, orElse: () => albums.first);
        final count = await targetAlbum.assetCountAsync;
        
        final targetFileName = photo.filePath.split('/').last;
        
        final assets = await targetAlbum.getAssetListPaged(page: 0, size: count > 1000 ? 1000 : count);
        
        for (final asset in assets) {
          final file = await asset.file;
          if (file == null) continue;
          
          final assetFileName = file.path.split('/').last;
          
          if (assetFileName == targetFileName) {
            assetIdToDelete = asset.id;
            break;
          }
        }

        if (assetIdToDelete != null) {
          final result = await PhotoManager.editor.deleteWithIds([assetIdToDelete]);
          
          if (result.isNotEmpty) {
            isDeleted = true;
            debugInfo = 'Silindi ✓';
          } else {
            debugInfo = 'İptal edildi';
          }
        } else {
          debugInfo = 'Asset bulunamadı';
        }
      }
    } catch (e) {
      debugInfo = 'Hata: $e';
    }
    
    if (!isDeleted) {
      try {
        final file = File(photo.filePath);
        if (await file.exists()) {
          await file.delete();
          isDeleted = true;
          debugInfo += ' | Manuel silindi';
        } else {
          isDeleted = true;
          debugInfo += ' | Dosya yoktu';
        }
      } catch (e) {
        debugInfo += ' | Manuel hata: $e';
      }
    }
    
    await _db.permanentlyDelete(photo.filePath);
    
    if (mounted) {
      setState(() {
        _trashItems.removeWhere((item) => item.filePath == photo.filePath);
      });
      
      _showSnackBar(debugInfo, isError: !isDeleted);
    }
  }
  
  Future<void> _emptyTrash() async {
    if (_trashItems.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Çöp Kutusunu Boşalt',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${_trashItems.length} fotoğraf kalıcı olarak silinecek.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Boşalt', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    
    final itemsToDelete = List<PhotoModel>.from(_trashItems);
    final assetIdsToDelete = <String>[];
    final fileNamesToFind = itemsToDelete.map((e) => e.filePath.split('/').last).toSet();
    
    try {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      
      AssetPathEntity? verisetAlbum;
      for (final album in albums) {
        if (album.name.toLowerCase().contains('veriseti')) {
          verisetAlbum = album;
          break;
        }
      }
      
      final targetAlbum = verisetAlbum ?? albums.firstWhere((a) => a.isAll, orElse: () => albums.first);
      final count = await targetAlbum.assetCountAsync;
      
      final assets = await targetAlbum.getAssetListPaged(page: 0, size: count > 1000 ? 1000 : count);
      
      for (final asset in assets) {
        final file = await asset.file;
        if (file == null) continue;
        
        final assetFileName = file.path.split('/').last;
        if (fileNamesToFind.contains(assetFileName)) {
          assetIdsToDelete.add(asset.id);
        }
      }
    } catch (e) {
    }
    
    if (assetIdsToDelete.isNotEmpty) {
      try {
        await PhotoManager.editor.deleteWithIds(assetIdsToDelete);
      } catch (e) {
      }
    }
    
    for (final item in itemsToDelete) {
      try {
        final file = File(item.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
      }
      
      await _db.permanentlyDelete(item.filePath);
    }
    
    if (mounted) {
      setState(() {
        _trashItems.clear();
        _isLoading = false;
      });
      _showSnackBar('Çöp kutusu boşaltıldı ✓');
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    
    if (_trashItems.isEmpty) {
      return const EmptyState(
        icon: Icons.delete_outline,
        title: AppStrings.emptyTrash,
        subtitle: 'Sildiğiniz fotoğraflar burada görünecek.',
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _emptyTrash,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Çöp Kutusunu Boşalt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.15),
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTrash,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingXS),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppDimensions.gridCrossAxisCount,
                crossAxisSpacing: AppDimensions.gridSpacing,
                mainAxisSpacing: AppDimensions.gridSpacing,
              ),
              itemCount: _trashItems.length,
              itemBuilder: (context, index) {
                final photo = _trashItems[index];
                return GestureDetector(
                  onTap: () => _showTrashOptions(photo),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo.filePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: AppDimensions.iconM,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
