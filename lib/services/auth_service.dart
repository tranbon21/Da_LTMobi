// Import thư viện Firebase Authentication để xác thực người dùng
import 'package:firebase_auth/firebase_auth.dart';
// Import model UserModel để quản lý thông tin người dùng
import '../models/user_model.dart';
// Import service Firestore để lưu trữ dữ liệu người dùng
import 'firestore_service.dart';

/// Service quản lý xác thực người dùng với Firebase Authentication
///
/// Class này cung cấp các phương thức để:
/// - Đăng nhập với email/password
/// - Đăng ký tài khoản mới
/// - Đăng nhập với tư cách khách (anonymous)
/// - Đăng xuất
/// - Kiểm tra trạng thái đăng nhập
class AuthService {
  // Instance của FirebaseAuth để thực hiện các thao tác xác thực
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance của FirestoreService để lưu/đọc thông tin người dùng từ Firestore
  final FirestoreService _firestoreService = FirestoreService();

  /// Lấy thông tin user hiện tại đang đăng nhập
  ///
  /// Trả về User nếu đã đăng nhập, null nếu chưa đăng nhập
  User? get currentUser => _auth.currentUser;

  /// Stream theo dõi thay đổi trạng thái đăng nhập
  ///
  /// Stream này sẽ emit User mới mỗi khi:
  /// - User đăng nhập
  /// - User đăng xuất
  /// - Token được refresh
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Kiểm tra xem user hiện tại có phải là khách (anonymous) không
  ///
  /// Trả về true nếu user đang đăng nhập ẩn danh (guest mode)
  /// Trả về false nếu user đăng nhập bằng email/password hoặc chưa đăng nhập
  bool isGuestUser() {
    // Lấy user hiện tại
    final user = currentUser;

    // Nếu chưa đăng nhập thì không phải guest
    if (user == null) return false;

    // Kiểm tra xem user có phải là anonymous không
    // isAnonymous = true nghĩa là đăng nhập với tư cách khách
    return user.isAnonymous;
  }

  /// Đăng nhập với email và mật khẩu
  ///
  /// Tham số:
  /// - email: Địa chỉ email của người dùng
  /// - password: Mật khẩu của người dùng
  ///
  /// Trả về UserModel nếu đăng nhập thành công, null nếu thất bại
  /// Throw exception nếu có lỗi (email/password sai, network error, etc.)
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Gọi Firebase Auth để đăng nhập với email và password
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin User từ kết quả đăng nhập
      User? user = result.user;

      // Nếu đăng nhập thành công (user không null)
      if (user != null) {
        // Lấy thông tin chi tiết của user từ Firestore database
        return await _firestoreService.getUser(user.uid);
      }

      // Trả về null nếu không có user
      return null;
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi đăng nhập: $e');

