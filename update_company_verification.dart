import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase에 저장된 모든 기업의 isVerified 필드를 true로 업데이트하는 스크립트
// 이 파일을 main.dart에서 임시로 실행하거나 별도로 실행할 수 있습니다.

Future<void> updateCompanyVerification() async {
  try {
    final companiesCollection = FirebaseFirestore.instance.collection('companies');
    
    // 모든 기업 문서 가져오기
    final snapshot = await companiesCollection.get();
    
    print('Found ${snapshot.docs.length} companies to update');
    
    // 각 문서의 isVerified 필드를 true로 업데이트
    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Updated company: ${doc.id}');
    }
    
    print('All companies have been verified!');
  } catch (e) {
    print('Error updating companies: $e');
  }
}

// 사용법:
// 1. 이 함수를 main.dart의 main() 함수에서 호출
// 2. 또는 별도의 스크립트로 실행
// 3. Firebase Console에서 직접 수동으로 업데이트
