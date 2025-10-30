import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'purchases';

  PurchaseRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPurchase(PurchaseEntity purchase) async {
    try {
      final model = PurchaseModel.fromEntity(purchase);
      await _firestore.collection(_collection).doc(purchase.id).set(
        model.toFirestore(),
      );
    } catch (e) {
      throw Exception('Failed to create purchase: $e');
    }
  }

  @override
  Future<void> updatePurchase(PurchaseEntity purchase) async {
    try {
      final model = PurchaseModel.fromEntity(purchase);
      await _firestore.collection(_collection).doc(purchase.id).update(
        model.toFirestore(),
      );
    } catch (e) {
      throw Exception('Failed to update purchase: $e');
    }
  }

  @override
  Future<PurchaseEntity?> getPurchaseById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      
      final model = PurchaseModel.fromFirestore(doc.data()!, doc.id);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get purchase: $e');
    }
  }

  @override
  Future<List<PurchaseEntity>> getUserPurchases(String userId) async {
    try {
      // 인덱스 오류를 방지하기 위해 orderBy 없이 쿼리하고 클라이언트에서 정렬
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final purchases = snapshot.docs.map((doc) {
        try {
          final model = PurchaseModel.fromFirestore(doc.data(), doc.id);
          return model.toEntity();
        } catch (e) {
          debugPrint('Error parsing purchase document ${doc.id}: $e');
          return null;
        }
      }).where((entity) => entity != null).cast<PurchaseEntity>().toList();
      
      // 클라이언트 사이드에서 정렬
      purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      return purchases;
    } catch (e) {
      debugPrint('Error getting user purchases: $e');
      throw Exception('Failed to get user purchases: $e');
    }
  }

  @override
  Future<List<PurchaseEntity>> getCompanyPurchases(String companyId) async {
    try {
      // 인덱스 오류를 방지하기 위해 orderBy 없이 쿼리하고 클라이언트에서 정렬
      final snapshot = await _firestore
          .collection(_collection)
          .where('companyId', isEqualTo: companyId)
          .get();

      final purchases = snapshot.docs.map((doc) {
        try {
          final model = PurchaseModel.fromFirestore(doc.data(), doc.id);
          return model.toEntity();
        } catch (e) {
          debugPrint('Error parsing purchase document ${doc.id}: $e');
          return null;
        }
      }).where((entity) => entity != null).cast<PurchaseEntity>().toList();
      
      // 클라이언트 사이드에서 정렬
      purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      return purchases;
    } catch (e) {
      debugPrint('Error getting company purchases: $e');
      throw Exception('Failed to get company purchases: $e');
    }
  }

  @override
  Stream<List<PurchaseEntity>> streamUserPurchases(String userId) {
    // 인덱스 오류를 방지하기 위해 orderBy 없이 쿼리하고 클라이언트에서 정렬
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      try {
        final purchases = snapshot.docs.map((doc) {
          final data = doc.data();
          // Null 체크 및 기본값 처리
          if (data.isEmpty) {
            debugPrint('Empty document data for purchase ${doc.id}');
            return null;
          }
          
          try {
            final model = PurchaseModel.fromFirestore(data, doc.id);
            return model.toEntity();
          } catch (e) {
            debugPrint('Error parsing purchase document ${doc.id}: $e');
            return null;
          }
        }).where((entity) => entity != null).cast<PurchaseEntity>().toList();
        
        // 클라이언트 사이드에서 정렬
        purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        return purchases;
      } catch (e) {
        debugPrint('Error processing purchase documents: $e');
        // 빈 리스트 반환하여 앱이 계속 동작하도록 함
        return <PurchaseEntity>[];
      }
    }).handleError((error) {
      debugPrint('Error streaming user purchases: $error');
      
      if (error.toString().contains('PERMISSION_DENIED')) {
        throw Exception('구매 내역에 접근할 권한이 없습니다. 로그인을 다시 시도해주세요.');
      } else {
        throw Exception('구매 내역을 불러오는 중 오류가 발생했습니다: ${error.toString()}');
      }
    });
  }
}