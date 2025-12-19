import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/tour_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class TourCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback onTap;

  const TourCard({super.key, required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour image
            SizedBox(
              height: AppSizes.imageCard,
              width: double.infinity,
              child: tour.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: tour.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.border,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.border,
                        child: const Icon(
                          Icons.tour,
                          size: AppSizes.iconXL,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.border,
                      child: const Icon(
                        Icons.tour,
                        size: AppSizes.iconXL,
                        color: AppColors.textHint,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tour name
                  Text(
                    tour.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Destination
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: AppSizes.iconS,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      Expanded(
                        child: Text(
                          '${tour.destination}, ${tour.country}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Duration and dates
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: AppSizes.iconS,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      Text(
                        '${tour.duration} ngày',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Text(
                        '${dateFormat.format(tour.startDate)} - ${dateFormat.format(tour.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: tour.rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: AppColors.warning),
                        itemCount: 5,
                        itemSize: AppSizes.iconS,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        '${tour.rating} (${tour.reviewCount} đánh giá)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Price and availability
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormat.format(tour.price),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'mỗi người',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: tour.isAvailable
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Text(
                          tour.isAvailable
                              ? '${tour.maxParticipants - tour.currentParticipants} chỗ trống'
                              : 'Hết chỗ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: tour.isAvailable
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
