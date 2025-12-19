import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/company_model.dart';
import '../models/payment_model.dart';
import '../models/inquiry_model.dart';
import '../models/post_model.dart';
import '../models/favorite_model.dart';

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
    String? subSubcategory,
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
  Stream<List<PostModel>> streamUserPosts(String userId);

  // Favorite operations
  Future<void> addFavorite(FavoriteModel favorite);
  Future<void> removeFavorite(String userId, String companyId);
  Future<List<FavoriteModel>> getFavoritesByUser(String userId);
  Future<bool> isFavorite(String userId, String companyId);
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
  CollectionReference get _favoritesCollection => _firestore.collection('favorites');

  // User operations
  @override
  Future<void> createUser(UserModel user) async {
    try {
      final userData = user.toJson();
      // isApproved 필드가 없으면 자동 승인으로 설정
      if (!userData.containsKey('isApproved')) {
        userData['isApproved'] = true;
      }
      await _usersCollection.doc(user.uid).set(userData);
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
      return CompanyModel.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id});
    } catch (e) {
      throw Exception('기업 조회 실패: $e');
    }
  }

  @override
  Future<List<CompanyModel>> getCompanies({
    String? category,
    String? subcategory,
    String? subSubcategory,
    String? region,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _companiesCollection;

      print('🔍 FirestoreDataSource: Loading companies with filters');
      print('🔍 Parameters - category: $category, subcategory: $subcategory, subSubcategory: $subSubcategory');
      
      // 카테고리 필터 적용 (정확한 매칭)
      if (category != null && category.isNotEmpty) {
        try {
          query = query.where('category', isEqualTo: category.trim());
          print('🔍 Applied category filter: "${category.trim()}"');
        } catch (e) {
          print('⚠️ FirestoreDataSource: category filter 실패, 클라이언트에서 필터링: $e');
        }
      }
      
      // 세부카테고리 필터 적용
      if (subcategory != null && subcategory.isNotEmpty) {
        try {
          query = query.where('subcategory', isEqualTo: subcategory.trim());
          print('🔍 Applied subcategory filter: "${subcategory.trim()}"');
        } catch (e) {
          print('⚠️ FirestoreDataSource: subcategory filter 실패, 클라이언트에서 필터링: $e');
        }
      }
      
      // 3차 세부카테고리 필터 적용
      if (subSubcategory != null && subSubcategory.isNotEmpty) {
        try {
          query = query.where('subSubcategory', isEqualTo: subSubcategory.trim());
          print('🔍 Applied subSubcategory filter: "${subSubcategory.trim()}"');
        } catch (e) {
          print('⚠️ FirestoreDataSource: subSubcategory filter 실패, 클라이언트에서 필터링: $e');
        }
      }
      
      // orderBy는 필터 적용 후 시도
      if (orderBy != null) {
        try {
          query = query.orderBy(orderBy, descending: descending);
        } catch (e) {
          // 인덱스 오류 시 orderBy 생략 (클라이언트에서 정렬)
          print('⚠️ FirestoreDataSource: orderBy 실패 (인덱스 없음), 클라이언트에서 정렬: $e');
        }
      }
      
      // limit 적용
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      } else {
        // limit이 없으면 기본값 설정
        query = query.limit(200);
      }

      final snapshot = await query.get();
      print('🔍 FirestoreDataSource: Found ${snapshot.docs.length} companies');
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('🔍 Company: ${data['companyName']} - Category: ${data['category']} - Subcategory: ${data['subcategory']}');
      }
      return snapshot.docs.map((doc) => 
        CompanyModel.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id})
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

  // 카테고리 이름 정규화 (Firebase에 저장된 형태로 변환)
  // 현재는 Firestore 쿼리에서 직접 필터링하므로 미사용
  // @deprecated Firestore 필터링 사용 중
  @Deprecated('Firestore 쿼리에서 직접 필터링 사용 중')
  // ignore: unused_element
  String _normalizeCategoryName(String category) {
    // Firebase에 저장된 카테고리 이름 매핑 (실제 Firebase 데이터 기준)
    final categoryMapping = {
      '*금형/몰드\n*3D 프린터': '*금형/몰드\n*3D 프린터', // 줄바꿈을 공백으로 변환
      '사출\n(공병, 플라스틱, 유리 등)': '사출\n(공병, 플라스틱, 유리 등)',
      '*표면처리\n*건조기\n(열,UV,LED)': '*표면처리\n*건조기\n(열,UV,LED)',
      '*Vision\n(비전)\n*Robot\n(무인화)': '*Vision\n(비전)\n*Robot\n(무인화)',
      '*유공압\n*모터': '*유공압\n*모터',
      // 추가 매핑 (실제 Firebase 데이터와 일치하도록)
      '기계 제작': '기계 제작',
      '인쇄': '인쇄',
      '공구 MALL': '공구 MALL',
    };
    
    final normalized = categoryMapping[category] ?? category;
    print('🔍 Category normalization: "$category" -> "$normalized"');
    return normalized;
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
      return PostModel.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id});
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
        PostModel.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id})
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
        PostModel.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id})
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

  // Favorite operations
  @override
  Future<void> addFavorite(FavoriteModel favorite) async {
    try {
      await _favoritesCollection.doc(favorite.id).set(favorite.toJson());
    } catch (e) {
      throw Exception('좋아요 추가 실패: $e');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String companyId) async {
    try {
      final snapshot = await _favoritesCollection
          .where('userId', isEqualTo: userId)
          .where('companyId', isEqualTo: companyId)
          .get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('좋아요 제거 실패: $e');
    }
  }

  @override
  Future<List<FavoriteModel>> getFavoritesByUser(String userId) async {
    try {
      final snapshot = await _favoritesCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final favorites = snapshot.docs
          .map((doc) => FavoriteModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return favorites;
    } catch (e) {
      throw Exception('좋아요 목록 조회 실패: $e');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String companyId) async {
    try {
      final snapshot = await _favoritesCollection
          .where('userId', isEqualTo: userId)
          .where('companyId', isEqualTo: companyId)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('좋아요 상태 확인 실패: $e');
    }
  }

  @override
  Stream<List<PostModel>> streamUserPosts(String userId) {
    try {
      print('🔍 StreamUserPosts in datasource called for userId: $userId');
      
      // 정확히 userId와 일치하는 게시글만 조회 (본인 게시글만)
      return _postsCollection
          .where('companyId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            print('📊 Posts snapshot received: ${snapshot.docs.length} documents');
            
            // 정확히 userId와 일치하는 게시글만 반환 (본인 게시글만)
            final posts = snapshot.docs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                // companyId가 userId와 일치하는지 다시 한 번 확인
                final postCompanyId = data['companyId'] as String?;
                if (postCompanyId != userId) {
                  print('⚠️ Post ${doc.id} has different companyId: $postCompanyId (expected: $userId)');
                  return null;
                }
                return PostModel.fromJson({...data, 'id': doc.id});
              } catch (e) {
                print('❌ Error processing post doc ${doc.id}: $e');
                return null;
              }
            }).where((post) => post != null).cast<PostModel>().toList();
            
            // 클라이언트 사이드에서 정렬
            posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return posts;
          }).handleError((error) {
            print('❌ Error in streamUserPosts: $error');
            // 인덱스 오류인 경우 orderBy 없이 시도
            if (error.toString().contains('index') || error.toString().contains('Index')) {
              print('🔄 Retrying without orderBy...');
              return _postsCollection
                  .where('companyId', isEqualTo: userId)
                  .snapshots()
                  .map((snapshot) {
                    print('📊 Posts snapshot (no orderBy): ${snapshot.docs.length} documents');
                    final posts = snapshot.docs.map((doc) {
                      try {
                        final data = doc.data() as Map<String, dynamic>;
                        // companyId가 userId와 일치하는지 다시 한 번 확인
                        final postCompanyId = data['companyId'] as String?;
                        if (postCompanyId != userId) {
                          print('⚠️ Post ${doc.id} has different companyId: $postCompanyId (expected: $userId)');
                          return null;
                        }
                        return PostModel.fromJson({...data, 'id': doc.id});
                      } catch (e) {
                        print('❌ Error processing post doc ${doc.id}: $e');
                        return null;
                      }
                    }).where((post) => post != null).cast<PostModel>().toList();
                    
                    // 클라이언트 사이드에서 정렬
                    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    return posts;
                  });
            }
            throw error;
          });
    } catch (e) {
      print('❌ StreamUserPosts in datasource error: $e');
      rethrow;
    }
  }
}