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
    return Hotel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      availableRooms: map['availableRooms'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
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
