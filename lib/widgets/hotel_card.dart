import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/hotel_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;

  const HotelCard({super.key, required this.hotel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel image
            SizedBox(
              height: AppSizes.imageCard,
              width: double.infinity,
              child: hotel.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: hotel.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.border,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.border,
                        child: const Icon(
                          Icons.hotel,
                          size: AppSizes.iconXL,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.border,
                      child: const Icon(
                        Icons.hotel,
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
                  // Hotel name
                  Text(
                    hotel.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Location
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
                          '${hotel.city}, ${hotel.country}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: hotel.rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: AppColors.warning),
                        itemCount: 5,
                        itemSize: AppSizes.iconS,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        '${hotel.rating} (${hotel.reviewCount} đánh giá)',
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
                            currencyFormat.format(hotel.pricePerNight),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'mỗi đêm',
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
                          color: hotel.availableRooms > 0
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Text(
                          hotel.availableRooms > 0
                              ? '${hotel.availableRooms} phòng trống'
                              : 'Hết phòng',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: hotel.availableRooms > 0
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
