// File: lib/screens/home_screen.dart

// Thêm các import sau vào đầu file (sau các import hiện có):
import '../models/user_promotion_model.dart';  // Thêm dòng này
import '../services/user_promotion_service.dart';  // Thêm dòng này
import '../services/auth_service.dart';  // Đảm bảo đã có
import 'package:provider/provider.dart';  // Đảm bảo đã có

// Các import hiện tại của bạn:
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
import 'promotions_screen.dart';
import 'notifications_screen.dart';
import 'package:intl/intl.dart';
import '../services/system_promotion_service.dart';

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
      top: false, // Cho phép background xanh kéo lên status bar
      bottom: false,
      child: Stack(
        children: [
          // NỘI DUNG CUỘN (KHÔNG GHIM)
          SingleChildScrollView(
            child: Column(
              children: [
                // KHOẢNG TRỐNG BẰNG CHIỀU CAO HEADER
                Container(
                  height: 130 + MediaQuery.of(context).padding.top, // Chiều cao header + status bar
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
                      // _buildPromotionList(),
                      // const SizedBox(height: 24),
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
  // Lấy chiều cao status bar
  final statusBarHeight = MediaQuery.of(context).padding.top;
  
  return Container(
    padding: EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 34),
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
            // Nút thông báo với badge động
            _buildNotificationButton(context),
          ],
        ),
      ],
    ),
  );
}

  /// ==========================================================================
  /// BUILD NOTIFICATION BUTTON VỚI BADGE ĐỘNG
  /// ==========================================================================
  /// 
  /// **Chức năng:**
  /// Tạo button thông báo ở header với badge hiển thị số thông báo chưa đọc
  /// Badge cập nhật REALTIME khi có thông báo mới
  /// 
  /// **Cách hoạt động:**
  /// 1. Check trạng thái đăng nhập của user
  ///    - Nếu chưa đăng nhập → Hiển thị icon đơn giản (không có badge)
  ///    - Nếu đã đăng nhập → Sử dụng StreamBuilder để lắng nghe thông báo
  /// 
  /// 2. StreamBuilder tự động cập nhật khi:
  ///    - Có thông báo mới được tạo
  ///    - User đánh dấu thông báo đã đọc
  ///    - User xóa thông báo
  /// 
  /// 3. Badge logic:
  ///    - Hiển thị số chính xác nếu <= 9 thông báo
  ///    - Hiển thị "9+" nếu > 9 thông báo
  ///    - Ẩn hoàn toàn nếu không có thông báo chưa đọc
  /// 
  /// **Firestore Query:**
  /// ```
  /// collection: 'user_notifications'
  /// where: userId == currentUser.uid
  /// where: read == false
  /// listen: snapshots() → real-time updates
  /// ```
  /// ==========================================================================
  Widget _buildNotificationButton(BuildContext context) {
    // ========================================================================
    // BƯỚC 1: LẤY THÔNG TIN USER HIỆN TẠI
    // ========================================================================
    // Provider.of<AuthService> để lấy service quản lý authentication
    // listen: true → Widget sẽ rebuild khi auth state thay đổi
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    
    // ========================================================================
    // BƯỚC 2: XỬ LÝ TRƯỜNG HỢP CHƯA ĐĂNG NHẬP
    // ========================================================================
    // Nếu user chưa đăng nhập hoặc đang dùng anonymous account
    // → Hiển thị icon notification đơn giản (không có badge)
    if (currentUser == null || currentUser.isAnonymous) {
      return GestureDetector(
        // Tap để mở màn hình thông báo
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            // Background trắng trong suốt 15%
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.notifications_none,     // Icon chuông outline
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    
    // ========================================================================
    // BƯỚC 3: XỬ LÝ TRƯỜNG HỢP ĐÃ ĐĂNG NHẬP - SỬ DỤNG STREAMBUILDER
    // ========================================================================
    // StreamBuilder lắng nghe Firebase Firestore realtime
    // Tự động rebuild widget khi data thay đổi
    return StreamBuilder<QuerySnapshot>(
      // ------------------------------------------------------------------------
      // STREAM: Lắng nghe collection 'user_notifications'
      // ------------------------------------------------------------------------
      stream: FirebaseFirestore.instance
          .collection('user_notifications')         // Collection chứa thông báo
          .where('userId', isEqualTo: currentUser.uid)  // Chỉ lấy thông báo của user này
          .where('read', isEqualTo: false)          // Chỉ lấy thông báo chưa đọc
          .snapshots(),                             // Lắng nghe realtime (không phải get 1 lần)
      
      // ------------------------------------------------------------------------
      // BUILDER: Xây dựng UI dựa trên snapshot data
      // ------------------------------------------------------------------------
      builder: (context, snapshot) {
        // Đếm số thông báo chưa đọc
        // snapshot.data?.docs.length: Số documents trong query result
        // ?? 0: Nếu null (đang loading hoặc lỗi) thì mặc định = 0
        final unreadCount = snapshot.data?.docs.length ?? 0;
        
        return GestureDetector(
          // Tap để navigate đến NotificationsScreen
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            // Stack để đặt badge lên trên icon
            child: Stack(
              children: [
                // Icon notification ở giữa
                const Center(
                  child: Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
                
                // ------------------------------------------------------------------
                // BADGE: Chỉ hiển thị khi có thông báo chưa đọc (unreadCount > 0)
                // ------------------------------------------------------------------
                if (unreadCount > 0)
                  Positioned(
                    top: 6,       // Cách top 6px
                    right: 6,     // Cách right 6px (góc trên bên phải)
                    child: Container(
                      padding: const EdgeInsets.all(4),     // Padding bên trong badge
                      decoration: const BoxDecoration(
                        color: Colors.red,                  // Màu đỏ nổi bật
                        shape: BoxShape.circle,             // Hình tròn
                      ),
                      // constraints để badge có kích thước tối thiểu
                      constraints: const BoxConstraints(
                        minWidth: 18,                       // Rộng tối thiểu 18px
                        minHeight: 18,                      // Cao tối thiểu 18px
                      ),
                      child: Center(
                        child: Text(
                          // Logic hiển thị số:
                          // - Nếu > 9: Hiển thị "9+"
                          // - Nếu <= 9: Hiển thị số chính xác
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
      child: Icon(icon, color: Colors.white),
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
                  _serviceItem(Icons.card_giftcard, 'Phiếu Quà\nTặng', () {
                    // CHUYỂN ĐẾN DANH SÁCH KHUYẾN MẠI
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PromotionsScreen(),
                      ),
                    );
                  }),
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
    )
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          // Thay đổi: trả về List thay vì Map
          future: _getAllWelcomePromotions(), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Không có ưu đãi chào mừng',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }
            
            final promotions = snapshot.data!;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: promotions.length, // Hiển thị tất cả ưu đãi
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _welcomeCard(promotions[index]); // Truyền từng promotion
              },
            );
          },
        ),
      ),
    ],
  );
}

// Hàm lấy tất cả ưu đãi
Future<List<Map<String, dynamic>>> _getAllWelcomePromotions() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('promotions_user')
        .get(); // BỎ điều kiện where để lấy TẤT CẢ
    
    print('📊 Total documents in promotions_user: ${querySnapshot.docs.length}');
    
    // In ra tất cả documents để debug
    for (var doc in querySnapshot.docs) {
      print('📄 Document ID: ${doc.id}, Data: ${doc.data()}');
    }
    
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  } catch (e) {
    print('❌ Error getting promotions: $e');
    return [];
  }
}