      // Throw lại exception để UI có thể xử lý và hiển thị thông báo lỗi
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới với email và mật khẩu
  ///
  /// Tham số:
  /// - email: Địa chỉ email của người dùng
  /// - password: Mật khẩu của người dùng
  /// - name: Tên đầy đủ của người dùng
  /// - phoneNumber: Số điện thoại (optional)
  ///
  /// Trả về UserModel nếu đăng ký thành công, null nếu thất bại
  /// Throw exception nếu có lỗi (email đã tồn tại, password yếu, etc.)
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.customer, // Role mặc định là customer
  }) async {
    try {
      // Gọi Firebase Auth để tạo tài khoản mới với email và password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin User từ kết quả đăng ký
      User? user = result.user;

      // Nếu tạo tài khoản thành công
      if (user != null) {
        // Tạo object UserModel với thông tin người dùng
        UserModel newUser = UserModel(
          id: user.uid, // ID duy nhất từ Firebase Auth
          email: email, // Email người dùng
          name: name, // Tên người dùng
          phoneNumber: phoneNumber, // Số điện thoại (có thể null)
          createdAt: DateTime.now(), // Thời gian tạo tài khoản
          role: role, // Role của user (customer/hotelOwner/tourOperator)
        );

        // Lưu thông tin user vào Firestore database
        await _firestoreService.createUser(newUser);

        // Trả về UserModel đã tạo
        return newUser;
      }

      // Trả về null nếu không tạo được user
      return null;
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi đăng ký: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
  }

  /// Đăng nhập với tư cách khách (anonymous)
  ///
  /// Phương thức này cho phép người dùng sử dụng app mà không cần tạo tài khoản.
  /// User khách sẽ có một số hạn chế (ví dụ: không thể đặt phòng).
  ///
  /// Trả về User nếu đăng nhập thành công
  /// Throw exception nếu có lỗi
  Future<User?> signInAsGuest() async {
    try {
      // Gọi Firebase Auth để đăng nhập ẩn danh
      // Firebase sẽ tự động tạo một user ID duy nhất cho guest
      UserCredential result = await _auth.signInAnonymously();

      // Trả về thông tin user guest
      return result.user;
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi đăng nhập với tư cách khách: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
  }

  /// Đăng xuất khỏi tài khoản hiện tại
  ///
  /// Phương thức này sẽ đăng xuất user (dù là guest hay user thông thường)
  /// và chuyển về màn hình đăng nhập
  Future<void> signOut() async {
    try {
      // Gọi Firebase Auth để đăng xuất
      await _auth.signOut();
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi đăng xuất: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
  }

  /// Gửi email đặt lại mật khẩu
  ///
  /// Tham số:
  /// - email: Địa chỉ email cần reset password
  ///
  /// Firebase sẽ gửi một email chứa link để đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      // Gọi Firebase Auth để gửi email reset password
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi reset mật khẩu: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
  }

  /// Cập nhật thông tin profile của user
  ///
  /// Tham số:
  /// - displayName: Tên hiển thị mới (optional)
  /// - photoURL: URL ảnh đại diện mới (optional)
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      // Lấy user hiện tại
      User? user = currentUser;

      // Nếu có user đang đăng nhập
      if (user != null) {
        // Cập nhật tên hiển thị nếu có
        await user.updateDisplayName(displayName);

        // Cập nhật ảnh đại diện nếu có
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi cập nhật profile: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
  }

  /// Xóa tài khoản người dùng
  ///
  /// Phương thức này sẽ:
  /// 1. Xóa dữ liệu user trong Firestore
  /// 2. Xóa tài khoản trong Firebase Auth
  ///
  /// CẢNH BÁO: Hành động này không thể hoàn tác!
  Future<void> deleteAccount() async {
    try {
      // Lấy user hiện tại
      User? user = currentUser;

      // Nếu có user đang đăng nhập
      if (user != null) {
        // Xóa dữ liệu user trong Firestore trước
        await _firestoreService.deleteUser(user.uid);

        // Sau đó xóa tài khoản trong Firebase Auth
        await user.delete();
      }
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi xóa tài khoản: $e');

      // Throw lại exception để UI có thể xử lý
      rethrow;
    }
  }

  /// Lấy role (vai trò) của user hiện tại
  ///
  /// Trả về UserRole của user đang đăng nhập
  /// Trả về null nếu chưa đăng nhập hoặc không tìm thấy user trong Firestore
  ///
  /// Sử dụng method này để kiểm tra quyền hạn của user
  /// Ví dụ: Chỉ cho phép hotel_owner truy cập màn hình đăng bài khách sạn
  Future<UserRole?> getUserRole() async {
    try {
      // Lấy user hiện tại từ Firebase Auth
      final currentUser = _auth.currentUser;

      // Nếu chưa đăng nhập hoặc là guest thì return null
      if (currentUser == null || currentUser.isAnonymous) {
        return null;
      }

      // Lấy thông tin user từ Firestore
      final userData = await _firestoreService.getUser(currentUser.uid);

      // Trả về role của user (hoặc null nếu không tìm thấy)
      return userData?.role;
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi khi lấy role của user: $e');

      // Trả về null nếu có lỗi
      return null;
    }
  }
}
