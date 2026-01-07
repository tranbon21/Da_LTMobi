// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import Firebase Auth để lấy user ID
import 'package:firebase_auth/firebase_auth.dart';
// Import các constants của app
import '../utils/constants.dart';
// Import FirestoreService để lưu hotel vào database
import '../services/firestore_service.dart';
// Import HotelModel
import '../models/hotel_model.dart';
// Import EasyLoading để hiển thị loading
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Màn hình Đăng bài Khách sạn
///
/// Màn hình này CHỈ dành cho user có role = hotelOwner
/// Cho phép chủ khách sạn đăng bài quảng cáo khách sạn mới
class CreateHotelPostScreen extends StatefulWidget {
  const CreateHotelPostScreen({super.key});

  @override
  State<CreateHotelPostScreen> createState() => _CreateHotelPostScreenState();
}

class _CreateHotelPostScreenState extends State<CreateHotelPostScreen> {
  // ==================== FORM KEY ====================

  /// Key để quản lý và validate form
  final _formKey = GlobalKey<FormState>();

  // ==================== CONTROLLERS ====================

  /// Controller cho TextField tên khách sạn
  final _nameController = TextEditingController();

  /// Controller cho TextField địa chỉ
  final _addressController = TextEditingController();

  /// Controller cho TextField thành phố
  final _cityController = TextEditingController();

  /// Controller cho TextField mô tả
  final _descriptionController = TextEditingController();

  /// Controller cho TextField giá mỗi đêm
  final _priceController = TextEditingController();

  /// Controller cho TextField số phòng có sẵn
  final _roomsController = TextEditingController();

  /// Controller cho TextField đánh giá (rating)
  final _ratingController = TextEditingController();

  // ==================== STATE ====================

  /// Biến theo dõi trạng thái loading
  bool _isLoading = false;

  // ==================== LIFECYCLE ====================

  @override
  void dispose() {
    // Giải phóng bộ nhớ của các controllers
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  // ==================== METHODS ====================

  /// Xử lý đăng bài khách sạn mới
  ///
  /// Hàm này sẽ:
  /// 1. Validate form
  /// 2. Tạo Hotel object với thông tin đã nhập
  /// 3. Lưu vào Firestore
  /// 4. Hiển thị thông báo thành công và quay lại
  Future<void> _submitHotel() async {
    // Validate form trước khi submit
    if (!_formKey.currentState!.validate()) return;

    // Lấy user ID hiện tại
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      EasyLoading.showError('Vui lòng đăng nhập để đăng bài');
      return;
    }

    // Bắt đầu loading
    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Đang đăng bài...');

    try {
      // Tạo Hotel object với thông tin đã nhập
      final hotel = Hotel(
        id: '', // ID sẽ được tạo tự động bởi Firestore
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        country: 'Việt Nam', // Mặc định là Việt Nam
        description: _descriptionController.text.trim(),
        pricePerNight: double.parse(_priceController.text.trim()),
        rating: double.parse(_ratingController.text.trim()),
        reviewCount: 0, // Mặc định 0 review khi mới tạo
        imageUrls: [], // TODO: Thêm tính năng upload ảnh sau
        amenities: [], // TODO: Thêm UI để chọn amenities
        latitude: 0.0, // TODO: Thêm tính năng chọn vị trí trên bản đồ
        longitude: 0.0, // TODO: Thêm tính năng chọn vị trí trên bản đồ
        availableRooms: int.parse(_roomsController.text.trim()),
      );

      // Lưu hotel vào Firestore
      await FirestoreService().createHotel(hotel);

      // Dismiss loading
      EasyLoading.dismiss();

      // Hiển thị thông báo thành công
      EasyLoading.showSuccess(
        'Đăng bài thành công!',
        duration: const Duration(seconds: 2),
      );

      // Đợi 1 giây rồi quay lại màn hình trước
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Có lỗi xảy ra
      EasyLoading.dismiss();
      EasyLoading.showError('Đăng bài thất bại: $e');

      setState(() => _isLoading = false);
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề "Đăng bài khách sạn"
      appBar: AppBar(title: const Text('Đăng bài khách sạn')),

      // Body của màn hình
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================== ICON & TITLE ====================

              // Icon khách sạn
              const Icon(Icons.hotel, size: 60, color: Colors.orange),
              const SizedBox(height: AppSizes.paddingM),

              // Tiêu đề
              const Text(
                'Thông tin khách sạn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // ==================== FORM FIELDS ====================

              // Tên khách sạn
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách sạn *',
                  hintText: 'VD: Khách sạn Hoàng Gia',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Vui lòng nhập tên khách sạn'
                    : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Địa chỉ
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ *',
                  hintText: 'VD: 123 Đường ABC',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Thành phố
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Thành phố *',
                  hintText: 'VD: TP. Hồ Chí Minh',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập thành phố' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Mô tả
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả *',
                  hintText: 'Mô tả về khách sạn của bạn',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập mô tả' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Giá mỗi đêm
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá mỗi đêm (VNĐ) *',
                  hintText: 'VD: 500000',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập giá';
                  if (double.tryParse(v) == null) return 'Giá không hợp lệ';
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Số phòng có sẵn
              TextFormField(
                controller: _roomsController,
                decoration: const InputDecoration(
                  labelText: 'Số phòng có sẵn *',
                  hintText: 'VD: 20',
                  prefixIcon: Icon(Icons.meeting_room),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số phòng';
                  if (int.tryParse(v) == null) return 'Số phòng không hợp lệ';
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Đánh giá (rating)
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Đánh giá (1-5 sao) *',
                  hintText: 'VD: 4.5',
                  prefixIcon: Icon(Icons.star),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập đánh giá';
                  final rating = double.tryParse(v);
                  if (rating == null) return 'Đánh giá không hợp lệ';
                  if (rating < 1 || rating > 5) return 'Đánh giá phải từ 1-5';
                  return null;
                },
                enabled: !_isLoading,
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // ==================== NÚT ĐĂNG BÀI ====================

              // Nút đăng bài
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitHotel,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Đăng bài', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Ghi chú
              const Text(
                '* Các trường bắt buộc',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
