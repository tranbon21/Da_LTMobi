// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import các constants của app (màu sắc, kích thước, strings)
import '../utils/constants.dart';
// Import models và services
import '../models/tour_model.dart';
import '../services/firestore_service.dart';
import 'tour_detail_screen.dart';

/// Màn hình Danh sách Tour Du lịch
///
/// Màn hình này hiển thị danh sách các tour du lịch từ Firebase
///
/// Các tính năng:
/// - Tìm kiếm tour theo điểm đến
/// - Hiển thị danh sách tour với ảnh, giá, rating
/// - Navigate đến màn hình chi tiết tour
class ToursScreen extends StatefulWidget {
  const ToursScreen({super.key});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  // ==================== CONTROLLERS ====================

  /// Controller cho TextField tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  // ==================== STATE ====================

  /// Chuỗi tìm kiếm điểm đến hiện tại
  String _searchDestination = '';

  // ==================== LIFECYCLE ====================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================== APP BAR ====================

      appBar: AppBar(
        title: const Text(AppStrings.tours),
      ),

      // ==================== BODY ====================

      body: Column(
        children: [
          // ==================== SEARCH BAR ====================

          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchTours,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchDestination.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchDestination = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchDestination = value;
                });
              },
            ),
          ),

          // ==================== TOURS LIST ====================

          Expanded(
            child: StreamBuilder<List<Tour>>(
              stream: FirestoreService().getTours(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          'Có lỗi xảy ra: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Get tours from snapshot
                List<Tour> tours = snapshot.data ?? [];

                // Filter tours based on search query
                if (_searchDestination.isNotEmpty) {
                  final query = _searchDestination.toLowerCase().trim();
                  tours = tours.where((tour) {
                    return tour.destination.toLowerCase().contains(query) ||
                        tour.name.toLowerCase().contains(query);
                  }).toList();
                }

                // Empty state
                if (tours.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.tour_outlined,
                          size: AppSizes.iconXL * 2,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          _searchDestination.isEmpty
                              ? 'Chưa có tour nào'
                              : 'Không tìm thấy tour phù hợp',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        if (_searchDestination.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.paddingS),
                          Text(
                            'Thử tìm kiếm với từ khóa khác',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textHint,
                                ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Tours list
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: tours.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSizes.paddingM),
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    return _buildTourCard(tour);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build tour card widget
  Widget _buildTourCard(Tour tour) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () {
          // Navigate to tour detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TourDetailScreen(tour: tour),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour image (if available)
            if (tour.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusM),
                ),
                child: Image.network(
                  tour.imageUrls.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                ),
              )
            else
              _buildPlaceholderImage(),

            // Tour info
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tour name
                  Text(
                    tour.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Destination
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.destination,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Duration
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tour.duration} ngày',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Price and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '${tour.price.toStringAsFixed(0).replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )} ₫',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tour.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
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

  /// Build placeholder image when no image is available
  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusM),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.tour,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }
}
