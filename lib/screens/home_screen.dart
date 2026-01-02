import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'hotels_screen.dart';
import 'tours_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';

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
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF5B8DEF),
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildServiceMenu(context),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16), // kéo lên đè nền xanh
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.vertical(
                  //   top: Radius.circular(24),
                  // ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildPromotionList(),
                    const SizedBox(height: 24),
                    _buildViewMoreButton(),
                    const SizedBox(height: 8),
                    _buildDealTitle1(),
                    const SizedBox(height: 16),
                    _buildDealGrid() ,
                    const SizedBox(height: 24),
            
                  ],
                ),
              ),
            ),
          ],
        ),
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
              Expanded(
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
              const SizedBox(width: 12),
              // chat icon
              _buildHeaderIcon(Icons.chat_bubble_outline),
              const SizedBox(width: 8),
              //notification icon
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
                      // Navigate to hotels tab
                      if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                        context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                          context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 1;
                        });
                      }
                    }),
                    _serviceItem(Icons.travel_explore, 'Hoạt Động\nDu Lịch', () {
                      // Navigate to tours tab
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
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
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
              // Text
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
          // Progress + button
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
          // Image placeholder
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
          // TODO: navigate to deal screen
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        'Deal Hôm Nay',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDealGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,        // 2 cột
          mainAxisSpacing: 12,      // dọc
          crossAxisSpacing: 12,     // ngang
          childAspectRatio: 0.68,   // QUAN TRỌNG (ảnh chiếm 2/3)
        ),
        itemBuilder: (context, index) {
          return _dealCard();
        },
      ),
    );
  }

  Widget _dealCard() {
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
          // ẢNH (2/3)
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFECEFF5),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 36, color: Colors.grey),
              ),
            ),
          ),

          // INFO (1/3)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Giảm đến 40%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Khách sạn cao cấp',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}