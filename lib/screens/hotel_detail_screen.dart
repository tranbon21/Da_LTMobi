import 'dart:math';
import 'package:flutter/material.dart';
// Package imports - organized by category
import 'package:cached_network_image/cached_network_image.dart'; // Hiển thị ảnh từ network với cache
import 'package:carousel_slider/carousel_slider.dart'; // Slider ảnh khách sạn đẹp
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // Loading indicators đẹp
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Toast notifications
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // Calendar picker cho date
import 'package:url_launcher/url_launcher.dart'; // Mở Google Maps và URLs
// Local imports - Services & Models
import '../models/booking_model.dart';
import '../models/hotel_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
// Local imports - Widgets
import '../widgets/booking_success_dialog.dart';
import '../widgets/counter_tile.dart';
import '../widgets/date_picker_dialog.dart';

class HotelDetailScreen extends StatefulWidget {
  static const String routeName = '/hotel-detail';
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  // Biến quản lý booking
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _roomCount = 1;
  int _adultCount = 2;
  int _childCount = 0;
  bool _isBooking = false;

  // Controllers cho form inputs
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _specialRequestController =
      TextEditingController();

  // Services
  final FirestoreService _firestoreService = FirestoreService();

  // Carousel slider state
  int _currentImageIndex = 0; // Vị trí hiện tại của slider ảnh

