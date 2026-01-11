// File: lib/models/user_promotion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum PromotionType {
  welcome,        // Ưu đãi chào mừng
  transport,      // Ưu đãi vé xe
  giftCard,       // Phiếu quà tặng
  hotel,          // Ưu đãi khách sạn
  tour,           // Ưu đãi tour
}

extension PromotionTypeExtension on PromotionType {
  String toStr() {
    switch (this) {
      case PromotionType.welcome:
        return 'welcome';
      case PromotionType.transport:
        return 'transport';
      case PromotionType.giftCard:
        return 'giftCard';
      case PromotionType.hotel:
        return 'hotel';
      case PromotionType.tour:
        return 'tour';
    }
  }

  String get displayName {
    switch (this) {
      case PromotionType.welcome:
        return 'Chào mừng';
      case PromotionType.transport:
        return 'Vé xe';
      case PromotionType.giftCard:
        return 'Quà tặng';
      case PromotionType.hotel:
        return 'Khách sạn';
      case PromotionType.tour:
        return 'Tour';
    }
  }
}

PromotionType promotionTypeFromString(String? typeStr) {
  switch (typeStr) {
    case 'welcome':
      return PromotionType.welcome;
    case 'transport':
      return PromotionType.transport;
    case 'giftCard':
      return PromotionType.giftCard;
    case 'hotel':
      return PromotionType.hotel;
    case 'tour':
      return PromotionType.tour;
    default:
      return PromotionType.welcome;
  }
}

class UserPromotion {
  final String id;
  final String userId;
  final String promotionId;
  final PromotionType type;
  final String title;
  final String description;
  final double discountPercentage;
  final double discountAmount;
  final double minOrderAmount;
  final String code;
  final DateTime expiryDate;
  final DateTime claimedAt;
  final bool isUsed;
  final DateTime? usedAt;
  final String? imageUrl;

  UserPromotion({
    required this.id,
    required this.userId,
    required this.promotionId,
    required this.type,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.discountAmount,
    required this.minOrderAmount,
    required this.code,
    required this.expiryDate,
    required this.claimedAt,
    this.isUsed = false,
    this.usedAt,
    this.imageUrl,
  });

  UserPromotion copyWith({
    String? id,
    String? userId,
    String? promotionId,
    PromotionType? type,
    String? title,
    String? description,
    double? discountPercentage,
    double? discountAmount,
    double? minOrderAmount,
    String? code,
    DateTime? expiryDate,
    DateTime? claimedAt,
    bool? isUsed,
    DateTime? usedAt,
    String? imageUrl,
  }) {
    return UserPromotion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      promotionId: promotionId ?? this.promotionId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      code: code ?? this.code,
      expiryDate: expiryDate ?? this.expiryDate,
      claimedAt: claimedAt ?? this.claimedAt,
      isUsed: isUsed ?? this.isUsed,
      usedAt: usedAt ?? this.usedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory UserPromotion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Xử lý expiryDate
    DateTime expiryDate;
    final expiryValue = data['expiryDate'];
    if (expiryValue is Timestamp) {
      expiryDate = expiryValue.toDate();
    } else if (expiryValue is String) {
      expiryDate = DateTime.parse(expiryValue);
    } else {
      expiryDate = DateTime.now().add(const Duration(days: 30));
    }
    
    // Xử lý claimedAt
    DateTime claimedAt;
    final claimedValue = data['claimedAt'];
    if (claimedValue is Timestamp) {
      claimedAt = claimedValue.toDate();
    } else if (claimedValue is String) {
      claimedAt = DateTime.parse(claimedValue);
    } else {
      claimedAt = DateTime.now();
    }
    
    // Xử lý usedAt
    DateTime? usedAt;
    final usedValue = data['usedAt'];
    if (usedValue != null) {
      if (usedValue is Timestamp) {
        usedAt = usedValue.toDate();
      } else if (usedValue is String) {
        usedAt = DateTime.parse(usedValue);
      }
    }
    
    return UserPromotion(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      promotionId: data['promotionId']?.toString() ?? '',
      type: promotionTypeFromString(data['type']),
      title: data['title']?.toString() ?? 'Ưu đãi',
      description: data['description']?.toString() ?? '',
      discountPercentage: (data['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (data['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      code: data['code']?.toString() ?? '',
      expiryDate: expiryDate,
      claimedAt: claimedAt,
      isUsed: data['isUsed'] ?? false,
      usedAt: usedAt,
      imageUrl: data['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'promotionId': promotionId,
      'type': type.toStr(),
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'minOrderAmount': minOrderAmount,
      'code': code,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'claimedAt': Timestamp.fromDate(claimedAt),
      'isUsed': isUsed,
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'imageUrl': imageUrl,
    };
  }

  /// Kiểm tra ưu đãi còn hiệu lực
  bool get isValid {
    final now = DateTime.now();
    return !isUsed && now.isBefore(expiryDate);
  }

  /// Tính giá sau khuyến mại
  double calculateFinalPrice(double originalPrice) {
    if (originalPrice < minOrderAmount) return originalPrice;
    
    if (discountPercentage > 0) {
      return originalPrice * (1 - discountPercentage / 100);
    } else if (discountAmount > 0) {
      return originalPrice - discountAmount;
    }
    
    return originalPrice;
  }

  /// Lấy số tiền được giảm
  double getDiscountAmount(double originalPrice) {
    if (originalPrice < minOrderAmount) return 0;
    
    if (discountPercentage > 0) {
      return originalPrice * (discountPercentage / 100);
    } else {
      return discountAmount;
    }
  }
}