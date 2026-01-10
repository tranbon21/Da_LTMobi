import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_model.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class TourDetailScreen extends StatefulWidget {
  final Tour tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  int _numberOfGuests = 1;
  bool _isBooking = false;

  Future<void> _bookTour() async {
    // Kiểm tra tour còn chỗ không
    if (!widget.tour.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tour đã hết chỗ')),
      );
      return;
    }

    // Kiểm tra số người không vượt quá số chỗ còn lại
    if (_numberOfGuests > (widget.tour.maxParticipants - widget.tour.currentParticipants)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số người vượt quá số chỗ còn lại')),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      // 1. Lấy user ID hiện tại
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        // Chưa đăng nhập
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để đặt tour')),
          );
          setState(() => _isBooking = false);
        }
        return;
      }

      // 2. Tạo Booking object
      final booking = Booking(
        id: '', // Firestore sẽ tự tạo ID
        userId: userId,
        type: BookingType.tour,
        itemId: widget.tour.id,
        itemName: widget.tour.name,
        bookingDate: DateTime.now(),
        checkInDate: widget.tour.startDate, // Ngày bắt đầu tour
        checkOutDate: widget.tour.endDate, // Ngày kết thúc tour
        numberOfGuests: _numberOfGuests,
        totalPrice: widget.tour.price * _numberOfGuests,
        status: BookingStatus.pending, // Pending - chờ xác nhận
        specialRequests: null,
        additionalInfo: {
          'tourGuide': widget.tour.tourGuide,
          'destination': widget.tour.destination,
        },
      );

      // 3. Lưu vào Firestore
      await FirestoreService().createBooking(booking);

      // 4. Hiển thị dialog thành công
      if (mounted) {
        setState(() => _isBooking = false);
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.check_circle, color: AppColors.success, size: 40),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  const Text(
                    'Đặt tour thành công!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.tour, 'Tour', widget.tour.name, AppColors.primary),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.people, 'Số người', '$_numberOfGuests người', AppColors.primary),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.payments, 
                          'Tổng tiền',
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(booking.totalPrice),
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pending_actions, size: 16, color: AppColors.warning),
                        SizedBox(width: 6),
                        Text('Chờ xác nhận', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Xem booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      if (mounted) {
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
              background: widget.tour.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.tour.imageUrls.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.border,
                      child: const Icon(
                        Icons.tour,
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
                  // Tour name
                  Text(
                    widget.tour.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Destination
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
                          '${widget.tour.destination}, ${widget.tour.country}',
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
                        rating: widget.tour.rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: AppColors.warning),
                        itemCount: 5,
                        itemSize: AppSizes.iconM,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        '${widget.tour.rating} (${widget.tour.reviewCount} đánh giá)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Price
                  Row(
                    children: [
                      Text(
                        currencyFormat.format(widget.tour.price),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        ' / người',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Tour info
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.schedule,
                          title: 'Thời gian',
                          value: '${widget.tour.duration} ngày',
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.people,
                          title: 'Còn lại',
                          value:
                              '${widget.tour.maxParticipants - widget.tour.currentParticipants} chỗ',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Dates
                  _InfoCard(
                    icon: Icons.calendar_today,
                    title: 'Ngày khởi hành',
                    value:
                        '${dateFormat.format(widget.tour.startDate)} - ${dateFormat.format(widget.tour.endDate)}',
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Tour guide
                  _InfoCard(
                    icon: Icons.person,
                    title: AppStrings.tourGuide,
                    value: widget.tour.tourGuide,
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Description
                  Text('Mô tả', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    widget.tour.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Highlights
                  Text(
                    AppStrings.highlights,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  ...widget.tour.highlights.map((highlight) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: AppSizes.iconM,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          Expanded(
                            child: Text(
                              highlight,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: AppSizes.paddingL),

                  // Booking section
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingL),
                  Text(
                    'Đặt tour',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Number of guests
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Số người tham gia'),
                    subtitle: Text('$_numberOfGuests người'),
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
                          onPressed:
                              _numberOfGuests <
                                  (widget.tour.maxParticipants -
                                      widget.tour.currentParticipants)
                              ? () => setState(() => _numberOfGuests++)
                              : null,
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Total price
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng tiền:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          currencyFormat.format(
                            widget.tour.price * _numberOfGuests,
                          ),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Book button
                  CustomButton(
                    text: AppStrings.bookNow,
                    onPressed: widget.tour.isAvailable ? _bookTour : () {},
                    isLoading: _isBooking,
                    icon: Icons.check_circle,
                    backgroundColor: widget.tour.isAvailable
                        ? null
                        : AppColors.textHint,
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

  // Helper method để build info row
  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: AppSizes.iconM),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSizes.paddingXS),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
