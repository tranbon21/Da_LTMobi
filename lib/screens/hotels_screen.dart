import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Local imports
import '../models/hotel_model.dart';
import '../services/hotel_service.dart';
import '../utils/constants.dart';
import '../widgets/hotel_card.dart';
import '../widgets/hotel_card_shimmer.dart'; // Shimmer loading skeleton
import 'hotel_detail_screen.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _HotelsViewModel(),
      child: Navigator(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == HotelDetailScreen.routeName) {
            final hotel = settings.arguments as Hotel;
            return MaterialPageRoute(
              builder: (_) => HotelDetailScreen(hotel: hotel),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (_) => const _HotelsListView(),
            settings: settings,
          );
        },
      ),
    );
  }
}

class _HotelsViewModel extends ChangeNotifier {
  final HotelService _service;
  String _searchQuery = '';
  double? _maxPrice;
  bool _sortByRating = true;

  _HotelsViewModel({HotelService? service})
      : _service = service ?? HotelService();

  String get searchQuery => _searchQuery;
  double? get maxPrice => _maxPrice;
  bool get sortByRating => _sortByRating;

  Stream<List<Hotel>> get hotelsStream => _service.getHotels().map((hotels) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = hotels.where((hotel) {
      final matchesQuery = query.isEmpty ||
          hotel.name.toLowerCase().contains(query) ||
          hotel.city.toLowerCase().contains(query);
      final matchesPrice =
          _maxPrice == null || hotel.pricePerNight <= _maxPrice!;
      return matchesQuery && matchesPrice;
    }).toList();

    if (_sortByRating) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      filtered.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    }

    return filtered;
  });

  void updateSearch(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }

  void updateMaxPrice(double? value) {
    _maxPrice = value;
    notifyListeners();
  }

  void updateSortByRating(bool value) {
    _sortByRating = value;
    notifyListeners();
  }

  void clearFilters() {
    _maxPrice = null;
    _sortByRating = true;
    notifyListeners();
  }
}

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


  void _clearSearch(_HotelsViewModel viewModel) {
    _searchController.clear();
    viewModel.updateSearch('');
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
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
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
          Expanded(
            child: StreamBuilder<List<Hotel>>(
              stream: viewModel.hotelsStream,
              builder: (context, snapshot) {
                // Hiển thị shimmer loading skeleton khi đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    itemCount: 5, // Hiển thị 5 skeleton cards
                    itemBuilder: (context, index) {
                      return const HotelCardShimmer();
                    },
                  );
                }

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
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (viewModel.searchQuery.isNotEmpty ||
                            viewModel.maxPrice != null) ...[
                          const SizedBox(height: AppSizes.paddingM),
                          Text(
                            'Thu xoa bo loc de xem tat ca',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  );
                }

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
