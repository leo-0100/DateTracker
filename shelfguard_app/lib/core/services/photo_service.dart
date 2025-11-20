import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for handling product photos
class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Take a photo with camera
  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      // Save to app directory
      final savedPath = await _savePhoto(photo.path);
      return savedPath;
    } catch (e) {
      print('[PhotoService] Error taking photo: $e');
      return null;
    }
  }

  /// Pick photo from gallery
  Future<String?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      // Save to app directory
      final savedPath = await _savePhoto(photo.path);
      return savedPath;
    } catch (e) {
      print('[PhotoService] Error picking photo: $e');
      return null;
    }
  }

  /// Pick multiple photos from gallery
  Future<List<String>> pickMultipleFromGallery({int maxImages = 5}) async {
    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photos.isEmpty) return [];

      // Limit number of photos
      final limitedPhotos = photos.take(maxImages);

      final List<String> savedPaths = [];
      for (final photo in limitedPhotos) {
        final savedPath = await _savePhoto(photo.path);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }

      return savedPaths;
    } catch (e) {
      print('[PhotoService] Error picking multiple photos: $e');
      return [];
    }
  }

  /// Save photo to app directory
  Future<String?> _savePhoto(String sourcePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/product_photos');

      // Create directory if it doesn't exist
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(sourcePath);
      final filename = 'product_$timestamp$extension';
      final destinationPath = '${photosDir.path}/$filename';

      // Copy file
      final sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);

      print('[PhotoService] Photo saved: $destinationPath');
      return destinationPath;
    } catch (e) {
      print('[PhotoService] Error saving photo: $e');
      return null;
    }
  }

  /// Delete photo
  Future<bool> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        print('[PhotoService] Photo deleted: $photoPath');
        return true;
      }
      return false;
    } catch (e) {
      print('[PhotoService] Error deleting photo: $e');
      return false;
    }
  }

  /// Delete multiple photos
  Future<void> deletePhotos(List<String> photoPaths) async {
    for (final photoPath in photoPaths) {
      await deletePhoto(photoPath);
    }
  }

  /// Check if photo exists
  Future<bool> photoExists(String photoPath) async {
    try {
      final file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get photo file
  File? getPhotoFile(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;
    return File(photoPath);
  }

  /// Clear all photos (for cleanup)
  Future<void> clearAllPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/product_photos');

      if (await photosDir.exists()) {
        await photosDir.delete(recursive: true);
        print('[PhotoService] All photos cleared');
      }
    } catch (e) {
      print('[PhotoService] Error clearing photos: $e');
    }
  }

  /// Get total storage used by photos (in bytes)
  Future<int> getStorageUsed() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/product_photos');

      if (!await photosDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in photosDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('[PhotoService] Error calculating storage: $e');
      return 0;
    }
  }

  /// Format storage size for display
  String formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
