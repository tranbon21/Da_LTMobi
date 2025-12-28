import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';

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
}
