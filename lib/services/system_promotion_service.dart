// File: lib/services/system_promotion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SystemPromotion {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final double discountAmount;
  final double minOrderAmount;
  final String code;
  final DateTime expiryDate;
  final DateTime createdAt;
  final bool isActive;
  final String category; // transport, gift, welcome, etc.
  final String? imageUrl;
  final int stock; // Số lượng còn lại
  final int claimedCount; // Số lượng đã claim

  SystemPromotion({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.discountAmount,
    required this.minOrderAmount,
    required this.code,
    required this.expiryDate,
    required this.createdAt,
    required this.isActive,
    required this.category,
    this.imageUrl,
    this.stock = 100,
    this.claimedCount = 0,
  });

  factory SystemPromotion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Xử lý dates
    DateTime expiryDate;
    final expiryValue = data['expiryDate'];
    if (expiryValue is Timestamp) {
      expiryDate = expiryValue.toDate();
    } else if (expiryValue is String) {
      expiryDate = DateTime.parse(expiryValue);
    } else {
      expiryDate = DateTime.now().add(const Duration(days: 30));
    }
    
    DateTime createdAt;
    final createdValue = data['createdAt'];
    if (createdValue is Timestamp) {
      createdAt = createdValue.toDate();
    } else if (createdValue is String) {
      createdAt = DateTime.parse(createdValue);
    } else {
      createdAt = DateTime.now();
    }
    
    return SystemPromotion(
      id: doc.id,
      title: data['title']?.toString() ?? 'Ưu đãi',
      description: data['description']?.toString() ?? '',
      discountPercentage: (data['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (data['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      code: data['code']?.toString() ?? '',
      expiryDate: expiryDate,
      createdAt: createdAt,
      isActive: data['isActive'] ?? true,
      category: data['category']?.toString() ?? 'general',
      imageUrl: data['imageUrl']?.toString(),
      stock: (data['stock'] as num?)?.toInt() ?? 100,
      claimedCount: (data['claimedCount'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isBefore(expiryDate) && stock > 0;
  }

  bool get isAvailable => stock > 0;
}

class SystemPromotionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lấy tất cả promotions từ hệ thống
  // Sửa collection name từ 'system_promotions' thành 'promotions_user'
Stream<List<SystemPromotion>> getAllPromotions() {
  return _db
      .collection('promotions_user')  // Sửa collection name
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final promotions = snapshot.docs.map((doc) {
      return SystemPromotion.fromFirestore(doc);
    }).toList();
    
    promotions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return promotions;
  });
}

Stream<List<SystemPromotion>> getPromotionsByCategory(String category) {
  return _db
      .collection('promotions_user')  // Sửa collection name
      .where('isActive', isEqualTo: true)
      .where('category', isEqualTo: category)
      .snapshots()
      .map((snapshot) {
    final promotions = snapshot.docs.map((doc) {
      return SystemPromotion.fromFirestore(doc);
    }).toList();
    
    promotions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return promotions;
  });
}

// Thêm phương thức mới để lấy promotion welcome
Future<SystemPromotion?> getWelcomePromotion() async {
  try {
    final snapshot = await _db
        .collection('promotions_user')
        .where('isActive', isEqualTo: true)
        .where('code', isEqualTo: 'WELCOME50')  // Hoặc where('type', isEqualTo: 'welcome')
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return SystemPromotion.fromFirestore(snapshot.docs.first);
    }
    return null;
  } catch (e) {
    print('Error getting welcome promotion: $e');
    return null;
  }
}

  // Claim một promotion
  Future<void> claimPromotion(String promotionId) async {
    try {
      await _db.runTransaction((transaction) async {
        final docRef = _db.collection('system_promotions').doc(promotionId);
        final doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final promotion = SystemPromotion.fromFirestore(doc);
          
          if (!promotion.isValid) {
            throw Exception('Khuyến mại không còn hiệu lực');
          }
          
          if (promotion.stock <= 0) {
            throw Exception('Khuyến mại đã hết');
          }
          
          // Giảm stock và tăng claimed count
          transaction.update(docRef, {
            'stock': FieldValue.increment(-1),
            'claimedCount': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      print('❌ Error claiming system promotion: $e');
      rethrow;
    }
  }
}