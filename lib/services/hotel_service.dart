import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';
import 'promotion_service.dart';

class HotelService {
  final FirebaseFirestore _firestore;

  HotelService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _hotelCollection =>
      _firestore.collection('hotels');

  Stream<List<Hotel>> getHotels() {
    return _hotelCollection.snapshots().map((snapshot) {
      return snapshot.docs.map(Hotel.fromFirestore).toList();
    });
  }

  Future<Hotel?> getHotelById(String id) async {
    final doc = await _hotelCollection.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return Hotel.fromFirestore(doc);
  }

  Stream<List<Hotel>> searchHotels({
    String? city,
    double? maxPrice,
    bool sortByRating = true,
  }) {
    Query<Map<String, dynamic>> query = _hotelCollection;

    if (city != null && city.trim().isNotEmpty) {
      query = query.where('city', isEqualTo: city.trim());
    }

    if (maxPrice != null) {
      query =
          query.where('pricePerNight', isLessThanOrEqualTo: maxPrice).orderBy(
        'pricePerNight',
      );
    } else if (sortByRating) {
      query = query.orderBy('rating', descending: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map(Hotel.fromFirestore).toList();
    });
  }

  Future<String> addHotel(Hotel hotel) async {
    final docRef = await _hotelCollection.add(hotel.toFirestore());
    return docRef.id;
  }

  Future<void> updateHotel(Hotel hotel) async {
    if (hotel.id.isEmpty) {
      return;
    }
    await _hotelCollection.doc(hotel.id).update(hotel.toFirestore());
  }

  Future<void> deleteHotel(String id) async {
    if (id.isEmpty) {
      return;
    }
    await _hotelCollection.doc(id).delete();
  }

  
  /// PHƯƠNG THỨC ĐƠN GIẢN NHẤT ĐỂ LẤY HOTELS CÓ KHUYẾN MẠI
  Stream<List<Hotel>> getPromotedHotels() {
    return _hotelCollection
        .snapshots()
        .asyncMap((snapshot) async {
          final promotionService = PromotionService();
          final promotedIds = await promotionService.getPromotedHotelIds().first;
          
          if (promotedIds.isEmpty) return [];
          
          // Lọc và giới hạn 6 hotels
          return snapshot.docs
              .map(Hotel.fromFirestore)
              .where((hotel) => promotedIds.contains(hotel.id))
              .take(6)
              .toList();
        });
  }

  /// PHƯƠNG THỨC CHI TIẾT (DÙNG CHO HOME SCREEN)
  Stream<List<Map<String, dynamic>>> getHotelsWithPromotions() {
    return _hotelCollection
        .snapshots()
        .asyncMap((snapshot) async {
          final promotionService = PromotionService();
          
          // 1. Lấy hotelIds có KM
          final promotedIds = await promotionService.getPromotedHotelIds().first;
          
          if (promotedIds.isEmpty) return [];
          
          // 2. Lấy chi tiết promotions
          final promotionMap = await promotionService.getPromotionsForHotels(promotedIds);
          
          // 3. Kết hợp dữ liệu
          final results = <Map<String, dynamic>>[];
          
          for (final doc in snapshot.docs) {
            final hotel = Hotel.fromFirestore(doc);
            
            if (promotionMap.containsKey(hotel.id)) {
              final promotion = promotionMap[hotel.id]!;
              final finalPrice = promotion.calculateFinalPrice(hotel.pricePerNight);
              
              results.add({
                'hotel': hotel,
                'promotion': promotion,
                'finalPrice': finalPrice,
                'discountPercentage': promotion.discountPercentage,
                'originalPrice': hotel.pricePerNight,
              });
              
              // Giới hạn 6 items
              if (results.length >= 6) break;
            }
          }
          
          return results;
        });
  }
}