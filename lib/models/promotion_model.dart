/// Model cho Promotion (Khuyến mãi/Ưu đãi)
///
/// Model này đại diện cho một chương trình khuyến mãi trong app
/// Ví dụ: "Giảm 30% Khách sạn & Resort", "Giảm vé xe đến 250K VND"
class Promotion {
  /// ID của promotion (document ID trong Firestore)
  final String id;

  /// Tiêu đề của promotion
  /// Ví dụ: "Giảm Vé Xe Đến 250K VND"
  final String title;

  /// Mô tả chi tiết của promotion
  /// Ví dụ: "Áp dụng cho tất cả các tuyến xe"
  final String description;

  /// URL của ảnh promotion
  /// Nếu không có ảnh thì để rỗng
  final String imageUrl;

  /// Phần trăm giảm giá (nếu có)
  /// Ví dụ: 30 (tức là giảm 30%)
  /// Nếu không phải giảm theo % thì để 0
  final int discountPercent;

  /// Số tiền giảm cố định (nếu có)
  /// Ví dụ: 250000 (tức là giảm 250K VND)
  /// Nếu không phải giảm cố định thì để 0
  final double discountAmount;

  /// Ngày bắt đầu promotion
  final DateTime startDate;

  /// Ngày kết thúc promotion
  final DateTime endDate;

  /// Promotion có đang active không
  /// true = đang hoạt động, false = đã hết hạn hoặc chưa bắt đầu
  final bool isActive;

  /// ID của hotel áp dụng promotion (optional)
  /// Nếu có giá trị thì promotion chỉ áp dụng cho hotel này
  /// Nếu null thì áp dụng cho tất cả
  final String? hotelId;

  /// Mã giảm giá (voucher code)
  /// Ví dụ: "HOTEL30", "TOUR20"
  final String voucherCode;

  /// Điều kiện áp dụng
  /// Ví dụ: "Áp dụng cho đơn hàng từ 500.000đ"
  final String conditions;

  /// Constructor
  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountPercent,
    required this.discountAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.hotelId, // Optional field
    this.voucherCode = '', // Default empty
    this.conditions = '', // Default empty
  });

  /// Tạo Promotion từ Map (từ Firestore)
  ///
  /// Map này được lấy từ Firestore document
  /// id là document ID
  factory Promotion.fromMap(Map<String, dynamic> map, String id) {
    return Promotion(
      // ID của document
      id: id,
      // Tiêu đề promotion
      title: map['title'] ?? '',
      // Mô tả
      description: map['description'] ?? '',
      // URL ảnh
      imageUrl: map['imageUrl'] ?? '',
      // Phần trăm giảm
      discountPercent: map['discountPercent'] ?? 0,
      // Số tiền giảm
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      // Ngày bắt đầu - parse từ string ISO8601
      startDate: DateTime.parse(
        map['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      // Ngày kết thúc - parse từ string ISO8601
      endDate: DateTime.parse(
        map['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      // Trạng thái active
      isActive: map['isActive'] ?? true,
      // Hotel ID (optional)
      hotelId: map['hotelId'],
      // Voucher code
      voucherCode: map['voucherCode'] ?? '',
      // Conditions
      conditions: map['conditions'] ?? '',
    );
  }

  /// Chuyển Promotion thành Map (để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      // Tiêu đề
      'title': title,
      // Mô tả
      'description': description,
      // URL ảnh
      'imageUrl': imageUrl,
      // Phần trăm giảm
      'discountPercent': discountPercent,
      // Số tiền giảm
      'discountAmount': discountAmount,
      // Ngày bắt đầu - convert sang string ISO8601
      'startDate': startDate.toIso8601String(),
      // Ngày kết thúc - convert sang string ISO8601
      'endDate': endDate.toIso8601String(),
      // Trạng thái active
      'isActive': isActive,
    };
  }

  /// Kiểm tra promotion có còn hiệu lực không
  ///
  /// Promotion còn hiệu lực khi:
  /// - isActive = true
  /// - Ngày hiện tại nằm trong khoảng startDate và endDate
  bool get isValid {
    // Lấy thời gian hiện tại
    final now = DateTime.now();

    // Kiểm tra active và trong khoảng thời gian
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Lấy text hiển thị giảm giá
  ///
  /// Ví dụ: "Giảm 30%", "Giảm 250K", "Ưu đãi"
  String get discountText {
    // Nếu có phần trăm giảm
    if (discountPercent > 0) {
      return 'Giảm $discountPercent%';
    }
    // Nếu có số tiền giảm
    else if (discountAmount > 0) {
      return 'Giảm ${(discountAmount / 1000).toInt()}K';
    }
    // Mặc định
    else {
      return 'Ưu đãi';
    }
  }
}