  // Constants cho pricing
  static const int _baseAdultsPerRoom = 2;
  static const int _baseChildrenPerRoom = 1;
  static const int _maxGuestsPerRoom = 4;
  static const double _extraAdultFee = 150000;
  static const double _extraChildFee = 80000;

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  /// Hiển thị dialog chọn ngày nhận phòng.
  ///
  /// Sử dụng HotelDatePickerDialog widget với TableCalendar.
  /// Ngày nhận phòng phải từ hôm nay trở đi.
  Future<void> _selectCheckInDate() async {
    final DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => HotelDatePickerDialog(
        title: 'Chọn ngày nhận phòng',
        icon: Icons.calendar_today,
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _checkInDate ?? DateTime.now(),
        selectedDay: _checkInDate,
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _checkInDate = selectedDate;
        // Reset check-out date nếu nó trước check-in date
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
        }
      });
    }
  }

  /// Hiển thị dialog chọn ngày trả phòng.
  /// Sử dụng HotelDatePickerDialog widget với TableCalendar.
  /// Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 ngày.
  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      Fluttertoast.showToast(
        msg: "Vui lòng chọn ngày nhận phòng trước",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => HotelDatePickerDialog(
        title: 'Chọn ngày trả phòng',
        icon: Icons.calendar_today,
        firstDay: _checkInDate!.add(const Duration(days: 1)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _checkOutDate ?? _checkInDate!.add(const Duration(days: 1)),
        selectedDay: _checkOutDate,
      ),
    );

    if (selectedDate != null) {
      setState(() => _checkOutDate = selectedDate);
    }
  }

  // Mở Google Maps với địa chỉ khách sạn
  Future<void> _openGoogleMaps() async {
    try {
      // Tạo URL Google Maps với địa chỉ khách sạn
      final address =
          '${widget.hotel.address}, ${widget.hotel.city}, ${widget.hotel.country}';
      final encodedAddress = Uri.encodeComponent(address);
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

      final uri = Uri.parse(googleMapsUrl);

      // Launch trực tiếp, không cần check canLaunchUrl
      // (canLaunchUrl thường trả về false trên Android ngay cả khi URL có thể mở được)
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Mở trong Chrome/browser
      );
    } catch (e) {
      // Lỗi khi mở URL
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Không thể mở Google Maps. Vui lòng kiểm tra kết nối.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      }
    }
  }

  /// Hiển thị dialog yêu cầu đăng nhập cho user khách
  ///
  /// Dialog này xuất hiện khi user đang ở chế độ khách (guest mode)
  /// cố gắng đặt phòng. Dialog có 2 nút:
  /// - "Đăng nhập": Chuyển đến màn hình đăng nhập
  /// - "Hủy": Đóng dialog
  void _showGuestLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Icon cảnh báo
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 48,
          ),
          // Tiêu đề dialog
          title: const Text('Yêu cầu đăng nhập', textAlign: TextAlign.center),
          // Nội dung thông báo
          content: const Text(
            'Bạn cần đăng nhập bằng tài khoản để có thể đặt phòng. '
            'Vui lòng đăng ký hoặc đăng nhập để tiếp tục.',
            textAlign: TextAlign.center,
          ),
          // Các nút hành động
          actions: [
            // Nút "Hủy" - đóng dialog
            TextButton(
              onPressed: () {
                // Đóng dialog
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            // Nút "Đăng nhập" - chuyển đến màn hình đăng nhập
            ElevatedButton(
              onPressed: () async {
                // Đóng dialog trước
                Navigator.of(dialogContext).pop();

                // Đăng xuất khỏi chế độ khách
                await AuthService().signOut();

                // AuthGate sẽ tự động chuyển sang LoginScreen
                // khi phát hiện user đã đăng xuất
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đăng nhập'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookHotel() async {
    // Kiểm tra thông tin đầu vào
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày nhận và trả phòng')),
      );
      return;
    }

    if (widget.hotel.availableRooms <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Khách sạn đã hết phòng')));
      return;
    }

    if (_adultCount < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cần ít nhất 1 người lớn')));
      return;
    }

    if (_totalGuests > _maxGuests) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tối đa $_maxGuests khách cho $_roomCount phòng'),
        ),
      );
      return;
    }

    final contactName = _contactNameController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();
    if (contactName.isEmpty || contactPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập thông tin liên hệ')),
      );
      return;
    }

    // Lấy userId của user hiện tại
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Kiểm tra xem user đã đăng nhập chưa
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt phòng')),
      );
      return;
    }

    // Kiểm tra xem user có phải là khách (guest) không
    // Khách không được phép đặt phòng, phải đăng nhập bằng tài khoản thật
    final authService = AuthService();
    if (authService.isGuestUser()) {
      // Hiển thị dialog yêu cầu đăng nhập
      _showGuestLoginRequiredDialog();
      return;
    }

    // Tính toán giá và thông tin
    final nights = _calculateNights();
    final basePrice = _calculateBasePrice(nights);
    final extraGuestFee = _calculateExtraGuestFee(nights);
    final totalPrice = basePrice + extraGuestFee;

    // Hiển thị dialog xác nhận thanh toán
    _showPaymentConfirmationDialog(
      userId: userId,
      nights: nights,
      basePrice: basePrice,
      extraGuestFee: extraGuestFee,
      totalPrice: totalPrice,
      contactName: contactName,
      contactPhone: contactPhone,
    );
  }

  void _showPaymentConfirmationDialog({
    required String userId,
    required int nights,
    required double basePrice,
    required double extraGuestFee,
    required double totalPrice,
    required String contactName,
    required String contactPhone,
  }) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.payment, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingS),
              const Text('Xác nhận thanh toán'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                _buildInfoRow('Số phòng:', '$_roomCount phòng'),
                _buildInfoRow('Số đêm:', '$nights đêm'),
                _buildInfoRow(
                  'Khách:',
                  '$_adultCount người lớn, $_childCount trẻ em',
                ),
                const SizedBox(height: AppSizes.paddingS),
                const Divider(),
                const SizedBox(height: AppSizes.paddingS),
                _buildInfoRow('Giá phòng:', currencyFormat.format(basePrice)),
                if (extraGuestFee > 0)
                  _buildInfoRow(
                    'Phụ thu khách:',
                    currencyFormat.format(extraGuestFee),
                  ),
                const SizedBox(height: AppSizes.paddingS),
                const Divider(thickness: 2),
                const SizedBox(height: AppSizes.paddingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _processPayment(
                  userId: userId,
                  nights: nights,
                  basePrice: basePrice,
                  extraGuestFee: extraGuestFee,
                  totalPrice: totalPrice,
                  contactName: contactName,
                  contactPhone: contactPhone,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thanh toán'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _processPayment({
    required String userId,
    required int nights,
    required double basePrice,
    required double extraGuestFee,
    required double totalPrice,
    required String contactName,
    required String contactPhone,
  }) async {
    setState(() => _isBooking = true);

    try {
      final specialRequests = _specialRequestController.text.trim();
      final additionalInfo = <String, dynamic>{
        'contactName': contactName,
        'contactPhone': contactPhone,
        'roomCount': _roomCount,
        'adultCount': _adultCount,
        'childCount': _childCount,
        'totalGuests': _totalGuests,
        'nights': nights,
        'pricePerNight': widget.hotel.pricePerNight,
        'basePrice': basePrice,
        'extraGuestFee': extraGuestFee,
        'extraAdultFee': _extraAdultFee,
        'extraChildFee': _extraChildFee,
        'maxGuestsPerRoom': _maxGuestsPerRoom,
        'baseAdultsPerRoom': _baseAdultsPerRoom,
        'baseChildrenPerRoom': _baseChildrenPerRoom,
      };

      final booking = Booking(
        id: '',
        userId: userId,
        type: BookingType.hotel,
        itemId: widget.hotel.id,
        itemName: widget.hotel.name,
        bookingDate: DateTime.now(),
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        numberOfGuests: _totalGuests,
        totalPrice: totalPrice,
        status: BookingStatus.confirmed,
        specialRequests: specialRequests.isEmpty ? null : specialRequests,
        additionalInfo: additionalInfo,
      );

      // Hiển thị loading indicator đẹp với EasyLoading
      EasyLoading.show(
        status: 'Đang xử lý thanh toán...',
        maskType: EasyLoadingMaskType.black,
      );

      // Tạo booking trong Firestore
      await _firestoreService.createBooking(booking);

      // Giảm số phòng trống
      await _firestoreService.updateHotelAvailableRooms(
        widget.hotel.id,
        _roomCount,
      );

      // Dismiss loading
      EasyLoading.dismiss();

      // Hiển thị dialog thành công
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      // Dismiss loading nếu có lỗi
      EasyLoading.dismiss();

      if (mounted) {
        // Hiển thị toast lỗi thay vì SnackBar
        Fluttertoast.showToast(
          msg: "Đặt phòng thất bại, vui lòng thử lại",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  /// Hiển thị dialog đặt phòng thành công.
  ///
  /// Sử dụng BookingSuccessDialog widget.
  /// Sau khi bấm Hoàn tất sẽ quay về trang danh sách khách sạn.
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BookingSuccessDialog(
        hotelName: widget.hotel.name,
        screenContext:
            context, // Truyền context screen để navigation về danh sách
      ),
    );
  }

  int _calculateNights() {
    if (_checkInDate == null || _checkOutDate == null) {
      return 0;
    }

    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    return nights <= 0 ? 1 : nights;
  }

  int get _totalGuests => _adultCount + _childCount;

  int get _maxGuests => _roomCount * _maxGuestsPerRoom;

  int get _includedAdults => _roomCount * _baseAdultsPerRoom;

  int get _includedChildren => _roomCount * _baseChildrenPerRoom;

  int get _extraAdults => max(0, _adultCount - _includedAdults);

  int get _extraChildren => max(0, _childCount - _includedChildren);

  double _calculateBasePrice(int nights) {
    if (nights == 0) {
      return 0;
    }
    return nights * widget.hotel.pricePerNight * _roomCount;
  }

  double _calculateExtraGuestFee(int nights) {
    if (nights == 0) {
      return 0;
    }
    final extraFee =
        (_extraAdults * _extraAdultFee) + (_extraChildren * _extraChildFee);
    return extraFee * nights;
  }

  void _ensureGuestLimit() {
    while (_totalGuests > _maxGuests && _childCount > 0) {
      _childCount--;
    }
    while (_totalGuests > _maxGuests && _adultCount > 1) {
      _adultCount--;
    }
    if (_adultCount < 1) {
      _adultCount = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final nights = _calculateNights();
    final basePrice = _calculateBasePrice(nights);
    final extraGuestFee = _calculateExtraGuestFee(nights);
    final totalPrice = basePrice + extraGuestFee;
    final maxRooms = widget.hotel.availableRooms > 0
        ? widget.hotel.availableRooms
        : 1;
    final roomSubtitle = widget.hotel.availableRooms > 0
        ? 'Còn ${widget.hotel.availableRooms} phòng trống'
        : 'Hết phòng';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header với Carousel Slider cho gallery ảnh
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent, // Bỏ màu xanh dư dưới ảnh
            foregroundColor: Colors.white, // Icon back button màu trắng
            elevation: 0, // Bỏ shadow
            flexibleSpace: FlexibleSpaceBar(
              background: widget.hotel.imageUrls.isNotEmpty
                  ? Stack(
                      children: [
                        // Carousel Slider cho nhiều ảnh
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 300,
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                            autoPlay: true, // Tự động chạy
                            autoPlayInterval:
                                AppDurations.carouselAutoPlayInterval,
                            autoPlayAnimationDuration:
                                AppDurations.carouselAnimationDuration,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            onPageChanged: (index, reason) {
                              // Cập nhật vị trí hiện tại của slider
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                          ),
                          items: widget.hotel.imageUrls.map((url) {
                            return Builder(
                              builder: (BuildContext context) {
                                return CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.border,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: AppColors.border,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: AppSizes.iconXL * 2,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                );
                              },
                            );
                          }).toList(),
                        ),

                        // Label số ảnh (giữ lại, bỏ indicators)
                        Positioned(
                          top: 50,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${widget.hotel.imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppColors.border,
                      child: const Icon(
                        Icons.hotel,
                        size: AppSizes.iconXL * 2,
                        color: AppColors.textHint,
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name
                  Text(
                    widget.hotel.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Location với nút xem bản đồ
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: AppSizes.iconM,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: Text(
                          '${widget.hotel.address}, ${widget.hotel.city}, ${widget.hotel.country}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Nút xem bản đồ
                  OutlinedButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Xem bản đồ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: widget.hotel.rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: AppColors.warning),
                        itemCount: 5,
                        itemSize: AppSizes.iconM,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        '${widget.hotel.rating} (${widget.hotel.reviewCount} đánh giá)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Price
                  Row(
                    children: [
                      Text(
                        currencyFormat.format(widget.hotel.pricePerNight),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        ' / đêm',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Description
                  Text('Mô tả', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    widget.hotel.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Amenities
                  Text(
                    AppStrings.amenities,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Wrap(
                    spacing: AppSizes.paddingS,
                    runSpacing: AppSizes.paddingS,
                    children: widget.hotel.amenities.map((amenity) {
                      return Chip(
                        label: Text(amenity),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Booking section
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingL),
                  Text(
                    'Đặt phòng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Check-in date
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text(AppStrings.checkIn),
                    subtitle: Text(
                      _checkInDate != null
                          ? dateFormat.format(_checkInDate!)
                          : 'Chọn ngày',
                    ),
                    onTap: _selectCheckInDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Check-out date
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text(AppStrings.checkOut),
                    subtitle: Text(
                      _checkOutDate != null
                          ? dateFormat.format(_checkOutDate!)
                          : 'Chọn ngày',
                    ),
                    onTap: _selectCheckOutDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Number of guests
                  CounterTile(
                    icon: Icons.meeting_room_outlined,
                    title: 'Số phòng',
                    subtitle: roomSubtitle,
                    value: _roomCount,
                    onRemove: _roomCount > 1
                        ? () {
                            setState(() {
                              _roomCount--;
                              _ensureGuestLimit();
                            });
                          }
                        : null,
                    onAdd: _roomCount < maxRooms
                        ? () {
                            setState(() {
                              _roomCount++;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  CounterTile(
                    icon: Icons.person,
                    title: 'Người lớn',
                    subtitle: 'Giá gồm $_baseAdultsPerRoom người lớn/phòng',
                    value: _adultCount,
                    onRemove: _adultCount > 1
                        ? () {
                            setState(() {
                              _adultCount--;
                            });
                          }
                        : null,
                    onAdd: _totalGuests < _maxGuests
                        ? () {
                            setState(() {
                              _adultCount++;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  CounterTile(
                    icon: Icons.child_care,
                    title: 'Trẻ em',
                    subtitle: 'Miễn phí $_baseChildrenPerRoom trẻ em/phòng',
                    value: _childCount,
                    onRemove: _childCount > 0
                        ? () {
                            setState(() {
                              _childCount--;
                            });
                          }
                        : null,
                    onAdd: _totalGuests < _maxGuests
                        ? () {
                            setState(() {
                              _childCount++;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng khách: $_totalGuests',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Tối đa $_maxGuests',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quy trình đặt phòng',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.paddingXS),
                        Text(
                          '- Giá tính theo số phòng và số đêm',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        Text(
                          '- Mỗi phòng gồm $_baseAdultsPerRoom người lớn và $_baseChildrenPerRoom trẻ em miễn phí',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        Text(
                          '- Vượt quá sẽ tính phụ thu theo đêm',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  if (nights > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng giá ($nights đêm)',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: AppSizes.paddingXS),
                              Text(
                                'Phòng: ${currencyFormat.format(basePrice)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (extraGuestFee > 0)
                                Text(
                                  'Phụ thu khách: ${currencyFormat.format(extraGuestFee)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          Text(
                            currencyFormat.format(totalPrice),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                  ],

                  TextField(
                    controller: _contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên liên hệ',
                      hintText: 'Nhập họ tên người đặt phòng',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  TextField(
                    controller: _contactPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      hintText: 'Ví dụ: 0901 234 567',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  TextField(
                    controller: _specialRequestController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Yêu cầu đặc biệt',
                      hintText: 'Ví dụ: phòng view biển, giường đôi...',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Book button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightM,
                    child: ElevatedButton(
                      onPressed: _isBooking ? null : _bookHotel,
                      child: _isBooking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.bookNow),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
