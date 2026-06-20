import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadNotifications);
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final listResponse = await _apiService.get(
        '${ApiConstants.notifications}?pageNumber=1&pageSize=20',
        token: auth.token,
      );

      final countResponse = await _apiService.get(
        ApiConstants.unreadCount,
        token: auth.token,
      );

      final data = listResponse['data'];

      setState(() {
        _notifications = data is List
            ? data.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];
        _unreadCount = countResponse['data'] is int ? countResponse['data'] : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.replaceAll('T', ' ').split('.').first;
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'Transaction':
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الإشعارات ($_unreadCount)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _notifications.isEmpty
          ? const Center(child: Text('لا توجد إشعارات'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _notifications[index];

          final title = item['title']?.toString() ?? '';
          final body = item['body']?.toString() ?? '';
          final type = item['type']?.toString();
          final isRead = item['isRead'] == true;
          final createdAt = item['createdAt']?.toString();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                  AppColors.primary.withValues(alpha: 0.12),
                  child: Icon(
                    _iconForType(type),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  const Icon(
                    Icons.circle,
                    color: AppColors.primary,
                    size: 10,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}