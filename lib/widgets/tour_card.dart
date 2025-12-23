import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tour_model.dart';

class TourCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback onTap;

  const TourCard({
    super.key,
    required this.tour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh tour (dùng ảnh local)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                tour.imageUrls.isNotEmpty
                    ? tour.imageUrls.first
                    : 'assets/images/tour_default.jpg',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.tour,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên tour
                  Text(
                    tour.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Địa điểm
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tour.destination,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Thời gian
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tour.duration} ngày • ${dateFormat.format(tour.startDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Đánh giá
                  Row(
                    children: [
                      _buildStarRating(tour.rating),
                      const SizedBox(width: 6),
                      Text(
                        '${tour.rating} (${tour.reviewCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Giá và chỗ trống
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(tour.price),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tour.isAvailable
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tour.isAvailable
                              ? '${tour.maxParticipants - tour.currentParticipants} chỗ'
                              : 'Hết chỗ',
                          style: TextStyle(
                            fontSize: 11,
                            color: tour.isAvailable
                                ? Colors.green[800]
                                : Colors.red[800],
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

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 14,
          color: index < rating.floor()
              ? Colors.orange
              : (index < rating ? Colors.orange : Colors.grey[300]),
        );
      }),
    );
  }
}