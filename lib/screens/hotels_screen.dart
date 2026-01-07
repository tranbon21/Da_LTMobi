import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Local imports
import '../models/hotel_model.dart';
import '../services/hotel_service.dart';
import '../utils/constants.dart';
import '../widgets/hotel_card.dart';
import '../widgets/hotel_card_shimmer.dart';
import '../widgets/price_filter_dialog.dart';
import 'hotel_detail_screen.dart';

/// Màn hình danh sách khách sạn.
/// 
/// Hiển thị danh sách tất cả khách sạn từ Firebase với các chức năng:
/// - Tìm kiếm theo tên khách sạn hoặc thành phố
/// - Lọc theo giá tối đa
/// - Sắp xếp theo rating (cao xuống thấp)
/// - Shimmer loading skeleton khi đang tải
/// - Navigation đến màn hình chi tiết khách sạn
class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _HotelsViewModel(),
      child: Navigator(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Route đến màn hình chi tiết khách sạn
          if (settings.name == HotelDetailScreen.routeName) {
            final hotel = settings.arguments as Hotel;
            return MaterialPageRoute(
              builder: (_) => HotelDetailScreen(hotel: hotel),
              settings: settings,
            );
          }
          // Route mặc định: màn hình danh sách
          return MaterialPageRoute(
            builder: (_) => const _HotelsListView(),
            settings: settings,
          );
        },
      ),
    );
  }
}

/// ViewModel quản lý state và logic nghiệp vụ cho màn hình Hotels.
/// 
/// Chức năng:
/// - Lấy danh sách hotels từ Firebase qua HotelService
/// - Lọc theo search query (tên hoặc thành phố)
/// - Lọc theo giá tối đa
class _HotelsViewModel extends ChangeNotifier {
  final HotelService _service;
  String _searchQuery = '';
  double? _maxPrice;

  _HotelsViewModel({HotelService? service})
      : _service = service ?? HotelService();

  // Getters
  String get searchQuery => _searchQuery;
  double? get maxPrice => _maxPrice;

  /// Stream danh sách hotels đã được lọc
  Stream<List<Hotel>> get hotelsStream => _service.getHotels().map((hotels) {
        // Lọc theo search query
        final query = _searchQuery.trim().toLowerCase();
        final filtered = hotels.where((hotel) {
          final matchesQuery = query.isEmpty ||
              hotel.name.toLowerCase().contains(query) ||
              hotel.city.toLowerCase().contains(query);
          final matchesPrice =
              _maxPrice == null || hotel.pricePerNight <= _maxPrice!;
          return matchesQuery && matchesPrice;
        }).toList();

        return filtered;
      });

  /// Cập nhật search query
  void updateSearch(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }

  /// Cập nhật giá tối đa để lọc
  void updateMaxPrice(double? value) {
    _maxPrice = value;
    notifyListeners();
  }

  /// Xóa tất cả bộ lọc về mặc định
  void clearFilters() {
    _maxPrice = null;
    notifyListeners();
  }
}

/// Widget hiển thị danh sách khách sạn với search bar và filter
class _HotelsListView extends StatefulWidget {
  const _HotelsListView();

  @override
  State<_HotelsListView> createState() => _HotelsListViewState();
}

class _HotelsListViewState extends State<_HotelsListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Xóa search query và reset search field
  void _clearSearch(_HotelsViewModel viewModel) {
    _searchController.clear();
    viewModel.updateSearch('');
  }

  /// Mở dialog lọc theo giá tối đa
  Future<void> _openPriceFilter(_HotelsViewModel viewModel) async {
    final result = await showDialog<double?>(
      context: context,
      builder: (context) => PriceFilterDialog(
        currentMaxPrice: viewModel.maxPrice,
      ),
    );

    // Cập nhật filter nếu user chọn giá hoặc xóa filter
    if (result != null || result == null && viewModel.maxPrice != null) {
      viewModel.updateMaxPrice(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<_HotelsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.hotels),
      ),
      body: Column(
        children: [
          // Search bar và filter button
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                // Search TextField
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHotels,
                      labelText: 'Tên khách sạn hoặc thành phố',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: viewModel.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _clearSearch(viewModel),
                            )
                          : null,
                    ),
                    onChanged: viewModel.updateSearch,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                // Filter button - màu xanh khi có filter active
                Container(
                  decoration: BoxDecoration(
                    color: viewModel.maxPrice != null
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: viewModel.maxPrice != null
                          ? Colors.white
                          : AppColors.primary,
                    ),
                    onPressed: () => _openPriceFilter(viewModel),
                    tooltip: 'Lọc theo giá',
                  ),
                ),
              ],
            ),
          ),
          // Danh sách hotels
          Expanded(
            child: StreamBuilder<List<Hotel>>(
              stream: viewModel.hotelsStream,
              builder: (context, snapshot) {
                // Hiển thị shimmer loading khi đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) => const HotelCardShimmer(),
                  );
                }

                // Hiển thị error nếu có lỗi
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Có lỗi khi tải dữ liệu',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  );
                }

                // Hiển thị empty state nếu không có hotels
                final hotels = snapshot.data ?? [];
                if (hotels.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hotel_outlined,
                          size: AppSizes.iconXL * 2,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          'Không có khách sạn phù hợp',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        // Gợi ý xóa filter nếu đang có filter
                        if (viewModel.searchQuery.isNotEmpty ||
                            viewModel.maxPrice != null) ...[
                          const SizedBox(height: AppSizes.paddingM),
                          Text(
                            'Thử xóa bộ lọc để xem tất cả',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Hiển thị danh sách hotels
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingS,
                  ),
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
                    return HotelCard(
                      hotel: hotel,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          HotelDetailScreen.routeName,
                          arguments: hotel,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
