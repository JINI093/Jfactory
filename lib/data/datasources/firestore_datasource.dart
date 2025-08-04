import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/company_model.dart';
import '../models/payment_model.dart';
import '../models/inquiry_model.dart';
import '../models/post_model.dart';

abstract class FirestoreDataSource {
  // User operations
  Future<void> createUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String uid);

  // Company operations
  Future<void> createCompany(CompanyModel company);
  Future<CompanyModel?> getCompany(String companyId);
  Future<List<CompanyModel>> getCompanies({
    String? category,
    String? subcategory,
    String? region,
    int? limit,
    String? orderBy,
    bool descending = false,
  });
  Future<void> updateCompany(CompanyModel company);
  Future<void> deleteCompany(String companyId);

  // Payment operations
  Future<void> createPayment(PaymentModel payment);
  Future<PaymentModel?> getPayment(String paymentId);
  Future<List<PaymentModel>> getPaymentsByUser(String userId);
  Future<List<PaymentModel>> getPaymentsByCompany(String companyId);
  Future<void> updatePayment(PaymentModel payment);

  // Inquiry operations
  Future<void> createInquiry(InquiryModel inquiry);
  Future<InquiryModel?> getInquiry(String inquiryId);
  Future<List<InquiryModel>> getInquiriesByUser(String userId);
  Future<List<InquiryModel>> getAllInquiries();
  Future<void> updateInquiry(InquiryModel inquiry);

  // Post operations
  Future<void> createPost(PostModel post);
  Future<PostModel?> getPost(String postId);
  Future<List<PostModel>> getPostsByCompany(String companyId);
  Future<List<PostModel>> getAllPosts({
    int? limit,
    bool? isPremium,
    String? orderBy,
    bool descending = true,
  });
  Future<void> updatePost(PostModel post);
  Future<void> deletePost(String postId);
  Future<void> incrementPostViewCount(String postId);
}

class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _companiesCollection => _firestore.collection('companies');
  CollectionReference get _paymentsCollection => _firestore.collection('payments');
  CollectionReference get _inquiriesCollection => _firestore.collection('inquiries');
  CollectionReference get _postsCollection => _firestore.collection('posts');

  // User operations
  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('사용자 생성 실패: $e');
    }
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('사용자 조회 실패: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toJson());
    } catch (e) {
      throw Exception('사용자 업데이트 실패: $e');
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('사용자 삭제 실패: $e');
    }
  }

  // Company operations
  @override
  Future<void> createCompany(CompanyModel company) async {
    try {
      await _companiesCollection.doc(company.id).set(company.toJson());
    } catch (e) {
      throw Exception('기업 생성 실패: $e');
    }
  }

  @override
  Future<CompanyModel?> getCompany(String companyId) async {
    try {
      final doc = await _companiesCollection.doc(companyId).get();
      if (!doc.exists) return null;
      return CompanyModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('기업 조회 실패: $e');
    }
  }

  @override
  Future<List<CompanyModel>> getCompanies({
    String? category,
    String? subcategory,
    String? region,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _companiesCollection;

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (subcategory != null) {
        query = query.where('subcategory', isEqualTo: subcategory);
      }
      if (region != null) {
        query = query.where('region', isEqualTo: region);
      }
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => 
        CompanyModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('기업 목록 조회 실패: $e');
    }
  }

  @override
  Future<void> updateCompany(CompanyModel company) async {
    try {
      await _companiesCollection.doc(company.id).update(company.toJson());
    } catch (e) {
      throw Exception('기업 업데이트 실패: $e');
    }
  }

  @override
  Future<void> deleteCompany(String companyId) async {
    try {
      await _companiesCollection.doc(companyId).delete();
    } catch (e) {
      throw Exception('기업 삭제 실패: $e');
    }
  }

  // Payment operations
  @override
  Future<void> createPayment(PaymentModel payment) async {
    try {
      await _paymentsCollection.doc(payment.id).set(payment.toJson());
    } catch (e) {
      throw Exception('결제 생성 실패: $e');
    }
  }

  @override
  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (!doc.exists) return null;
      return PaymentModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('결제 조회 실패: $e');
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsByUser(String userId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => 
        PaymentModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('사용자 결제 내역 조회 실패: $e');
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsByCompany(String companyId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('companyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => 
        PaymentModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('기업 결제 내역 조회 실패: $e');
    }
  }

  @override
  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _paymentsCollection.doc(payment.id).update(payment.toJson());
    } catch (e) {
      throw Exception('결제 업데이트 실패: $e');
    }
  }

  // Inquiry operations
  @override
  Future<void> createInquiry(InquiryModel inquiry) async {
    try {
      await _inquiriesCollection.doc(inquiry.id).set(inquiry.toJson());
    } catch (e) {
      throw Exception('문의 생성 실패: $e');
    }
  }

  @override
  Future<InquiryModel?> getInquiry(String inquiryId) async {
    try {
      final doc = await _inquiriesCollection.doc(inquiryId).get();
      if (!doc.exists) return null;
      return InquiryModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('문의 조회 실패: $e');
    }
  }

  @override
  Future<List<InquiryModel>> getInquiriesByUser(String userId) async {
    try {
      final snapshot = await _inquiriesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => 
        InquiryModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('사용자 문의 목록 조회 실패: $e');
    }
  }

  @override
  Future<List<InquiryModel>> getAllInquiries() async {
    try {
      final snapshot = await _inquiriesCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => 
        InquiryModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('전체 문의 목록 조회 실패: $e');
    }
  }

  @override
  Future<void> updateInquiry(InquiryModel inquiry) async {
    try {
      await _inquiriesCollection.doc(inquiry.id).update(inquiry.toJson());
    } catch (e) {
      throw Exception('문의 업데이트 실패: $e');
    }
  }

  // Post operations
  @override
  Future<void> createPost(PostModel post) async {
    try {
      await _postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('게시글 생성 실패: $e');
    }
  }

  @override
  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return null;
      return PostModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('게시글 조회 실패: $e');
    }
  }

  @override
  Future<List<PostModel>> getPostsByCompany(String companyId) async {
    try {
      final snapshot = await _postsCollection
          .where('companyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => 
        PostModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('기업 게시글 목록 조회 실패: $e');
    }
  }

  @override
  Future<List<PostModel>> getAllPosts({
    int? limit,
    bool? isPremium,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      Query query = _postsCollection.where('status', isEqualTo: 'published');

      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }
      
      final orderByField = orderBy ?? 'createdAt';
      query = query.orderBy(orderByField, descending: descending);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => 
        PostModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('게시글 목록 조회 실패: $e');
    }
  }

  @override
  Future<void> updatePost(PostModel post) async {
    try {
      await _postsCollection.doc(post.id).update(post.toJson());
    } catch (e) {
      throw Exception('게시글 업데이트 실패: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  @override
  Future<void> incrementPostViewCount(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'viewCount': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('게시글 조회수 증가 실패: $e');
    }
  }
}