// File: lib/services/user_promotion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_promotion_model.dart';

class UserPromotionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Claim một promotion cho user - LƯU VÀO user_promotions
  Future<UserPromotion> claimPromotion({
    required String userId,
    required String promotionId,
    required String title,
    required String description,
    required double discountPercentage,
    required double discountAmount,
    required double minOrderAmount,
    required String code,
    required PromotionType type,
    String? imageUrl,
  }) async {
    try {
      // Kiểm tra xem user đã claim promotion này chưa
      // Collection user_promotions
      final existing = await _db
          .collection('user_promotions')  // Đúng collection
          .where('userId', isEqualTo: userId)
          .where('promotionId', isEqualTo: promotionId)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Bạn đã nhận khuyến mại này rồi');
      }

      // Tạo user_promotion document trong collection user_promotions
      final promotion = UserPromotion(
        id: '',
        userId: userId,
        promotionId: promotionId,
        title: title,
        description: description,
        discountPercentage: discountPercentage,
        discountAmount: discountAmount,
        minOrderAmount: minOrderAmount,
        code: code,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        claimedAt: DateTime.now(),
        type: type,
        imageUrl: imageUrl,
      );

      // Lưu vào collection user_promotions
      final docRef = await _db
          .collection('user_promotions')  // Đúng collection
          .add(promotion.toFirestore());

      // Cập nhật ID
      return promotion.copyWith(id: docRef.id);
    } catch (e) {
      print('❌ Error claiming promotion: $e');
      rethrow;
    }
  }

  // Lấy danh sách promotions của user từ collection user_promotions
  Stream<List<UserPromotion>> getUserPromotions(String userId) {
    return _db
        .collection('user_promotions')  // Đúng collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final promotions = snapshot.docs.map((doc) {
        return UserPromotion.fromFirestore(doc);
      }).toList();
      
      promotions.sort((a, b) => b.claimedAt.compareTo(a.claimedAt));
      return promotions;
    });
  }

  // Lấy promotion theo ID
  Future<UserPromotion?> getUserPromotion(String promotionId) async {
    try {
      final doc = await _db
          .collection('user_promotions')
          .doc(promotionId)
          .get();
      
      if (doc.exists) {
        return UserPromotion.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user promotion: $e');
      return null;
    }
  }

  // Đánh dấu đã sử dụng promotion
  Future<void> markPromotionAsUsed(String promotionId) async {
    try {
      await _db
          .collection('user_promotions')
          .doc(promotionId)
          .update({
            'isUsed': true,
            'usedAt': Timestamp.now(),
          });
    } catch (e) {
      print('❌ Error marking promotion as used: $e');
      rethrow;
    }
  }

  // Kiểm tra xem user đã claim welcome package chưa
  Future<bool> hasClaimedWelcomePackage(String userId) async {
    try {
      final snapshot = await _db
          .collection('user_promotions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'welcome')
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking welcome package: $e');
      return false;
    }
  }

  // Lấy số lượng promotions hợp lệ của user
  Future<int> getValidPromotionsCount(String userId) async {
    try {
      final snapshot = await _db
          .collection('user_promotions')
          .where('userId', isEqualTo: userId)
          .get();

      final promotions = snapshot.docs.map((doc) {
        return UserPromotion.fromFirestore(doc);
      }).where((promo) => promo.isValid).toList();

      return promotions.length;
    } catch (e) {
      print('❌ Error getting valid promotions count: $e');
      return 0;
    }
  }
}