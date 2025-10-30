import '../entities/purchase_entity.dart';

abstract class PurchaseRepository {
  Future<void> createPurchase(PurchaseEntity purchase);
  Future<void> updatePurchase(PurchaseEntity purchase);
  Future<PurchaseEntity?> getPurchaseById(String id);
  Future<List<PurchaseEntity>> getUserPurchases(String userId);
  Future<List<PurchaseEntity>> getCompanyPurchases(String companyId);
  Stream<List<PurchaseEntity>> streamUserPurchases(String userId);
}