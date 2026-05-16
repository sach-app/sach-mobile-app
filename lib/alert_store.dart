import 'package:flutter/material.dart';

import 'dart:convert';
import 'api_service.dart';

/// Alert data model
class AlertItem {
  final int id;
  final int userId;
  final String titleText;
  final String message;
  bool isRead;
  final String notificationType;
  final int referenceId;
  final String createdAt;

  AlertItem({
    required this.id,
    required this.userId,
    required this.titleText,
    required this.message,
    required this.isRead,
    required this.notificationType,
    required this.referenceId,
    required this.createdAt,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      titleText: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      notificationType: json['notification_type'] ?? '',
      referenceId: json['reference_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  String title(bool isUrdu) => titleText;
  String subtitle(bool isUrdu) => message;
  String get time {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  bool get isUnread => !isRead;
  set isUnread(bool val) => isRead = !val;

  IconData get icon {
    if (notificationType == 'fir_status_update') {
      return Icons.update_rounded;
    }
    return Icons.notifications_rounded;
  }
}

/// Global singleton alert store — shared between Dashboard popup and AlertsScreen.
class AlertStore extends ChangeNotifier {
  AlertStore._();
  static final AlertStore instance = AlertStore._();

  final List<AlertItem> alerts = [];
  bool isLoading = false;

  int get unreadCount => alerts.where((a) => a.isUnread).length;

  Future<void> fetchNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/user/notifications');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['items'] ?? [];
        alerts.clear();
        for (var json in items) {
          alerts.add(AlertItem.fromJson(json));
        }
      }
    } catch (e) {
      // Safe error handling
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    for (final a in alerts) {
      a.isRead = true;
    }
    notifyListeners();

    try {
      final res = await ApiService.put('/user/notifications/read-all');
      if (res.statusCode != 200) {
        debugPrint('MarkAllRead Error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('MarkAllRead Exception: $e');
    }
  }

  Future<void> markRead(AlertItem item) async {
    if (item.isRead) return;

    item.isRead = true;
    notifyListeners();

    try {
      final res = await ApiService.put('/user/notifications/${item.id}/read');
      if (res.statusCode != 200) {
        debugPrint('MarkRead Error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('MarkRead Exception: $e');
    }
  }

  void clearAll() {
    alerts.clear();
    notifyListeners();
  }
}
