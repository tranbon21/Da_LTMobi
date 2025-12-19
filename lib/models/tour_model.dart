class Tour {
  final String id;
  final String name;
  final String description;
  final String destination;
  final String country;
  final double price;
  final int duration; // in days
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final List<String> highlights;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final int currentParticipants;
  final String tourGuide;

  Tour({
    required this.id,
    required this.name,
    required this.description,
    required this.destination,
    required this.country,
    required this.price,
    required this.duration,
    required this.rating,
    required this.reviewCount,
    required this.imageUrls,
    required this.highlights,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.tourGuide,
  });

  factory Tour.fromMap(Map<String, dynamic> map, String id) {
    return Tour(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      destination: map['destination'] ?? '',
      country: map['country'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      duration: map['duration'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      highlights: List<String>.from(map['highlights'] ?? []),
      startDate: DateTime.parse(
        map['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        map['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      maxParticipants: map['maxParticipants'] ?? 0,
      currentParticipants: map['currentParticipants'] ?? 0,
      tourGuide: map['tourGuide'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'destination': destination,
      'country': country,
      'price': price,
      'duration': duration,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrls': imageUrls,
      'highlights': highlights,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'tourGuide': tourGuide,
    };
  }

  bool get isAvailable => currentParticipants < maxParticipants;

  Tour copyWith({
    String? id,
    String? name,
    String? description,
    String? destination,
    String? country,
    double? price,
    int? duration,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    List<String>? highlights,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    int? currentParticipants,
    String? tourGuide,
  }) {
    return Tour(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      highlights: highlights ?? this.highlights,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      tourGuide: tourGuide ?? this.tourGuide,
    );
  }
}
