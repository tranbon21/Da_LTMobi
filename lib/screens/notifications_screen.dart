import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    
    if (currentUser == null || currentUser.isAnonymous) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo'),
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
                'Vui lòng đăng nhập để xem thông báo',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: const Color(0xFF5B8DEF),
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('user_notifications')
                .where('userId', isEqualTo: currentUser.uid)
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.docs.length ?? 0;
              
              if (unreadCount > 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _clearAllNotifications(currentUser.uid),
            tooltip: 'Xóa tất cả',
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => _markAllAsRead(currentUser.uid),
            tooltip: 'Đánh dấu đã đọc tất cả',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('user_notifications')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }
          
          final notifications = snapshot.data?.docs ?? [];
          
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không có thông báo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Các thông báo mới sẽ xuất hiện ở đây',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildNotificationItem(doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(String notificationId, Map<String, dynamic> data) {
    final isRead = data['read'] ?? false;
    final title = data['title'] ?? 'Thông báo';
    final message = data['message'] ?? '';
    final type = data['type'] ?? 'general';
    final createdAt = data['createdAt'] != null
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    
    final timeAgo = _getTimeAgo(createdAt);
    
    // Map type to icon and color
    final Map<String, dynamic> typeInfo = _getTypeInfo(type);
    
    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa thông báo: $title'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue[50],
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: typeInfo['color'] as Color,
            child: Icon(
              typeInfo['icon'] as IconData,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            _markAsRead(notificationId);
            _handleNotificationTap(notificationId, data);
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _getTypeInfo(String type) {
    switch (type) {
      case 'booking':
        return {
          'icon': Icons.hotel,
          'color': Colors.blue,
        };
      case 'promotion':
        return {
          'icon': Icons.local_offer,
          'color': Colors.green,
        };
      case 'payment':
        return {
          'icon': Icons.payment,
          'color': Colors.orange,
        };
      case 'review':
        return {
          'icon': Icons.star,
          'color': Colors.purple,
        };
      case 'system':
        return {
          'icon': Icons.info,
          'color': Colors.blueGrey,
        };
      default:
        return {
          'icon': Icons.notifications,
          'color': Colors.grey,
        };
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('user_notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      
      await batch.commit();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả là đã đọc'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error marking all as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('user_notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> _clearAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_notifications')
          .where('userId', isEqualTo: userId)
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa tất cả thông báo'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error clearing all notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNotificationTap(String notificationId, Map<String, dynamic> data) {
    final type = data['type'] ?? 'general';
    final title = data['title'] ?? 'Thông báo';
    final message = data['message'] ?? '';
    final bookingId = data['bookingId'];
    final promotionId = data['promotionId'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
          if (type == 'booking' && bookingId != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Điều hướng đến trang chi tiết booking
                print('Navigate to booking: $bookingId');
              },
              child: const Text('XEM ĐẶT PHÒNG'),
            ),
          if (type == 'promotion' && promotionId != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Điều hướng đến trang chi tiết promotion
                print('Navigate to promotion: $promotionId');
              },
              child: const Text('XEM ƯU ĐÃI'),
            ),
        ],
      ),
    );
  }
}