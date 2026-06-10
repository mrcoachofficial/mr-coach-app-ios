import 'package:flutter/material.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:mrcoach/home%20screens/services_page.dart';
import 'package:mrcoach/home%20screens/scratch_card_screen.dart';
import 'package:mrcoach/my_bookings_page.dart';
import 'package:mrcoach/webview_screen.dart';

class NotificationsInboxPage extends StatefulWidget {
  const NotificationsInboxPage({super.key});

  @override
  State<NotificationsInboxPage> createState() => _NotificationsInboxPageState();
}

class _NotificationsInboxPageState extends State<NotificationsInboxPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final notifs = await ApiService.getUserNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String userNotifId) async {
    await ApiService.updateNotificationStatus(userNotifId, 'read');
    // Update local state without full reload
    if (mounted) {
      setState(() {
        for (var n in _notifications) {
          if (n['_id'] == userNotifId) {
            n['status'] = 'read';
          }
        }
      });
    }
  }

  Future<void> _markAsClicked(String userNotifId) async {
    await ApiService.updateNotificationStatus(userNotifId, 'clicked');
    if (mounted) {
      setState(() {
        for (var n in _notifications) {
          if (n['_id'] == userNotifId) {
            n['status'] = 'clicked';
          }
        }
      });
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return '';
    }
  }

  void _handleDeepLink(String redirectUrl, String userNotifId) async {
    // Track click state
    await _markAsClicked(userNotifId);

    if (!mounted) return;

    final url = redirectUrl.trim().toLowerCase();

    if (url == 'home') {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (url == 'services') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServiceScreen()),
      );
    } else if (url == 'bookings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllMyBookingsScreen()),
      );
    } else if (url == 'rewards') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScratchRewardsPage()),
      );
    } else if (url.startsWith('/events/') || url.startsWith('event')) {
      // Extract Event ID
      final parts = redirectUrl.split('/');
      final eventId = parts.isNotEmpty ? parts.last : '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventWebViewScreen(
            title: 'Event details',
            url: 'https://mrcoach.in/events/$eventId',
          ),
        ),
      );
    } else if (url.startsWith('/services/') || url.startsWith('service')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServiceScreen()),
      );
    } else {
      // Custom Web Link redirect
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventWebViewScreen(
            title: 'Announcement',
            url: redirectUrl,
          ),
        ),
      );
    }
  }

  void _showNotificationDetail(Map<String, dynamic> userNotif) {
    final notif = userNotif['notification'];
    final userNotifId = userNotif['_id'];

    if (userNotif['status'] == 'unread') {
      _markAsRead(userNotifId);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 14,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (notif['bannerImage'] != null && notif['bannerImage'].toString().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    notif['bannerImage'],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  _getTypeBadge(notif['type'] ?? 'promotion'),
                  const Spacer(),
                  Text(
                    _formatTime(notif['createdAt']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notif['title'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111118),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                notif['description'] ?? notif['message'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7B8194),
                  height: 1.5,
                ),
              ),
              if (notif['redirectUrl'] != null && notif['redirectUrl'].toString().isNotEmpty) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _handleDeepLink(notif['redirectUrl'], userNotifId);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C518),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF5C518).withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      notif['ctaText'] ?? 'View Details',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111118),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _getTypeBadge(String type) {
    Color bg = const Color(0xFFF3E8FF);
    Color fg = const Color(0xFF7C4DFF);
    String label = type.toUpperCase();

    if (type == 'reward') {
      bg = const Color(0xFFFFF8DC);
      fg = const Color(0xFFFF9800);
    } else if (type == 'event') {
      bg = const Color(0xFFDCF5E7);
      fg = const Color(0xFF22C55E);
    } else if (type == 'booking') {
      bg = const Color(0xFFDCEEFF);
      fg = const Color(0xFF2563EB);
    } else if (type == 'alert') {
      bg = const Color(0xFFFFE4E6);
      fg = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    if (type == 'reward') return Icons.card_giftcard_rounded;
    if (type == 'event') return Icons.emoji_events_rounded;
    if (type == 'booking') return Icons.calendar_today_rounded;
    if (type == 'alert') return Icons.warning_amber_rounded;
    return Icons.notifications_none_rounded;
  }

  Color _getTypeIconColor(String type) {
    if (type == 'reward') return const Color(0xFFFF9800);
    if (type == 'event') return const Color(0xFF22C55E);
    if (type == 'booking') return const Color(0xFF2563EB);
    if (type == 'alert') return const Color(0xFFDC2626);
    return const Color(0xFF7C4DFF);
  }

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Custom Top Header AppBar
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: topPad + 14,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEAEBF0)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 15, color: Color(0xFF111118)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111118),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _fetchNotifications,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEAEBF0)),
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        size: 18, color: Color(0xFF111118)),
                  ),
                ),
              ],
            ),
          ),

          // Inbox List Views
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: const Color(0xFFF5C518),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5C518)),
                      ),
                    )
                  : _notifications.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Inbox is clean!',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'No new notifications right now.',
                                    style: TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final userNotif = _notifications[index];
                            final notif = userNotif['notification'];
                            if (notif == null) return const SizedBox.shrink();

                            final isUnread = userNotif['status'] == 'unread';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isUnread ? const Color(0xFFF5C518).withOpacity(0.4) : const Color(0xFFEAEBF0),
                                  width: isUnread ? 1.5 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _showNotificationDetail(userNotif),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Icon Badge
                                              Container(
                                                width: 42,
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: _getTypeIconColor(notif['type']).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  _getTypeIcon(notif['type']),
                                                  color: _getTypeIconColor(notif['type']),
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        _getTypeBadge(notif['type'] ?? 'promotion'),
                                                        const Spacer(),
                                                        Text(
                                                          _formatTime(notif['createdAt']),
                                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                        ),
                                                        if (isUnread) ...[
                                                          const SizedBox(width: 8),
                                                          Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF5C518),
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      notif['title'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 14.5,
                                                        fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                                                        color: const Color(0xFF111118),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            notif['description'] ?? notif['message'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF7B8194),
                                              height: 1.45,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (notif['bannerImage'] != null && notif['bannerImage'].toString().isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                notif['bannerImage'],
                                                width: double.infinity,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                              ),
                                            ),
                                          ],
                                          if (notif['redirectUrl'] != null && notif['redirectUrl'].toString().isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  notif['ctaText'] ?? 'View Details',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFFF5C518),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.keyboard_arrow_right_rounded,
                                                  size: 16,
                                                  color: Color(0xFFF5C518),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
