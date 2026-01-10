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
    // Helper function để parse giá trị thành double an toàn
    double _parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    // Helper function để parse giá trị thành int an toàn
    int _parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    // Helper function để parse List<String> an toàn
    List<String> _parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        try {
          return List<String>.from(value);
        } catch (e) {
          print('Error parsing list: $e');
          return [];
        }
      }
      if (value is String) {
        // Nếu là string rỗng, trả về list rỗng
        if (value.isEmpty) return [];
        // Nếu là string không rỗng, wrap thành list
        return [value];
      }
      return [];
    }

    // Helper function để parse DateTime an toàn
    DateTime _parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      
      if (value is DateTime) return value;
      
      if (value is String) {
        try {
          // Thử parse ISO 8601 format
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing date "$value": $e');
          // Nếu parse lỗi, trả về ngày hiện tại
          return DateTime.now();
        }
      }
      
      // Nếu không phải String hoặc DateTime, trả về ngày hiện tại
      return DateTime.now();
    }

    return Tour(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      destination: map['destination'] ?? '',
      country: map['country'] ?? '',
      price: _parseDouble(map['price'], 0),
      duration: _parseInt(map['duration'], 0),
      rating: _parseDouble(map['rating'], 0),
      reviewCount: _parseInt(map['reviewCount'], 0),
      imageUrls: _parseStringList(map['imageUrls']),
      highlights: _parseStringList(map['highlights']),
      startDate: _parseDateTime(map['startDate']),
      endDate: _parseDateTime(map['endDate']),
      maxParticipants: _parseInt(map['maxParticipants'], 0),
      currentParticipants: _parseInt(map['currentParticipants'], 0),
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
