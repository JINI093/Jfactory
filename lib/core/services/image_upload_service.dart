import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadImage(File imageFile, {String? customPath}) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = imageFile.path.split('.').last;
      final String path = customPath ?? 'uploads/images/$fileName.$extension';
      
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: ${e.toString()}');
    }
  }

  static Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    String? customPath,
  }) async {
    try {
      final List<Future<String>> uploadTasks = imageFiles.map((file) {
        return uploadImage(file, customPath: customPath);
      }).toList();
      
      return await Future.wait(uploadTasks);
    } catch (e) {
      throw Exception('다중 이미지 업로드 실패: ${e.toString()}');
    }
  }

  static Future<String> uploadCompanyLogo(File logoFile, String companyId) async {
    return await uploadImage(
      logoFile,
      customPath: 'companies/$companyId/logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  static Future<List<String>> uploadCompanyPhotos(
    List<File> photoFiles,
    String companyId,
  ) async {
    final List<Future<String>> uploadTasks = photoFiles.map((file) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      return uploadImage(
        file,
        customPath: 'companies/$companyId/photos/photo_$fileName.jpg',
      );
    }).toList();
    
    return await Future.wait(uploadTasks);
  }

  static Future<List<String>> uploadPostImages(
    List<File> imageFiles,
    String postId,
  ) async {
    final List<Future<String>> uploadTasks = imageFiles.map((file) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      return uploadImage(
        file,
        customPath: 'posts/$postId/images/image_$fileName.jpg',
      );
    }).toList();
    
    return await Future.wait(uploadTasks);
  }

  static Future<String> uploadInquiryAttachment(
    File attachmentFile,
    String inquiryId,
  ) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final extension = attachmentFile.path.split('.').last;
    return await uploadImage(
      attachmentFile,
      customPath: 'inquiries/$inquiryId/attachments/attachment_$fileName.$extension',
    );
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('이미지 삭제 실패: ${e.toString()}');
    }
  }

  static Future<void> deleteMultipleImages(List<String> imageUrls) async {
    try {
      final List<Future<void>> deleteTasks = imageUrls.map((url) {
        return deleteImage(url);
      }).toList();
      
      await Future.wait(deleteTasks);
    } catch (e) {
      throw Exception('다중 이미지 삭제 실패: ${e.toString()}');
    }
  }
}