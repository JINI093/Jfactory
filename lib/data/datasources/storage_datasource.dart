import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageDataSource {
  Future<String> uploadFile(File file, String path);
  Future<String> uploadBytes(Uint8List bytes, String path);
  Future<void> deleteFile(String path);
  Future<String> getDownloadUrl(String path);
  Future<List<String>> uploadMultipleFiles(List<File> files, String basePath);
  Future<void> deleteMultipleFiles(List<String> paths);
}

class StorageDataSourceImpl implements StorageDataSource {
  final FirebaseStorage _storage;

  StorageDataSourceImpl({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('파일 업로드 실패: $e');
    }
  }

  @override
  Future<String> uploadBytes(Uint8List bytes, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(bytes);
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('바이트 데이터 업로드 실패: $e');
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw Exception('파일 삭제 실패: $e');
    }
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('다운로드 URL 가져오기 실패: $e');
    }
  }

  @override
  Future<List<String>> uploadMultipleFiles(List<File> files, String basePath) async {
    try {
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.${_getFileExtension(file.path)}';
        final path = '$basePath/$fileName';
        
        final downloadUrl = await uploadFile(file, path);
        downloadUrls.add(downloadUrl);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('다중 파일 업로드 실패: $e');
    }
  }

  @override
  Future<void> deleteMultipleFiles(List<String> paths) async {
    try {
      final List<Future<void>> deleteFutures = paths.map((path) => deleteFile(path)).toList();
      await Future.wait(deleteFutures);
    } catch (e) {
      throw Exception('다중 파일 삭제 실패: $e');
    }
  }

  String _getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  // 헬퍼 메서드들
  static String generateCompanyImagePath(String companyId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return 'companies/$companyId/images/${timestamp}_${fileName}.$extension';
  }

  static String generatePostImagePath(String postId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return 'posts/$postId/images/${timestamp}_${fileName}.$extension';
  }

  static String generateUserAvatarPath(String userId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return 'users/$userId/avatar/${timestamp}_avatar.$extension';
  }

  static String generateInquiryAttachmentPath(String inquiryId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return 'inquiries/$inquiryId/attachments/${timestamp}_${fileName}.$extension';
  }

  // URL에서 Storage path 추출하는 헬퍼 메서드
  static String? extractPathFromUrl(String downloadUrl) {
    try {
      final uri = Uri.parse(downloadUrl);
      final pathSegments = uri.pathSegments;
      
      final oIndex = pathSegments.indexOf('o');
      if (oIndex != -1 && oIndex + 1 < pathSegments.length) {
        return Uri.decodeComponent(pathSegments[oIndex + 1]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}