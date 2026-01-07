import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'hotels_screen.dart';
import 'tours_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import '../models/hotel_model.dart';
import '../models/promotion_model.dart';
import '../services/promotion_service.dart';
import '../services/hotel_service.dart';
import 'hotel_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _servicePageController;
  int _currentServicePage = 0;
  final int _servicePageCount = 2;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const HotelsScreen(),
    const ToursScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _servicePageController = PageController();
  }

  @override
  void dispose() {
    _servicePageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 29, 87, 202),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: AppStrings.hotels,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tour),
            label: AppStrings.tours,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: AppStrings.bookings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  PageController? _servicePageController;
  int _currentServicePage = 0;
  final int _servicePageCount = 2;
  final Map<String, Promotion> _promotionMap = {};
  final PromotionService _promotionService = PromotionService();
  
  // KHAI BÁO CÁC BIẾN CẦN THIẾT
  List<Hotel> _promotedHotels = [];
  bool _isLoadingPromotions = true;

  @override
  void initState() {
    super.initState();
    _servicePageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    _loadPromotedHotels();
    _loadPromotions();
  });
  }

  @override
  void dispose() {
    _servicePageController?.dispose();
    super.dispose();
  }
  
  Future<void> _loadPromotedHotels() async {
    try {
      setState(() {
        _isLoadingPromotions = true;
      });

      final hotelService = HotelService();
      
      // PHƯƠNG THỨC 1: Chỉ lấy hotels (đơn giản)
      final promotedHotels = await hotelService.getPromotedHotels().first;
      
      // HOẶC PHƯƠNG THỨC 2: Lấy với thông tin chi tiết
      // final hotelsWithPromos = await hotelService.getHotelsWithPromotions().first;
      // final promotedHotels = hotelsWithPromos.map((item) => item['hotel'] as Hotel).toList();
      
      setState(() {
        _promotedHotels = promotedHotels;
        _isLoadingPromotions = false;
      });
      
      // DEBUG
      print('✅ Loaded ${promotedHotels.length} promoted hotels');
      for (final hotel in promotedHotels.take(3)) {
        print('  - ${hotel.name} (ID: ${hotel.id})');
      }
      
    } catch (error) {
      print('❌ Error loading promoted hotels: $error');
      setState(() {
        _promotedHotels = [];
        _isLoadingPromotions = false;
      });
    }
  }

  Future<void> _loadPromotions() async {
    try {
      print('🔄 Loading promotions...');
      
      // Lấy tất cả promotions từ Firestore
      final promotions = await _promotionService.getAllPromotions().first;
      
      print('✅ Found ${promotions.length} valid promotions');
      
      // Tạo map hotelId -> Promotion
      final Map<String, Promotion> newMap = {};
      for (final promotion in promotions) {
        newMap[promotion.hotelId] = promotion;
        print('   - Hotel ${promotion.hotelId}: ${promotion.discountPercentage}% off');
      }
      
      setState(() {
        _promotionMap.clear();
        _promotionMap.addAll(newMap);
      });
      
    } catch (error) {
      print('❌ Error loading promotions: $error');
    }
  }
  
  // THÊM PHƯƠNG THỨC: Lấy promotion của hotel
  Promotion? _getPromotionForHotel(Hotel hotel) {
    return _promotionMap[hotel.id];
  }
  
  // THÊM PHƯƠNG THỨC: Kiểm tra có khuyến mại
  bool _hasPromotion(Hotel hotel) {
    final promotion = _getPromotionForHotel(hotel);
    return promotion != null && promotion.isValid;
  }
  
  // THÊM PHƯƠNG THỨC: Tính giá khuyến mại
  double _getPromotionalPrice(Hotel hotel) {
    final promotion = _getPromotionForHotel(hotel);
    if (promotion == null || !promotion.isValid) {
      return hotel.pricePerNight;
    }
    return promotion.calculateFinalPrice(hotel.pricePerNight);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // NỘI DUNG CUỘN (KHÔNG GHIM)
          SingleChildScrollView(
            child: Column(
              children: [
                // KHOẢNG TRỐNG BẰNG CHIỀU CAO HEADER
                Container(
                  height: 130, // Chiều cao header
                  color: const Color(0xFF5B8DEF),
                ),
                
                // SERVICE MENU
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: _buildServiceMenu(context),
                ),
                const SizedBox(height: 8),
                
                // NỘI DUNG CHÍNH
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [                   
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      _buildPromotionList(),
                      const SizedBox(height: 24),
                      _buildViewMoreButton(),
                      const SizedBox(height: 8),
                      _buildDealTitle1(),
                      const SizedBox(height: 16),
                      _buildDealGrid(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // HEADER GHIM CỐ ĐỊNH Ở TRÊN
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF5B8DEF),
              child: _buildHeader(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 34),
    decoration: const BoxDecoration(
      color: Color(0xFF5B8DEF),
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(24),
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            // SEARCH BAR - CLICKABLE
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to hotels tab
                  if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                    context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                      context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 1;
                    });
                  }
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Tìm kiếm khách sạn...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildHeaderIcon(Icons.chat_bubble_outline),
            const SizedBox(width: 8),
            _buildHeaderIcon(Icons.notifications_none),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.black,
      ),
    );
  }

  Widget _buildServiceMenu(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20), // kéo lên đè header
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: PageView(
                controller: _servicePageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentServicePage = index;
                  });
                },
                children: [
                  _servicePage([
                    _serviceItem(Icons.hotel, 'Tìm\nKhách Sạn', () {
                      if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                        context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                          context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 1;
                        });
                      }
                    }),
                    _serviceItem(Icons.travel_explore, 'Hoạt Động\nDu Lịch', () {
                      if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                        context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                          context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 2;
                        });
                      }
                    }),
                    _serviceItem(Icons.directions_bus, 'Dịch Vụ\nĐưa Đón', () {}),
                    _serviceItem(Icons.card_giftcard, 'Phiếu Quà\nTặng', () {}),
                  ]),
                  _servicePage([
                    _serviceItem(Icons.flight, 'Vé\nMáy Bay', () {}),
                    _serviceItem(Icons.map, 'Bản Đồ\nDu Lịch', () {}),
                    _serviceItem(Icons.restaurant, 'Ẩm\nThực', () {}),
                    _serviceItem(Icons.more_horiz, 'Xem\nThêm', () {}),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildDots(),
          ],
        ),
      ),
    );
  }

  Widget _serviceItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              icon,
              color: const Color(0xFF5B8DEF),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicePage(List<Widget> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items,
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _servicePageCount,
        (index) => _buildDot(isActive: index == _currentServicePage),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 10 : 6,
      height: isActive ? 10 : 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF5B8DEF) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Gói Chào Mừng Người Dùng Mới!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 2,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _welcomeCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8D9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_bus, color: Colors.blue),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giảm Vé Xe Đến 250K VND',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dành Cho 🚗 ✈️ 🚆 +2',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.error_outline, color: Colors.red),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            '-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - ',
            style: TextStyle(
              fontSize: 12,
              height: 0,
              color: Color.fromARGB(255, 66, 144, 69),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhận thêm ưu đãi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.4,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        color: const Color.fromARGB(255, 142, 223, 50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DEF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                ),
                onPressed: () {},
                child: const Text('Nhận'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ưu đãi hấp dẫn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _promoCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _promoCard() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFECEFF5),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Giảm đến 30%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Khách sạn & Resort',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 228, 111, 44),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Xem Thêm Ưu Đãi Dành Cho Bạn',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 17, 17, 17),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDealTitle1() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Khách Sạn Đang Khuyến Mại',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!_isLoadingPromotions)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _loadPromotedHotels,
              tooltip: 'Làm mới',
            ),
        ],
      ),
    );
  }

  Widget _buildDealGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _isLoadingPromotions
          ? _buildLoadingGrid()
          : _promotedHotels.isEmpty
              ? _buildEmptyPromotions()
              : _buildPromotedHotelsGrid(),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        return _buildLoadingCard();
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.grey[200],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPromotions() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Hiện không có khuyến mại',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quay lại sau nhé!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotedHotelsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _promotedHotels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final hotel = _promotedHotels[index];
        return _buildPromotedHotelCard(hotel);
      },
    );
  }

  Widget _buildPromotedHotelCard(Hotel hotel) {
    final promotion = _getPromotionForHotel(hotel);
    final hasPromotion = promotion != null && promotion.isValid;
    final originalPrice = hotel.pricePerNight;
    final promoPrice = hasPromotion 
        ? promotion!.calculateFinalPrice(originalPrice)
        : originalPrice;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotel: hotel),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ẢNH - 2/3 chiều cao
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFF5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      image: hotel.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(hotel.imageUrls.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: hotel.imageUrls.isEmpty
                        ? const Center(
                            child: Icon(Icons.hotel, size: 36, color: Colors.grey),
                          )
                        : null,
                  ),
                  // BADGE - FIXED POSITION
                  if (hasPromotion)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 50, // GIỚI HẠN CHIỀU RỘNG
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,  // GIẢM PADDING
                          vertical: 3,    // GIẢM PADDING
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FittedBox(  // THÊM FittedBox
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '-${promotion!.discountPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,  // GIẢM FONT SIZE
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // THÔNG TIN - 1/3 chiều cao
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // PHÂN BỐ ĐỀU
                  children: [
                    // TÊN KHÁCH SẠN - FIX OVERFLOW
                    Flexible(
                      child: Text(
                        hotel.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,  // GIẢM FONT SIZE
                        ),
                        maxLines: 2,  // CHO PHÉP 2 DÒNG
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // THÀNH PHỐ
                    Text(
                      hotel.city,
                      style: const TextStyle(
                        fontSize: 10,  // GIẢM FONT SIZE
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // GIÁ - FIXED HEIGHT CONTAINER
                    Container(
                      height: 34,  // CỐ ĐỊNH CHIỀU CAO
                      child: hasPromotion
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // GIÁ GỐC
                                Text(
                                  '${originalPrice.toStringAsFixed(0)}₫',
                                  style: const TextStyle(
                                    fontSize: 10,  // GIẢM FONT SIZE
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // GIÁ KHUYẾN MÃI
                                Text(
                                  '${promoPrice.toStringAsFixed(0)}₫/đêm',
                                  style: const TextStyle(
                                    fontSize: 12,  // GIẢM FONT SIZE
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          : // GIÁ THƯỜNG
                            Text(
                              '${originalPrice.toStringAsFixed(0)}₫/đêm',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}