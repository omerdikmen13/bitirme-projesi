import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../data/database/database_helper.dart';

class FaceDetectionService {
  static final FaceDetectionService instance = FaceDetectionService._init();
  FaceDetectionService._init();

  final DatabaseHelper _db = DatabaseHelper.instance;
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: false,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.1,
    ),
  );

  Future<int> detectAndSaveFaces(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return 0;

      final inputImage = InputImage.fromFilePath(filePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) return 0;

      debugPrint(' ${faces.length} yüz bulundu: ${filePath.split('/').last}');

      int savedCount = 0;
      for (final face in faces) {
        final boundingBox = {
          'left': face.boundingBox.left,
          'top': face.boundingBox.top,
          'width': face.boundingBox.width,
          'height': face.boundingBox.height,
        };

        final faceData = {
          'smilingProbability': face.smilingProbability,
          'leftEyeOpenProbability': face.leftEyeOpenProbability,
          'rightEyeOpenProbability': face.rightEyeOpenProbability,
          'headEulerAngleY': face.headEulerAngleY,
          'headEulerAngleZ': face.headEulerAngleZ,
        };

        await _db.insertFace(
          filePath: filePath,
          boundingBox: boundingBox,
          faceData: faceData,
        );
        
        savedCount++;
      }

      return savedCount;
    } catch (e) {
      debugPrint(' Yüz algılama hatası: $e');
      return 0;
    }
  }

  Future<void> scanAllPhotos({
    required List<String> photoPaths,
    Function(int current, int total)? onProgress,
  }) async {
    final total = photoPaths.length;
    int current = 0;
    int totalFaces = 0;

    for (final path in photoPaths) {
      final alreadyScanned = await _db.isPhotoFaceScanned(path);
      if (!alreadyScanned) {
        final faceCount = await detectAndSaveFaces(path);
        totalFaces += faceCount;
      }

      current++;
      onProgress?.call(current, total);
    }

    debugPrint(' Yüz tarama tamamlandı: $totalFaces yüz bulundu');
  }

  void dispose() {
    _faceDetector.close();
  }
}
