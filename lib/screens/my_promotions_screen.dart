// File: lib/screens/my_promotions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_promotion_service.dart';
import '../models/user_promotion_model.dart';

class MyPromotionsScreen extends StatefulWidget {
  const MyPromotionsScreen({super.key});

  @override
  State<MyPromotionsScreen> createState() => _MyPromotionsScreenState();
}

class _MyPromotionsScreenState extends State<MyPromotionsScreen> {
  final UserPromotionService _userPromotionService = UserPromotionService();
  String _filter = 'all'; // all, valid, used, expired

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    
    if (currentUser == null || currentUser.isAnonymous) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ưu Đãi Của Tôi'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Vui lòng đăng nhập để xem ưu đãi',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                },
                child: const Text('ĐĂNG NHẬP'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ưu Đãi Của Tôi'),
        backgroundColor: const Color(0xFF5B8DEF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                _buildFilterTab('Tất cả', 'all'),
                _buildFilterTab('Còn hiệu lực', 'valid'),
                _buildFilterTab('Đã dùng', 'used'),
                _buildFilterTab('Hết hạn', 'expired'),
              ],
            ),
          ),
          
          // Promotions list
          Expanded(
            child: StreamBuilder<List<UserPromotion>>(
              stream: _userPromotionService.getUserPromotions(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                }
                
                final allPromotions = snapshot.data ?? [];
                final filteredPromotions = _filterPromotions(allPromotions);
                
                if (filteredPromotions.isEmpty) {
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
                        Text(
                          _getEmptyMessage(),
                          style: const TextStyle(
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
                  itemCount: filteredPromotions.length,
                  itemBuilder: (context, index) {
                    final promotion = filteredPromotions[index];
                    return _buildPromotionCard(promotion);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _filter = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _filter == value 
                    ? const Color(0xFF5B8DEF) 
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _filter == value 
                      ? const Color(0xFF5B8DEF) 
                      : Colors.grey,
                  fontWeight: _filter == value 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<UserPromotion> _filterPromotions(List<UserPromotion> promotions) {
    switch (_filter) {
      case 'valid':
        return promotions.where((p) => p.isValid).toList();
      case 'used':
        return promotions.where((p) => p.isUsed).toList();
      case 'expired':
        return promotions.where((p) => !p.isValid && !p.isUsed).toList();
      default:
        return promotions;
    }
  }

  String _getEmptyMessage() {
    switch (_filter) {
      case 'valid':
        return 'Không có ưu đãi nào còn hiệu lực';
      case 'used':
        return 'Bạn chưa sử dụng ưu đãi nào';
      case 'expired':
        return 'Không có ưu đãi hết hạn';
      default:
        return 'Bạn chưa có ưu đãi nào';
    }
  }

  Widget _buildPromotionCard(UserPromotion promotion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: promotion.type == PromotionType.welcome
                        ? Colors.orange.withOpacity(0.1)
                        : promotion.type == PromotionType.transport
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    promotion.type.displayName,
                    style: TextStyle(
                      color: promotion.type == PromotionType.welcome
                          ? Colors.orange
                          : promotion.type == PromotionType.transport
                              ? Colors.green
                              : Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: promotion.isValid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    promotion.isValid 
                        ? 'HIỆU LỰC' 
                        : promotion.isUsed 
                            ? 'ĐÃ DÙNG' 
                            : 'HẾT HẠN',
                    style: TextStyle(
                      color: promotion.isValid
                          ? Colors.green
                          : promotion.isUsed
                              ? Colors.blue
                              : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              promotion.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            
            // Promotion code
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã ưu đãi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          promotion.code,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          // Copy to clipboard
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Validity info
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
          ],
        ),
      ),
    );
  }
}