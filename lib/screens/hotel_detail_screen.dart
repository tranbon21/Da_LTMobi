import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/hotel_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  bool _isBooking = false;

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

    setState(() => _isBooking = true);

    // TODO: Implement booking logic here
    // 1. Get current user ID
    // 2. Create booking object
    // 3. Save to database
    // 4. Show success message

    // Simulate booking delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TODO: Implement booking logic'),
          backgroundColor: AppColors.warning,
        ),
      );
      setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy');

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
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text(AppStrings.guests),
                    subtitle: Text('$_numberOfGuests khách'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _numberOfGuests > 1
                              ? () => setState(() => _numberOfGuests--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _numberOfGuests++),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Book button
                  CustomButton(
                    text: AppStrings.bookNow,
                    onPressed: _bookHotel,
                    isLoading: _isBooking,
                    icon: Icons.check_circle,
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
