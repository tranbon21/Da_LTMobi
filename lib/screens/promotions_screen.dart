// File: lib/screens/promotions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/system_promotion_service.dart';
import '../services/user_promotion_service.dart';
import '../models/user_promotion_model.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final SystemPromotionService _systemPromotionService = SystemPromotionService();
  final UserPromotionService _userPromotionService = UserPromotionService();
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Tất cả'},
    {'id': 'welcome', 'name': 'Chào mừng'},
    {'id': 'transport', 'name': 'Vé xe'},
    {'id': 'giftCard', 'name': 'Quà tặng'},
    {'id': 'hotel', 'name': 'Khách sạn'},
    {'id': 'tour', 'name': 'Tour du lịch'},
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    final isLoggedIn = currentUser != null && !currentUser.isAnonymous;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ưu Đãi Hấp Dẫn'),
        backgroundColor: const Color(0xFF5B8DEF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Categories filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == _categories.length - 1 ? 16 : 0,
                    top: 12,
                    bottom: 12,
                  ),
                  child: FilterChip(
                    label: Text(category['name']),
                    selected: _selectedCategory == category['id'],
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category['id'];
                      });
                    },
                    selectedColor: const Color(0xFF5B8DEF),
                    labelStyle: TextStyle(
                      color: _selectedCategory == category['id'] 
                          ? Colors.white 
                          : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Promotions list
          Expanded(
            child: StreamBuilder<List<SystemPromotion>>(
              stream: _selectedCategory == 'all'
                  ? _systemPromotionService.getAllPromotions()
                  : _systemPromotionService.getPromotionsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                }
                
                final promotions = snapshot.data ?? [];
                
                if (promotions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hiện chưa có ưu đãi nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: promotions.length,
                  itemBuilder: (context, index) {
                    final promotion = promotions[index];
                    return _buildPromotionCard(promotion, isLoggedIn);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(SystemPromotion promotion, bool isLoggedIn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promotion image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: promotion.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(promotion.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: promotion.imageUrl == null
                ? const Center(
                    child: Icon(
                      Icons.local_offer_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        promotion.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: promotion.isValid ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        promotion.isValid ? 'HIỆU LỰC' : 'HẾT HẠN',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  promotion.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Discount info
                Row(
                  children: [
                    if (promotion.discountPercentage > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${promotion.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    if (promotion.discountAmount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${promotion.discountAmount.toStringAsFixed(0)}K',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Conditions
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Áp dụng cho đơn từ ${promotion.minOrderAmount.toStringAsFixed(0)}K',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'HSD: ${promotion.expiryDate.day}/${promotion.expiryDate.month}/${promotion.expiryDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Row(
                //   children: [
                //     Icon(
                //       Icons.inventory_2_outlined,
                //       size: 16,
                //       color: Colors.grey[500],
                //     ),
                //     const SizedBox(width: 8),
                //     // Expanded(
                //     //   child: Text(
                //     //     'Còn lại: ${promotion.stock} lượt',
                //     //     style: TextStyle(
                //     //       fontSize: 12,
                //     //       color: Colors.grey[600],
                //     //     ),
                //     //   ),
                //     // ),
                //   ],
                // ),
                
                const SizedBox(height: 16),
                
                // Claim button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: promotion.isValid && promotion.isAvailable
                          ? const Color(0xFF5B8DEF)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: promotion.isValid && promotion.isAvailable
                        ? () => _claimPromotion(promotion)
                        : null,
                    child: isLoggedIn
                        ? const Text('NHẬN ƯU ĐÃI')
                        : const Text('ĐĂNG NHẬP ĐỂ NHẬN'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claimPromotion(SystemPromotion promotion) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser == null || currentUser.isAnonymous) {
        // Yêu cầu đăng nhập
        _showLoginRequiredDialog();
        return;
      }
      
      final userPromotionService = UserPromotionService();
      
      // Claim promotion từ hệ thống
      await _systemPromotionService.claimPromotion(promotion.id);
      
      // Lưu promotion cho user
      await userPromotionService.claimPromotion(
        userId: currentUser.uid,
        promotionId: promotion.id,
        title: promotion.title,
        description: promotion.description,
        discountPercentage: promotion.discountPercentage,
        discountAmount: promotion.discountAmount,
        minOrderAmount: promotion.minOrderAmount,
        code: promotion.code,
        type: _getPromotionType(promotion.category),
        imageUrl: promotion.imageUrl,
      );
      
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Nhận ưu đãi thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  PromotionType _getPromotionType(String category) {
    switch (category) {
      case 'welcome':
        return PromotionType.welcome;
      case 'transport':
        return PromotionType.transport;
      case 'giftCard':
        return PromotionType.giftCard;
      case 'hotel':
        return PromotionType.hotel;
      case 'tour':
        return PromotionType.tour;
      default:
        return PromotionType.welcome;
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
              // Chuyển đến màn hình đăng nhập
              // Bạn có thể thêm navigation tại đây
            },
            child: const Text('ĐĂNG NHẬP'),
          ),
        ],
      ),
    );
  }
}