import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String country;
  final double pricePerNight;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final List<String> amenities;
  final double latitude;
  final double longitude;
  final int availableRooms;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.pricePerNight,
    required this.rating,
    required this.reviewCount,
    required this.imageUrls,
    required this.amenities,
    required this.latitude,
    required this.longitude,
    required this.availableRooms,
  });

  factory Hotel.fromMap(Map<String, dynamic> map, String id) {
    return Hotel.fromJson(map, id: id);
  }

  factory Hotel.fromJson(Map<String, dynamic> json, {String? id}) {
    final priceValue = json['pricePerNight'];
    final ratingValue = json['rating'];
    final latitudeValue = json['latitude'];
    final longitudeValue = json['longitude'];

    return Hotel(
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      pricePerNight: (priceValue is num ? priceValue : 0).toDouble(),
      rating: (ratingValue is num ? ratingValue : 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      latitude: (latitudeValue is num ? latitudeValue : 0).toDouble(),
      longitude: (longitudeValue is num ? longitudeValue : 0).toDouble(),
      availableRooms: json['availableRooms'] ?? 0,
    );
  }

  factory Hotel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Hotel.fromJson(doc.data() ?? {}, id: doc.id);
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'pricePerNight': pricePerNight,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'latitude': latitude,
      'longitude': longitude,
      'availableRooms': availableRooms,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  Hotel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? country,
    double? pricePerNight,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    List<String>? amenities,
    double? latitude,
    double? longitude,
    int? availableRooms,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availableRooms: availableRooms ?? this.availableRooms,
    );
  }
}
