import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class LabelingService {
  static final LabelingService instance = LabelingService._init();
  
  ImageLabeler? _labeler;
  bool _isInitialized = false;
  
  LabelingService._init();
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final options = ImageLabelerOptions(confidenceThreshold: 0.60);
      _labeler = ImageLabeler(options: options);
      _isInitialized = true;
    } catch (e) {
      debugPrint('LabelingService init error: $e');
      _isInitialized = true;
    }
  }
  
  Future<List<Map<String, dynamic>>> labelImage(String imagePath) async {
    if (_labeler == null) return [];
    
    try {
      final file = File(imagePath);
      if (!await file.exists()) return [];
      
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await _labeler!.processImage(inputImage);
      
      if (labels.isEmpty) return [];
      
      final results = labels.map((label) => {
        'label': label.label.toLowerCase().trim(),
        'confidence': label.confidence,
      }).toList();
      
      results.sort((a, b) => 
        (b['confidence'] as double).compareTo(a['confidence'] as double)
      );
      
      return results.take(10).toList();
      
    } catch (e) {
      debugPrint('Labeling error: $e');
      return [];
    }
  }
  
  Future<void> dispose() async {
    await _labeler?.close();
    _labeler = null;
    _isInitialized = false;
  }
}
