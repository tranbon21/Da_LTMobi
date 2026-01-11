// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import Firebase Auth để lấy user ID
import 'package:firebase_auth/firebase_auth.dart';
// Import các constants của app
import '../utils/constants.dart';
// Import FirestoreService để lưu tour vào database
import '../services/firestore_service.dart';
// Import TourModel
import '../models/tour_model.dart';
// Import EasyLoading để hiển thị loading
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Màn hình Đăng bài Tour Du lịch
///
/// Màn hình này CHỈ dành cho user có role = tourOperator
/// Cho phép nhà cung cấp tour đăng bài quảng cáo tour du lịch mới
class CreateTourPostScreen extends StatefulWidget {
  const CreateTourPostScreen({super.key});

  @override
  State<CreateTourPostScreen> createState() => _CreateTourPostScreenState();
}

class _CreateTourPostScreenState extends State<CreateTourPostScreen> {
  // ==================== FORM KEY ====================

  /// Key để quản lý và validate form
  final _formKey = GlobalKey<FormState>();

  // ==================== CONTROLLERS ====================

  /// Controller cho TextField tên tour
  final _nameController = TextEditingController();

  /// Controller cho TextField điểm đến
  final _destinationController = TextEditingController();

  /// Controller cho TextField mô tả
  final _descriptionController = TextEditingController();

  /// Controller cho TextField thời gian (số ngày)
  final _durationController = TextEditingController();

  /// Controller cho TextField giá
  final _priceController = TextEditingController();

  /// Controller cho TextField số chỗ còn trống
  final _slotsController = TextEditingController();

  /// Controller cho TextField đánh giá (rating)
  final _ratingController = TextEditingController();

  /// Controller cho TextField hướng dẫn viên
  final _tourGuideController = TextEditingController();

  /// Controller cho TextField highlight mới
  final _highlightController = TextEditingController();

  /// Controller cho TextField image URL mới
  final _imageUrlController = TextEditingController();

  // ==================== STATE ====================

  /// Biến theo dõi trạng thái loading
  bool _isLoading = false;

  /// Danh sách highlights đã thêm
  final List<String> _highlights = [];

  /// Danh sách image URLs đã thêm
  final List<String> _imageUrls = [];

  // ==================== LIFECYCLE ====================

  @override
  void dispose() {
    // Giải phóng bộ nhớ của các controllers
    _nameController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    _ratingController.dispose();
    _tourGuideController.dispose();
    _highlightController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ==================== METHODS ====================

  /// Xử lý đăng bài tour mới
  ///
  /// Hàm này sẽ:
  /// 1. Validate form
  /// 2. Tạo Tour object với thông tin đã nhập
  /// 3. Lưu vào Firestore
  /// 4. Hiển thị thông báo thành công và quay lại
  Future<void> _submitTour() async {
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
      // Tạo Tour object với thông tin đã nhập
      final tour = Tour(
        id: '', // ID sẽ được tạo tự động bởi Firestore
        name: _nameController.text.trim(),
        destination: _destinationController.text.trim(),
        country: 'Việt Nam', // Mặc định là Việt Nam
        description: _descriptionController.text.trim(),
        duration: int.parse(
          _durationController.text.trim(),
        ), // duration là int (số ngày)
        price: double.parse(_priceController.text.trim()),
        rating: double.parse(_ratingController.text.trim()),
        reviewCount: 0, // Mặc định 0 review khi mới tạo
        imageUrls: _imageUrls, // Lấy từ state
        highlights: _highlights, // Lấy từ state
        startDate: DateTime.now(), // TODO: Thêm DatePicker để chọn ngày bắt đầu
        endDate: DateTime.now().add(
          Duration(days: int.parse(_durationController.text.trim())),
        ), // Tự động tính endDate
        maxParticipants: int.parse(
          _slotsController.text.trim(),
        ), // Số chỗ tối đa
        currentParticipants: 0, // Mặc định 0 người đã đăng ký
        tourGuide: _tourGuideController.text.trim(), // Lấy từ controller
      );

      // Lưu tour vào Firestore
      await FirestoreService().createTour(tour);

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
      // AppBar với tiêu đề "Đăng bài tour du lịch"
      appBar: AppBar(title: const Text('Đăng bài tour du lịch')),

      // Body của màn hình
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================== ICON & TITLE ====================

              // Icon tour
              const Icon(Icons.tour, size: 60, color: Colors.purple),
              const SizedBox(height: AppSizes.paddingM),

              // Tiêu đề
              const Text(
                'Thông tin tour du lịch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // ==================== FORM FIELDS ====================

              // Tên tour
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên tour *',
                  hintText: 'VD: Tour Đà Lạt 3 ngày 2 đêm',
                  prefixIcon: Icon(Icons.tour),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập tên tour' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Điểm đến
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Điểm đến *',
                  hintText: 'VD: Đà Lạt',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập điểm đến' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Mô tả
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả *',
                  hintText: 'Mô tả về tour của bạn',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập mô tả' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Thời gian (số ngày)
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Thời gian (số ngày) *',
                  hintText: 'VD: 3',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập thời gian';
                  if (int.tryParse(v) == null) return 'Thời gian không hợp lệ';
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Giá
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá (VNĐ) *',
                  hintText: 'VD: 2000000',
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

              // Số chỗ còn trống
              TextFormField(
                controller: _slotsController,
                decoration: const InputDecoration(
                  labelText: 'Số chỗ còn trống *',
                  hintText: 'VD: 30',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số chỗ';
                  if (int.tryParse(v) == null) return 'Số chỗ không hợp lệ';
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

              const SizedBox(height: AppSizes.paddingM),

              // Hướng dẫn viên
              TextFormField(
                controller: _tourGuideController,
                decoration: const InputDecoration(
                  labelText: 'Hướng dẫn viên',
                  hintText: 'VD: Nguyễn Văn A',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),

              const SizedBox(height: AppSizes.paddingM),

              // ==================== HIGHLIGHTS ====================
              
              // Tiêu đề Highlights
              const Text(
                'Điểm nổi bật',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),

              // Input để thêm highlight mới
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _highlightController,
                      decoration: const InputDecoration(
                        hintText: 'VD: Tham quan vịnh Hạ Long',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.purple),
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_highlightController.text.trim().isNotEmpty) {
                              setState(() {
                                _highlights.add(_highlightController.text.trim());
                                _highlightController.clear();
                              });
                            }
                          },
                  ),
                ],
              ),

              // Danh sách highlights đã thêm
              if (_highlights.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _highlights.map((highlight) {
                    return Chip(
                      label: Text(highlight),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _highlights.remove(highlight);
                              });
                            },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: AppSizes.paddingM),

              // ==================== IMAGE URLS ====================
              
              // Tiêu đề Image URLs
              const Text(
                'Hình ảnh (URLs)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),

              // Input để thêm image URL mới
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        hintText: 'VD: https://example.com/image.jpg',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate, color: Colors.purple),
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_imageUrlController.text.trim().isNotEmpty) {
                              setState(() {
                                _imageUrls.add(_imageUrlController.text.trim());
                                _imageUrlController.clear();
                              });
                            }
                          },
                  ),
                ],
              ),

              // Danh sách image URLs đã thêm
              if (_imageUrls.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingS),
                ...List.generate(_imageUrls.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${_imageUrls[index]}',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _imageUrls.removeAt(index);
                                  });
                                },
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: AppSizes.paddingXL),

              // ==================== NÚT ĐĂNG BÀI ====================

              // Nút đăng bài
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTour,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
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
