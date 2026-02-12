import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/models.dart';
import '../../../services/labeling_service.dart';
import '../../../services/face_detection_service.dart';
import '../../widgets/widgets.dart';
import '../photo_viewer/photo_viewer_screen.dart';
import '../albums/albums_screen.dart';
import '../favorites/favorites_screen.dart';
import '../trash/trash_screen.dart';
import '../persons/persons_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final LabelingService _labeler = LabelingService.instance;
  final FaceDetectionService _faceDetector = FaceDetectionService.instance;
  
  List<AssetEntity> _photos = [];
  Map<String, List<AssetEntity>> _groupedPhotos = {};
  
  List<Map<String, dynamic>> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  bool _isLoading = true;
  bool _isSearching = false;
  
  int _currentTab = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      await _labeler.initialize();
      await _loadPhotos();
      _startBackgroundLabeling();
      _startBackgroundFaceScanning();
    } catch (e) {
      debugPrint('Initialize error: $e');
      if (mounted) {
        _showSnackBar('Başlatma hatası: $e', isError: true);
      }
    }
  }
  
  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    
    try {
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess) {
        if (mounted) {
          _showSnackBar('Galeri izni verilmedi', isError: true);
        }
        setState(() => _isLoading = false);
        return;
      }

      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      
      AssetPathEntity? targetAlbum;
      for (final album in albums) {
        if (album.name.toLowerCase().contains('veriseti')) {
          targetAlbum = album;
          break;
        }
      }
      if (targetAlbum == null) {
        debugPrint('⚠️ Veriseti klasörü bulunamadı. Lütfen DCIM/Veriseti klasörünü oluşturun.');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      
      if (targetAlbum != null) {
        final allPhotos = await targetAlbum.getAssetListPaged(page: 0, size: 500);
        
        final filteredPhotos = <AssetEntity>[];
        for (final photo in allPhotos) {
          final file = await photo.file;
          if (file != null) {
            final isDeleted = await _db.isPhotoDeleted(file.path);
            if (!isDeleted) {
              filteredPhotos.add(photo);
            }
          }
        }
        
        _photos = filteredPhotos;
        _groupedPhotos = _groupByDate(_photos);
      }
    } catch (e) {
      debugPrint('Load photos error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  
  Map<String, List<AssetEntity>> _groupByDate(List<AssetEntity> photos) {
    final Map<String, List<AssetEntity>> grouped = {};
    
    final sortedPhotos = List<AssetEntity>.from(photos)
      ..sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    
    for (final photo in sortedPhotos) {
      final date = photo.createDateTime;
      final key = '${date.day} ${AppStrings.months[date.month - 1]} ${date.year}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(photo);
    }
    
    final sortedMap = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) {
        final dateA = a.value.first.createDateTime;
        final dateB = b.value.first.createDateTime;
        return dateB.compareTo(dateA);
      }),
    );
    
    return sortedMap;
  }
  
  void _startBackgroundLabeling() async {
    if (_photos.isEmpty) return;
    
    int labeledCount = 0;
    
    for (int i = 0; i < _photos.length; i++) {
      if (!mounted) return;
      
      final file = await _photos[i].file;
      if (file == null) continue;

      final hasLabels = await _db.hasLabels(file.path);
      
      if (!hasLabels) {
        try {
          final labels = await _labeler.labelImage(file.path);
          if (labels.isNotEmpty) {
            await _db.saveLabels(file.path, labels);
            labeledCount++;
          }
        } catch (e) {
          debugPrint('Labeling error: $e');
        }
      }
      
      if (i % 20 == 0) {
        await Future.delayed(const Duration(milliseconds: 5));
      }
    }
    
    if (labeledCount > 0) {
      debugPrint('✅ $labeledCount yeni fotoğraf etiketlendi');
    }
  }
  
  void _startBackgroundFaceScanning() async {
    if (_photos.isEmpty) return;
    
    int facesFound = 0;
    int photosScanned = 0;
    
    for (int i = 0; i < _photos.length; i++) {
      if (!mounted) return;
      
      final file = await _photos[i].file;
      if (file == null) continue;
      
      final alreadyScanned = await _db.isPhotoFaceScanned(file.path);
      
      if (!alreadyScanned) {
        try {
          final faceCount = await _faceDetector.detectAndSaveFaces(file.path);
          if (faceCount > 0) {
            facesFound += faceCount;
            photosScanned++;
          }
        } catch (e) {
          debugPrint('Face detection error: $e');
        }
      }
      
      if (i % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
    
    if (facesFound > 0) {
      debugPrint('👤 $photosScanned fotoğrafta $facesFound yüz bulundu');
    }
  }

  Future<void> _openCamera() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (photo != null) {
        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        final verisetDir = Directory('/storage/emulated/0/DCIM/Veriseti');
        if (!await verisetDir.exists()) {
          await verisetDir.create(recursive: true);
        }
        
        final savedPath = '${verisetDir.path}/$fileName';
        final savedFile = await File(photo.path).copy(savedPath);
        
        await PhotoManager.editor.saveImageWithPath(
          savedFile.path,
          title: fileName,
        );
        
        await _db.insertPhoto(PhotoModel(
          filePath: savedFile.path,
          fileName: fileName,
          dateTaken: DateTime.now(),
        ));
        
        final labels = await _labeler.labelImage(savedFile.path);
        if (labels.isNotEmpty) {
          await _db.saveLabels(savedFile.path, labels);
        }
        
        await _faceDetector.detectAndSaveFaces(savedFile.path);
        
        await _loadPhotos();
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      _showSnackBar('Kamera hatası: $e', isError: true);
    }
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchQuery = '';
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    
    final results = await _db.searchByLabel(query);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _searchQuery = '';
    });
  }
  
  Future<void> _refreshGallery() async {
    await _loadPhotos();
  }
  
  
  Future<void> _openPhotoViewer(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;
    
    final files = <File>[];
    final assets = <AssetEntity>[];
    for (final photo in _photos) {
      final f = await photo.file;
      if (f != null) {
        files.add(f);
        assets.add(photo);
      }
    }
    
    final index = _photos.indexOf(asset);
    
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photos: files,
          assets: assets,
          initialIndex: index >= 0 ? index : 0,
        ),
      ),
    );
    
    if (result is Map && result.containsKey('searchLabel')) {
      final label = result['searchLabel'] as String;
      _searchController.text = label;
      _performSearch(label);
    }
    else if (result == true) {
      await _loadPhotos();
    }
  }
  
  void _openSearchResult(String path) async {
    final allFiles = <File>[];
    for (final photo in _photos) {
      final f = await photo.file;
      if (f != null) allFiles.add(f);
    }
    
    final index = allFiles.indexWhere((f) => f.path == path);
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photos: [File(path)],
          initialIndex: 0,
        ),
      ),
    );
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              onSearch: _performSearch,
              onClear: _clearSearch,
            ),
            
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildTabContent(),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
      ),
      
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              onPressed: _openCamera,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null,
    );
  }
  
  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildPhotosTab();
      case 1:
        return const AlbumsScreen();
      case 2:
        return FavoritesScreen(
          onLabelSearch: (label) {
            setState(() => _currentTab = 0);
            _searchController.text = label;
            _performSearch(label);
          },
        );
      case 3:
        return PersonsScreen(
          onLabelSearch: (label) {
            setState(() => _currentTab = 0);
            _searchController.text = label;
            _performSearch(label);
          },
        );
      case 4:
        return const TrashScreen();
      default:
        return _buildPhotosTab();
    }
  }
  
  Widget _buildPhotosTab() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Fotoğraflar yükleniyor...');
    }
    
    if (_photos.isEmpty) {
      return EmptyState(
        icon: Icons.photo_library,
        title: AppStrings.noPhotos,
        action: ElevatedButton.icon(
          onPressed: _loadPhotos,
          icon: const Icon(Icons.refresh),
          label: const Text('Yenile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshGallery,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingXS),
        itemCount: _groupedPhotos.length,
        itemBuilder: (context, index) {
          final date = _groupedPhotos.keys.elementAt(index);
          final photos = _groupedPhotos[date]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateHeader(date: date, count: photos.length),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AppDimensions.gridCrossAxisCount,
                  crossAxisSpacing: AppDimensions.gridSpacing,
                  mainAxisSpacing: AppDimensions.gridSpacing,
                ),
                itemCount: photos.length,
                itemBuilder: (context, photoIndex) {
                  return _buildPhotoThumbnail(photos[photoIndex]);
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildPhotoThumbnail(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        const ThumbnailSize(AppDimensions.thumbnailSize, AppDimensions.thumbnailSize),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(color: AppColors.surface);
        }
        
        return GestureDetector(
          onTap: () => _openPhotoViewer(asset),
          child: Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
  
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const LoadingIndicator(message: 'Aranıyor...');
    }
    
    if (_searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: '"$_searchQuery" için sonuç bulunamadı',
        subtitle: null,
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppDimensions.gridCrossAxisCount,
        crossAxisSpacing: AppDimensions.gridSpacing,
        mainAxisSpacing: AppDimensions.gridSpacing,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final path = result['path'] as String;
        final confidence = ((result['confidence'] as double?) ?? 0) * 100;
        
        return PhotoThumbnail(
          file: File(path),
          onTap: () => _openSearchResult(path),
          scorePercent: confidence.toInt(),
        );
      },
    );
  }
}
