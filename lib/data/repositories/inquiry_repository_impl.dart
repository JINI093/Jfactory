import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inquiry_entity.dart';
import '../../domain/repositories/inquiry_repository.dart';
import '../models/inquiry_model.dart';

class InquiryRepositoryImpl implements InquiryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'inquiries';

  @override
  Future<String> createInquiry(InquiryEntity inquiry) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final inquiryWithId = InquiryEntity(
        id: docRef.id,
        userId: inquiry.userId,
        companyId: inquiry.companyId,
        title: inquiry.title,
        content: inquiry.content,
        type: inquiry.type,
        status: InquiryStatus.pending,
        createdAt: DateTime.now(),
        attachments: inquiry.attachments,
      );
      
      final model = InquiryModel.fromEntity(inquiryWithId);
      await docRef.set(model.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create inquiry: $e');
    }
  }

  @override
  Future<InquiryEntity?> getInquiry(String inquiryId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(inquiryId).get();
      if (doc.exists && doc.data() != null) {
        return InquiryModel.fromJson(doc.data()!).toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get inquiry: $e');
    }
  }

  @override
  Future<List<InquiryEntity>> getInquiriesByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InquiryModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get user inquiries: $e');
    }
  }

  @override
  Future<List<InquiryEntity>> getAllInquiries() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InquiryModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get all inquiries: $e');
    }
  }

  @override
  Future<void> updateInquiry(InquiryEntity inquiry) async {
    try {
      final model = InquiryModel.fromEntity(inquiry);
      await _firestore
          .collection(_collection)
          .doc(inquiry.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update inquiry: $e');
    }
  }

  @override
  Future<void> deleteInquiry(String inquiryId) async {
    try {
      await _firestore.collection(_collection).doc(inquiryId).delete();
    } catch (e) {
      throw Exception('Failed to delete inquiry: $e');
    }
  }

  @override
  Stream<List<InquiryEntity>> streamUserInquiries(String userId) {
    try {
      print('🔍 StreamUserInquiries called for userId: $userId');
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('📊 Inquiry snapshot received: ${snapshot.docs.length} documents');
            return snapshot.docs
                .map((doc) {
                  try {
                    print('📄 Processing inquiry doc: ${doc.id}');
                    return InquiryModel.fromJson(doc.data()).toEntity();
                  } catch (e) {
                    print('❌ Error processing doc ${doc.id}: $e');
                    print('📄 Doc data: ${doc.data()}');
                    rethrow;
                  }
                })
                .toList();
          });
    } catch (e) {
      print('❌ StreamUserInquiries error: $e');
      rethrow;
    }
  }
}