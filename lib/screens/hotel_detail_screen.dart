import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/hotel_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class HotelDetailScreen extends StatefulWidget {
  static const String routeName = '/hotel-detail';
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _roomCount = 1;
  int _adultCount = 2;
  int _childCount = 0;
  bool _isBooking = false;
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController =
      TextEditingController();
  final TextEditingController _specialRequestController =
      TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
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

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày nhận phòng trước')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  Future<void> _bookHotel() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày nhận và trả phòng')),
      );
      return;
    }

    if (widget.hotel.availableRooms <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khách sạn đã hết phòng')),
      );
      return;
    }

    if (_adultCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần ít nhất 1 người lớn')),
      );
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

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt phòng')),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final nights = _calculateNights();
      final basePrice = _calculateBasePrice(nights);
      final extraGuestFee = _calculateExtraGuestFee(nights);
      final totalPrice = basePrice + extraGuestFee;
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
        status: BookingStatus.pending,
        specialRequests: specialRequests.isEmpty ? null : specialRequests,
        additionalInfo: additionalInfo,
      );

      await _firestoreService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt phòng thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt phòng thất bại, vui lòng thử lại'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
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
    final extraFee = (_extraAdults * _extraAdultFee) +
        (_extraChildren * _extraChildFee);
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

  Widget _buildCounterTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
    VoidCallback? onRemove,
    VoidCallback? onAdd,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onRemove,
          ),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: const BorderSide(color: AppColors.border),
      ),
    );
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
          // App bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.hotel.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.hotel.imageUrls.first,
                      fit: BoxFit.cover,
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

                  // Location
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
                  _buildCounterTile(
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
                  _buildCounterTile(
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
                  _buildCounterTile(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '- Mỗi phòng gồm $_baseAdultsPerRoom người lớn và $_baseChildrenPerRoom trẻ em miễn phí',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '- Vượt quá sẽ tính phụ thu theo đêm',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
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
