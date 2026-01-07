import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id;
  final String hotelId;
  final double discountPercentage;
  final bool isActive;
  final DateTime endDate;

  Promotion({
    required this.id,
    required this.hotelId,
    required this.discountPercentage,
    required this.isActive,
    required this.endDate,
  });

  factory Promotion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // XỬ LÝ endDate (có thể là string hoặc timestamp)
    DateTime endDate;
    final endDateValue = data['endDate'];
    
    if (endDateValue is Timestamp) {
      endDate = endDateValue.toDate();
    } else if (endDateValue is String) {
      endDate = DateTime.parse(endDateValue);
    } else {
      endDate = DateTime.now().add(const Duration(days: 30));
    }
    
    // XỬ LÝ discountPercentage (có thể là string hoặc number)
    double discountPercentage;
    final discountValue = data['discountPercentage'];
    
    if (discountValue is num) {
      discountPercentage = discountValue.toDouble();
    } else if (discountValue is String) {
      discountPercentage = double.tryParse(discountValue) ?? 0.0;
    } else {
      discountPercentage = 0.0;
    }
    
    return Promotion(
      id: doc.id,
      hotelId: data['hotelId']?.toString() ?? '',
      discountPercentage: discountPercentage,
      isActive: data['isActive'] ?? true,
      endDate: endDate,
    );
  }

  /// KIỂM TRA KHUYẾN MẠI CÒN HIỆU LỰC
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isBefore(endDate);
  }

  /// TÍNH GIÁ SAU KHI ÁP DỤNG KHUYẾN MẠI
  double calculateFinalPrice(double originalPrice) {
    return originalPrice * (1 - discountPercentage / 100);
  }

  /// CHUYỂN THÀNH MAP ĐỂ LƯU FIRESTORE
  Map<String, dynamic> toFirestore() {
    return {
      'hotelId': hotelId,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  /// DEBUG
  @override
  String toString() {
    return 'Promotion{hotelId: $hotelId, discount: ${discountPercentage}%, valid: $isValid}';
  }
}