import '../entities/inquiry_entity.dart';

abstract class InquiryRepository {
  Future<void> createInquiry(InquiryEntity inquiry);
  Future<InquiryEntity?> getInquiry(String inquiryId);
  Future<List<InquiryEntity>> getInquiriesByUser(String userId);
  Future<List<InquiryEntity>> getAllInquiries();
  Future<void> updateInquiry(InquiryEntity inquiry);
  Future<void> deleteInquiry(String inquiryId);
}