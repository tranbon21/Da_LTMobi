import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

/// Widget hiển thị shimmer loading skeleton cho hotel card
/// Sử dụng khi đang tải danh sách khách sạn từ Firebase
/// Layout giống y hệt HotelCard để consistent UX
class HotelCardShimmer extends StatelessWidget {
  const HotelCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer cho hotel image (giống HotelCard line 26-54)
            Container(
              height: AppSizes.imageCard, // 200px - giống với hotel card
              width: double.infinity,
              color: Colors.white,
            ),

            // Shimmer cho content (giống HotelCard line 56-160)
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer cho hotel name (giống line 62-67)
                  Container(
                    width: double.infinity,
                    height: 24, // titleLarge height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Shimmer cho location row (giống line 71-88)
                  Row(
                    children: [
                      Container(
                        width: AppSizes.iconS,
                        height: AppSizes.iconS,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      Container(
                        width: 150,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Shimmer cho rating row (giống line 92-108)
                  Row(
                    children: [
                      // Shimmer cho 5 ngôi sao
                      ...List.generate(5, (index) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Container(
                          width: AppSizes.iconS,
                          height: AppSizes.iconS,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),
                      const SizedBox(width: AppSizes.paddingS),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Shimmer cho price & availability row (giống line 112-157)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shimmer cho price column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 20, // titleLarge price
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 12, // "mỗi đêm" text
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      // Shimmer cho availability badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Container(
                          width: 70,
                          height: 12,
                          color: Colors.white,
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
