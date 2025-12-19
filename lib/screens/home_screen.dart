import 'package:flutter/material.dart';
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
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const HotelsScreen(),
    const ToursScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khám phá thế giới',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    'Đặt phòng khách sạn và tour du lịch dễ dàng',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingL),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dịch vụ',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.hotel,
                          title: AppStrings.hotels,
                          color: AppColors.primary,
                          onTap: () {
                            // Navigate to hotels tab
                            if (context
                                    .findAncestorStateOfType<
                                      _HomeScreenState
                                    >() !=
                                null) {
                              context
                                  .findAncestorStateOfType<_HomeScreenState>()!
                                  .setState(() {
                                    context
                                            .findAncestorStateOfType<
                                              _HomeScreenState
                                            >()!
                                            ._currentIndex =
                                        1;
                                  });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.tour,
                          title: AppStrings.tours,
                          color: AppColors.accent,
                          onTap: () {
                            // Navigate to tours tab
                            if (context
                                    .findAncestorStateOfType<
                                      _HomeScreenState
                                    >() !=
                                null) {
                              context
                                  .findAncestorStateOfType<_HomeScreenState>()!
                                  .setState(() {
                                    context
                                            .findAncestorStateOfType<
                                              _HomeScreenState
                                            >()!
                                            ._currentIndex =
                                        2;
                                  });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingL),

            // Featured section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm đến phổ biến',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _DestinationCard(
                          image: Icons.location_city,
                          title: 'Hà Nội',
                          subtitle: '120+ khách sạn',
                        ),
                        _DestinationCard(
                          image: Icons.beach_access,
                          title: 'Đà Nẵng',
                          subtitle: '80+ khách sạn',
                        ),
                        _DestinationCard(
                          image: Icons.temple_buddhist,
                          title: 'Hội An',
                          subtitle: '50+ khách sạn',
                        ),
                        _DestinationCard(
                          image: Icons.landscape,
                          title: 'Sapa',
                          subtitle: '30+ tour',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingL),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              Icon(icon, size: AppSizes.iconXL, color: color),
              const SizedBox(height: AppSizes.paddingS),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final IconData image;
  final String title;
  final String subtitle;

  const _DestinationCard({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: AppSizes.paddingM),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              color: AppColors.primary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  image,
                  size: AppSizes.iconXL,
                  color: AppColors.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSizes.paddingXS),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
