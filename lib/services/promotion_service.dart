import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion_model.dart';

class PromotionService {
  final FirebaseFirestore _firestore;

  PromotionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _promotionCollection =>
      _firestore.collection('promotions');

  /// Lấy danh sách hotelIds đang có khuyến mại
  Stream<List<String>> getPromotedHotelIds() {
    return _promotionCollection.snapshots().map((snapshot) {
      final now = DateTime.now();
      
      return snapshot.docs
          .map((doc) {
            try {
              final promotion = Promotion.fromFirestore(doc);
              
              if (promotion.isValid && promotion.hotelId.isNotEmpty) {
                return promotion.hotelId;
              }
              return null;
            } catch (e) {
              print('Error processing promotion ${doc.id}: $e');
              return null;
            }
          })
          .where((hotelId) => hotelId != null)
          .map((hotelId) => hotelId!)
          .toList();
    });
  }

  /// Lấy Map hotelId -> Promotion cho nhiều hotels
  Future<Map<String, Promotion>> getPromotionsForHotels(List<String> hotelIds) async {
    if (hotelIds.isEmpty) return {};
    
    try {
      // Giới hạn 10 hotels để tránh lỗi Firebase
      final validHotelIds = hotelIds.length > 10 ? hotelIds.sublist(0, 10) : hotelIds;
      
      final snapshot = await _promotionCollection
          .where('hotelId', whereIn: validHotelIds)
          .get();

      final Map<String, Promotion> result = {};
      
      for (final doc in snapshot.docs) {
        try {
          final promotion = Promotion.fromFirestore(doc);
          if (promotion.isValid) {
            result[promotion.hotelId] = promotion;
          }
        } catch (e) {
          print('Error processing promotion ${doc.id}: $e');
        }
      }
      
      return result;
    } catch (e) {
      print('Error in getPromotionsForHotels: $e');
      return {};
    }
  }

  /// Debug: In ra thông tin promotions
  Future<void> debugPromotions() async {
    print('=== DEBUG PROMOTIONS ===');
    
    try {
      final snapshot = await _promotionCollection.get();
      print('Total promotions in Firestore: ${snapshot.docs.length}');
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('\nDocument ID: ${doc.id}');
        print('  hotelId: ${data['hotelId']}');
        
        try {
          final promotion = Promotion.fromFirestore(doc);
          print('  ✅ Valid: ${promotion.isValid}');
          print('  Hotel ID: ${promotion.hotelId}');
          print('  Discount: ${promotion.discountPercentage}%');
          print('  End Date: ${promotion.endDate}');
        } catch (e) {
          print('  ❌ Parse error: $e');
        }
      }
      
      print('=== END DEBUG ===');
    } catch (e) {
      print('Debug error: $e');
    }
  }
  Future<Promotion?> getPromotionForHotel(String hotelId) async {
    try {
      print('🔍 Looking for promotion for hotel: $hotelId');
      
      final snapshot = await _promotionCollection
          .where('hotelId', isEqualTo: hotelId)
          .get();
      
      print('   Found ${snapshot.docs.length} promotion(s)');
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      // Tìm promotion đầu tiên còn hiệu lực
      for (final doc in snapshot.docs) {
        try {
          final promotion = Promotion.fromFirestore(doc);
          print('   Promotion found: ${promotion.discountPercentage}% discount');
          print('   Is valid: ${promotion.isValid}');
          
          if (promotion.isValid) {
            print('   ✅ Using this promotion');
            return promotion;
          }
        } catch (e) {
          print('   ❌ Error parsing: $e');
        }
      }
      
      print('   No valid promotion found');
      return null;
    } catch (e) {
      print('❌ Error getting promotion: $e');
      return null;
    }
  }
  Stream<List<Promotion>> getAllPromotions() {
  return _promotionCollection.snapshots().map((snapshot) {
    final now = DateTime.now();
    
    return snapshot.docs
        .map((doc) {
          try {
            final promotion = Promotion.fromFirestore(doc);
            return promotion.isValid ? promotion : null;
          } catch (e) {
            return null;
          }
        })
        .where((promotion) => promotion != null)
        .map((promotion) => promotion!)
        .toList();
  });
}
}