import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/tour_model.dart';
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
    if (!widget.tour.isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tour đã hết chỗ')));
      return;
    }

    setState(() => _isBooking = true);

    // TODO: Implement tour booking logic here
    // 1. Get current user ID
    // 2. Create booking object
    // 3. Save to database
    // 4. Show success message

    // Simulate booking delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TODO: Implement tour booking logic'),
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
                  }),
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
