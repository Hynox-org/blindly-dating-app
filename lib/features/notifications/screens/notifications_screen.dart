import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_db_service.dart';
import '../models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final notificationService = NotificationDbService();
    // Using white background per user rules
    final backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to view notifications.'))
          : StreamBuilder<List<AppNotification>>(
              stream: notificationService.streamNotifications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('You have no notifications yet.'),
                  );
                }

                return ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        // Mark as read
                        if (!notification.isRead) {
                          notificationService.markAsRead(
                            notification.id,
                            userId,
                          );
                        }

                        // Handle deep linking navigation here based on routing data
                        if (notification.data.containsKey('route')) {
                          final route = notification.data['route'] as String;
                          Navigator.pushNamed(context, route);
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Choose icon based on type
    IconData iconData;
    switch (notification.type) {
      case 'match_update':
        iconData = Icons.favorite;
        break;
      case 'message':
        iconData = Icons.message;
        break;
      case 'greeting':
        iconData = Icons.waving_hand;
        break;
      case 'alert':
        iconData = Icons.warning;
        break;
      default:
        iconData = Icons.notifications;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.white
            : theme.colorScheme.surface.withValues(
                alpha: 0.5,
              ), // Unread has slight tint using app colors
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(iconData, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: notification.isRead
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeago.format(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
