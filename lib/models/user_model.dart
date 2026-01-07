/// Enum định nghĩa các loại role (vai trò) của user trong hệ thống
///
/// Có 3 loại role:
/// - customer: Khách hàng thông thường, có thể đặt phòng và tour
/// - hotelOwner: Chủ khách sạn, có thể đăng bài khách sạn mới
/// - tourOperator: Nhà cung cấp tour, có thể đăng bài tour du lịch mới
enum UserRole {
  customer, // Khách hàng
  hotelOwner, // Chủ khách sạn
  tourOperator, // Nhà cung cấp tour
}

/// Extension để convert UserRole sang String và ngược lại
///
/// Extension này giúp:
/// - Convert enum sang string để lưu vào Firestore
/// - Convert string từ Firestore thành enum
extension UserRoleExtension on UserRole {
  /// Convert UserRole enum thành String
  ///
  /// Ví dụ: UserRole.customer → 'customer'
  String toStr() {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.hotelOwner:
        return 'hotel_owner';
      case UserRole.tourOperator:
        return 'tour_operator';
    }
  }

  /// Lấy tên hiển thị tiếng Việt của role
  ///
  /// Dùng để hiển thị trên UI
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Khách hàng';
      case UserRole.hotelOwner:
        return 'Chủ khách sạn';
      case UserRole.tourOperator:
        return 'Nhà cung cấp tour';
    }
  }
}

/// Helper function để convert String thành UserRole enum
///
/// Nhận vào string từ Firestore và convert thành enum
/// Default là customer nếu string không hợp lệ
UserRole userRoleFromString(String? roleStr) {
  switch (roleStr) {
    case 'customer':
      return UserRole.customer;
    case 'hotel_owner':
      return UserRole.hotelOwner;
    case 'tour_operator':
      return UserRole.tourOperator;
    default:
      // Nếu không match, default là customer
      return UserRole.customer;
  }
}

/// Model đại diện cho User trong hệ thống
///
/// Chứa tất cả thông tin của một user bao gồm:
/// - Thông tin cơ bản: id, email, name
/// - Thông tin bổ sung: phoneNumber, avatarUrl
/// - Metadata: createdAt, role
class UserModel {
  /// ID duy nhất của user (từ Firebase Auth)
  final String id;

  /// Email của user
  final String email;

  /// Họ tên của user
  final String name;

  /// Số điện thoại (optional)
  final String? phoneNumber;

  /// URL avatar (optional)
  final String? avatarUrl;

  /// Ngày tạo tài khoản
  final DateTime createdAt;

  /// Role (vai trò) của user trong hệ thống
  ///
  /// Xác định quyền hạn của user:
  /// - customer: Chỉ có thể đặt phòng/tour
  /// - hotelOwner: Có thể đăng bài khách sạn
  /// - tourOperator: Có thể đăng bài tour
  final UserRole role;

  /// Constructor của UserModel
  ///
  /// Tất cả fields đều required trừ phoneNumber và avatarUrl
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    required this.role,
  });

  /// Factory constructor để tạo UserModel từ Map (từ Firestore)
  ///
  /// Nhận vào:
  /// - map: Data từ Firestore document
  /// - id: Document ID
  ///
  /// Convert các field từ Map sang đúng kiểu dữ liệu
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      // ID từ document ID
      id: id,

      // Email - default '' nếu null
      email: map['email'] ?? '',

      // Tên - default '' nếu null
      name: map['name'] ?? '',

      // Số điện thoại - có thể null
      phoneNumber: map['phoneNumber'],

      // Avatar URL - có thể null
      avatarUrl: map['avatarUrl'],

      // Ngày tạo - parse từ ISO8601 string
      // Nếu null thì dùng thời gian hiện tại
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),

      // Role - convert từ string sang enum
      // Default là customer nếu không có hoặc invalid
      role: userRoleFromString(map['role']),
    );
  }

  /// Convert UserModel thành Map để lưu vào Firestore
  ///
  /// Trả về Map chứa tất cả fields (trừ id vì id là document ID)
  Map<String, dynamic> toMap() {
    return {
      // Email
      'email': email,

      // Tên
      'name': name,

      // Số điện thoại (có thể null)
      'phoneNumber': phoneNumber,

      // Avatar URL (có thể null)
      'avatarUrl': avatarUrl,

      // Ngày tạo - convert sang ISO8601 string
      'createdAt': createdAt.toIso8601String(),

      // Role - convert enum sang string để lưu vào Firestore
      'role': role.toStr(),
    };
  }

  /// Copy UserModel với một số fields được thay đổi
  ///
  /// Tạo một instance mới với các fields được update
  /// Các fields không được truyền vào sẽ giữ nguyên giá trị cũ
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? createdAt,
    UserRole? role,
  }) {
    return UserModel(
      // Dùng giá trị mới nếu có, không thì giữ nguyên
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}