Widget _welcomeCard(Map<String, dynamic> promotion) {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final discountAmount = (promotion['discountAmount'] as num?)?.toDouble() ?? 0;
  final minOrderAmount = (promotion['minOrderAmount'] as num?)?.toDouble() ?? 0;
  
  return Container(
    width: 200, 
    height: 140, // Chiều cao cố định
    padding: const EdgeInsets.all(10), 
    decoration: BoxDecoration(
      color: const Color(0xFFF3F8D9),
      borderRadius: BorderRadius.circular(14), 
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4, 
          offset: const Offset(0, 3), 
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần trên: 60% chiều cao
        Expanded(
          flex: 6, // 6/10 = 60%
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40, 
                    width: 40,  
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10), 
                    ),
                    child: const Icon(
                      Icons.sell, 
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12), 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion['title'] ?? 'Ưu đãi chào mừng',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600, 
                            fontSize: 14, 
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3), 
                        Text(
                          promotion['description'] ?? 'Ưu đãi đặc biệt cho thành viên mới',
                          style: const TextStyle(
                            fontSize: 10, 
                            color: Colors.grey,
                            height: 1.2, 
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.error_outline, 
                    color: Colors.red,
                    size: 18, 
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Dòng kẻ: 10% chiều cao
        Expanded(
          flex: 1, // 1/10 = 10%
          child: Center(
            child: const Text(
              '-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - -',
              style: TextStyle(
                fontSize: 10, 
                height: 0,
                color: Color.fromARGB(255, 66, 144, 69),
              ),
            ),
          ),
        ),
        
        // Phần dưới: 30% chiều cao
        Expanded(
          flex: 3, // 3/10 = 30%
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhận ưu đãi ngay!',
                      style: TextStyle(
                        fontSize: 10, 
                        color: Color.fromARGB(255, 138, 180, 22),
                      ),
                    ),
                    const SizedBox(height: 4), 
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4), 
                      child: LinearProgressIndicator(
                        value: 0.4,
                        minHeight: 5, 
                        backgroundColor: Colors.grey.shade300,
                        color: const Color.fromARGB(255, 142, 223, 50),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // if (minOrderAmount > 0)
                    //   Text(
                    //     'Đơn tối thiểu: ${currencyFormat.format(minOrderAmount)}',
                    //     style: const TextStyle(
                    //       fontSize: 9, 
                    //       color: Colors.grey,
                    //     ),
                    //   ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DEF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _handleClaimWelcomePackage(promotion),
                child: const Text(
                  'Nhận',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Thêm hàm lấy dữ liệu từ Firebase
Future<Map<String, dynamic>?> _getWelcomePromotion() async {
  try {
    print('🔍 START: Testing Firestore connection for promotions_user...');
    
    // Test 1: Kiểm tra Firestore instance
    print('   Testing FirebaseFirestore.instance...');
    final firestore = FirebaseFirestore.instance;
    print('   ✅ FirebaseFirestore.instance created');
    
    // Test 2: Kiểm tra collection reference
    print('   Getting collection reference...');
    final collectionRef = firestore.collection('promotions_user');
    print('   ✅ Collection reference created');
    
    // Test 3: Thử đếm documents (có thể bị rules chặn)
    print('   Attempting to count documents...');
    try {
      final countQuery = await collectionRef.count().get();
      print('   ✅ Count query successful');
      print('   📊 Total documents in promotions_user: ${countQuery.count}');
    } catch (e) {
      print('   ⚠️ Count query failed (may be due to rules): $e');
    }
    
    // Test 4: Thử get document đầu tiên
    print('   Getting first document...');
    final snapshot = await collectionRef.limit(1).get();
    
    print('   ✅ Get query successful');
    print('   📄 Documents found: ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      print('   ⚠️ Collection promotions_user exists but is EMPTY');
      print('   ℹ️  Add at least one document to promotions_user collection');
      return null;
    }
    
    // In ra thông tin document đầu tiên
    final firstDoc = snapshot.docs.first;
    final data = firstDoc.data();
    print('   📋 First document info:');
    print('      ID: ${firstDoc.id}');
    print('      Fields: ${data.keys.join(', ')}');
    print('      type: ${data['type']}');
    print('      isActive: ${data['isActive']}');
    print('      title: ${data['title']}');
    
    // Tìm promotion với type='fixed' và isActive=true
    print('\n🔍 Searching for welcome promotion (type=fixed, isActive=true)...');
    final querySnapshot = await collectionRef
        .where('type', isEqualTo: 'fixed')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    print('   ✅ Query executed');
    print('   📊 Results: ${querySnapshot.docs.length} documents');
    
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final docData = doc.data();
      print('   🎉 FOUND welcome promotion!');
      print('      Title: ${docData['title']}');
      print('      Type: ${docData['type']}');
      print('      Discount: ${docData['discountAmount']}₫');
      
      return {
        'id': doc.id,
        ...docData,
      };
    }
    
    print('   ⚠️ No promotion with type=fixed AND isActive=true found');
    
    // Nếu không tìm thấy, thử tìm bất kỳ active promotion
    print('\n🔍 Searching for ANY active promotion...');
    final anyActive = await collectionRef
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (anyActive.docs.isNotEmpty) {
      final doc = anyActive.docs.first;
      print('   ✅ Found active promotion (not necessarily welcome):');
      print('      Title: ${doc.data()['title']}');
      print('      Type: ${doc.data()['type']}');
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }
    
    // Nếu vẫn không có, lấy document đầu tiên (cho mục đích demo)
    print('\n🔍 Using first document in collection (for demo)...');
    final firstDocSnapshot = await collectionRef.limit(1).get();
    if (firstDocSnapshot.docs.isNotEmpty) {
      final doc = firstDocSnapshot.docs.first;
      print('   Using document: ${doc.data()['title']}');
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }
    
    print('   ❌ No documents found in collection at all');
    return null;
    
  } catch (e) {
    print('❌ CRITICAL ERROR accessing Firestore:');
    print('   Error type: ${e.runtimeType}');
    print('   Error message: $e');
    
    // Phân tích lỗi chi tiết
    if (e is FirebaseException) {
      print('   🔥 Firebase Error Details:');
      print('      Code: ${e.code}');
      print('      Message: ${e.message}');
      print('      Plugin: ${e.plugin}');
      
      if (e.code == 'permission-denied') {
        print('   🔒 SECURITY RULES ERROR: Permission denied!');
        print('      Check Firestore Security Rules in Firebase Console');
        print('      Current rules may not allow read operations');
      }
    }
    
    return null;
  }
}

// Sửa hàm xử lý nhận khuyến mại
Future<void> _handleClaimWelcomePackage(Map<String, dynamic> promotion) async {
  try {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null || currentUser.isAnonymous) {
      _showLoginRequiredDialog();
      return;
    }
    
    // Kiểm tra đã claim chưa bằng cách kiểm tra trong user_promotions
    final hasClaimed = await _hasUserClaimedPromotion(currentUser.uid, promotion['id']);
    
    if (hasClaimed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã nhận ưu đãi chào mừng rồi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Lưu promotion cho user vào collection user_promotions
    await _saveUserPromotion(currentUser.uid, promotion);
    
    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Nhận ưu đãi thành công! Mã: ${promotion['code']}'),
        backgroundColor: Colors.green,
      ),
    );
    
  } catch (e) {
    print('❌ Error claiming welcome package: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Hàm kiểm tra user đã claim promotion chưa
Future<bool> _hasUserClaimedPromotion(String userId, String promotionId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('user_promotions')
        .where('userId', isEqualTo: userId)
        .where('promotionId', isEqualTo: promotionId)
        .limit(1)
        .get();
    
    return snapshot.docs.isNotEmpty;
  } catch (e) {
    print('Error checking claimed promotion: $e');
    return false;
  }
}

// Hàm lưu promotion cho user
Future<void> _saveUserPromotion(String userId, Map<String, dynamic> promotion) async {
  try {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    await FirebaseFirestore.instance.collection('user_promotions').add({
      'userId': userId,
      'promotionId': promotion['id'],
      'code': promotion['code'] ?? 'WELCOME${userId.substring(0, 6).toUpperCase()}',
      'title': promotion['title'] ?? 'Ưu đãi chào mừng',
      'description': promotion['description'] ?? '',
      'type': promotion['type'] ?? 'fixed',
      'discountAmount': promotion['discountAmount'] ?? 0,
      'discountPercentage': promotion['discountPercentage'] ?? 0,
      'minOrderAmount': promotion['minOrderAmount'] ?? 0,
      'originalPrice': promotion['originalPrice'] ?? 0,
      'expiryDate': promotion['expiryDate'] ?? 
          Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
      'claimedAt': FieldValue.serverTimestamp(),
      'isUsed': false,
      'usedAt': null,
      'imageUrl': promotion['imageUrl'],
      
      // Thông tin hiển thị
      'displayInfo': {
        'discountText': promotion['discountAmount'] != null 
            ? 'Giảm ${currencyFormat.format(promotion['discountAmount'])}' 
            : 'Giảm ${promotion['discountPercentage']}%',
        'conditionText': promotion['minOrderAmount'] != null && promotion['minOrderAmount'] > 0
            ? 'Cho đơn từ ${currencyFormat.format(promotion['minOrderAmount'])}'
            : 'Không có điều kiện',
      }
    });
    
    print('✅ Saved user promotion for user $userId');
    
  } catch (e) {
    print('❌ Error saving user promotion: $e');
    rethrow;
  }
}

void _showLoginRequiredDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Đăng nhập yêu cầu'),
      content: const Text('Vui lòng đăng nhập để nhận ưu đãi này.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('HỦY'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Điều hướng đến màn hình đăng nhập
            // Có thể sử dụng:
            // Navigator.pushNamed(context, '/login');
            // Hoặc:
            // if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
            //   context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
            //     context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 4; // Profile tab
            //   });
            // }
          },
          child: const Text('ĐĂNG NHẬP'),
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PromotionsScreen(),
          ),
        );
      },
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