import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrcoach/profile_settings_pages/booking_store.dart';
import 'package:mrcoach/services/api_service.dart';

const Color _kBg          = Color(0xFFFAFAF8);
const Color _kSurface     = Color(0xFFFFFFFF);
const Color _kYellow      = Color(0xFFFFD60A);
const Color _kYellowLight = Color(0xFFFFF9D6);
const Color _kYellowMid   = Color(0xFFFFF0A0);
const Color _kYellowDark  = Color(0xFFD4A900);
const Color _kInk         = Color(0xFF18181B);
const Color _kInkSub      = Color(0xFF71717A);
const Color _kInkHint     = Color(0xFFB4B4BC);
const Color _kBorder      = Color(0xFFE8E8ED);
const Color _kGreen       = Color(0xFF16A34A);
const Color _kGreenBg     = Color(0xFFDCFCE7);
const Color _kRed         = Color(0xFFDC2626);
const Color _kRedBg       = Color(0xFFFEE2E2);
const Color _kBlue        = Color(0xFF2563EB);
const Color _kBlueBg      = Color(0xFFDFEAFE);

// Tab indices:
// 0 = All
// 1 = Demo
// 2 = Enquiry
// 3 = Done

class AllMyBookingsScreen extends StatefulWidget {
  const AllMyBookingsScreen({super.key});

  @override
  State<AllMyBookingsScreen> createState() => _AllMyBookingsScreenState();
}

class _AllMyBookingsScreenState extends State<AllMyBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ServiceCategory? _catFilter;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    BookingStore.instance.addListener(_refresh);
    _loadBookingsFromBackend();
  }

  Future<void> _loadBookingsFromBackend() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMyBookings();
      final list = data.map((item) => Booking.fromJson(item)).toList();
      BookingStore.instance.setBookings(list);
    } catch (e) {
      print('Error loading bookings from backend: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    BookingStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  List<Booking> _getList(int tabIndex) {
    var list = BookingStore.instance.all;
    if (_catFilter != null) {
      list = list.where((b) => b.serviceCategory == _catFilter).toList();
    }
    switch (tabIndex) {
      case 0: // All — active + completed (no cancelled)
        return list
            .where((b) =>
                b.status == BookingStatus.active ||
                b.status == BookingStatus.completed)
            .toList();
      case 1: // Demo (active only)
        return list
            .where((b) =>
                b.type == BookingType.demo &&
                b.status == BookingStatus.active)
            .toList();
      case 2: // Enquiry (active only)
        return list
            .where((b) =>
                b.type == BookingType.enquire &&
                b.status == BookingStatus.active)
            .toList();
      case 3: // Done (completed)
        return list
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      default:
        return list;
    }
  }

  int _countFor(int tabIndex) {
    final list = BookingStore.instance.all;
    switch (tabIndex) {
      case 0:
        return list
            .where((b) =>
                b.status == BookingStatus.active ||
                b.status == BookingStatus.completed)
            .length;
      case 1:
        return list
            .where((b) =>
                b.type == BookingType.demo &&
                b.status == BookingStatus.active)
            .length;
      case 2:
        return list
            .where((b) =>
                b.type == BookingType.enquire &&
                b.status == BookingStatus.active)
            .length;
      case 3:
        return list
            .where((b) => b.status == BookingStatus.completed)
            .length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final topPad = MediaQuery.of(context).padding.top;
    final all = BookingStore.instance.all;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: _kSurface,
            padding: EdgeInsets.only(
              top: topPad + 14,
              left: 20,
              right: 20,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kBorder),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 15, color: _kInk),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'My Bookings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    if (all.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${all.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                          ),
                        ),
                      ),
                  ],
                ),

                // Stat pills
                if (all.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatPill(
                          label: '${BookingStore.instance.demoCount} Demos',
                          icon: Icons.calendar_today_rounded,
                          color: _kYellowLight,
                          textColor: _kYellowDark,
                        ),
                        const SizedBox(width: 6),
                        _StatPill(
                          label:
                              '${BookingStore.instance.enquiryCount} Enquiries',
                          icon: Icons.chat_bubble_outline_rounded,
                          color: _kBlueBg,
                          textColor: _kBlue,
                        ),
                        if (BookingStore.instance.totalAmountPaid > 0) ...[
                          const SizedBox(width: 6),
                          _StatPill(
                            label:
                                '₹${BookingStore.instance.totalAmountPaid} Paid',
                            icon: Icons.payments_rounded,
                            color: _kGreenBg,
                            textColor: _kGreen,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Category filter chips
                if (all.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _CategoryRow(
                    active: _catFilter,
                    all: all,
                    onSelect: (c) => setState(() => _catFilter = c),
                  ),
                ],

                const SizedBox(height: 2),

                // Tab bar: All | Demo | Enquiry | Done
                TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: _kInk,
                  unselectedLabelColor: _kInkSub,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: _kYellow, width: 2.5),
                    insets: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: _kBorder,
                  tabs: [
                    _TabItem(label: 'All',     count: _countFor(0)),
                    _TabItem(label: 'Demo',    count: _countFor(1)),
                    _TabItem(label: 'Enquiry', count: _countFor(2)),
                    _TabItem(label: 'Done',    count: _countFor(3)),
                  ],
                ),
              ],
            ),
          ),

          // ── Tab views ───────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_kYellow),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(4, (i) {
                      final list = _getList(i);
                      if (list.isEmpty) {
                        return _EmptyState(tabIndex: i, catFilter: _catFilter);
                      }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                  itemCount: list.length,
                  itemBuilder: (_, idx) => _BookingCard(
                    booking: list[idx],
                    onViewDetails: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailScreen(booking: list[idx]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category row ────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final ServiceCategory? active;
  final List<Booking> all;
  final void Function(ServiceCategory?) onSelect;

  const _CategoryRow(
      {required this.active, required this.all, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final present = ServiceCategory.values
        .where((c) => all.any((b) => b.serviceCategory == c))
        .toList();
    if (present.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _CatChip(
              emoji: '🔀',
              label: 'All',
              isActive: active == null,
              onTap: () => onSelect(null),
            ),
            ...present.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _CatChip(
                    emoji: c.emoji,
                    label: c.label,
                    isActive: active == c,
                    onTap: () => onSelect(c),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String emoji, label;
  final bool isActive;
  final VoidCallback onTap;

  const _CatChip({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _kYellow : _kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _kYellow : _kBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? _kInk : _kInkSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab item ────────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  final String label;
  final int count;

  const _TabItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: _kYellowLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _kYellowDark),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat pill ───────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, textColor;

  const _StatPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
        ],
      ),
    );
  }
}

// ── Booking card (no quick-action buttons) ──────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewDetails;

  const _BookingCard({
    required this.booking,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final cat = booking.serviceCategory;
    final isDemo = booking.type == BookingType.demo;
    final isOnline = booking.serviceMode == ServiceMode.online;
    final Color catColor = Color(cat.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ── Top: emoji + service name + status badge ─────────────────
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(booking.service.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.service.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _kInk,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            cat.emoji,
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cat.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _kInkSub,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: _kInkHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isOnline
                                ? Icons.videocam_rounded
                                : Icons.home_rounded,
                            size: 12,
                            color: _kInkSub,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isOnline ? 'Online' : 'Home Visit',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kInkSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: _kBorder, height: 1),
            const SizedBox(height: 12),

            // ── Info chips ────────────────────────────────────────────────
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  value: booking.sessionDate != null
                      ? _fmtDate(booking.sessionDate!)
                      : _fmtDate(booking.bookedAt),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  value: booking.timeSlot ?? 'TBD',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.person_rounded,
                  value: (isDemo
                          ? booking.customerName
                          : booking.enquirerName) ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Bottom row: amount tag + Details button ───────────────────
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDemo ? _kYellowLight : _kBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isDemo ? '₹${booking.totalAmount}' : 'FREE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDemo ? _kYellowDark : _kBlue,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onViewDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _kInk,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 12, color: _kYellow),
                      ],
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

  String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month - 1]}';
  }
}

// ── Info chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: _kInkSub),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    late IconData icon;
    late String label;

    switch (status) {
      case BookingStatus.active:
        bg = _kGreenBg;
        fg = _kGreen;
        icon = Icons.circle;
        label = 'Active';
        break;
      case BookingStatus.completed:
        bg = _kBlueBg;
        fg = _kBlue;
        icon = Icons.check_circle_rounded;
        label = 'Done';
        break;
      case BookingStatus.cancelled:
        bg = _kRedBg;
        fg = _kRed;
        icon = Icons.cancel_rounded;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 7, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final int tabIndex;
  final ServiceCategory? catFilter;

  const _EmptyState({required this.tabIndex, required this.catFilter});

  @override
  Widget build(BuildContext context) {
    const labels  = ['bookings', 'demo bookings', 'enquiries', 'completed sessions'];
    const emojis  = ['📋', '🗓️', '💬', '✅'];
    final label = catFilter != null
        ? '${catFilter!.label} ${labels[tabIndex]}'
        : labels[tabIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kYellowLight,
              shape: BoxShape.circle,
              border: Border.all(color: _kYellowMid, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              catFilter?.emoji ?? emojis[tabIndex],
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${label[0].toUpperCase()}${label.substring(1)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _kInk,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tabIndex == 0
                ? 'Book a demo or send an enquiry\nto see your sessions here.'
                : 'No sessions in this category.\nTry a different filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: _kInkSub, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Booking Detail Screen
// ════════════════════════════════════════════════════════════════════════════

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _editingAddress = false;
  late TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _addressCtrl =
        TextEditingController(text: widget.booking.address ?? '');
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _saving = false;
      _editingAddress = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Address updated'),
          backgroundColor: _kGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final cat = b.serviceCategory;
    final isDemo = b.type == BookingType.demo;
    final isOnline = b.serviceMode == ServiceMode.online;
    final Color catColor = Color(cat.colorValue);
    final Color catDark = Color(cat.darkColorValue);
    final Color catLight = Color(cat.lightColorValue);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: _kSurface,
              padding: EdgeInsets.only(
                top: topPad + 14,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nav
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _kBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _kBorder),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 15, color: _kInk),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      _StatusBadge(status: b.status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(b.service.emoji,
                            style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.service.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _kInk,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: catLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${cat.emoji} ${cat.label}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: catDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _kBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: _kBorder),
                                  ),
                                  child: Text(
                                    isDemo ? 'Demo' : 'Enquiry',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _kInkSub,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _DetailCard(
                  title: 'Booking Info',
                  icon: Icons.confirmation_number_rounded,
                  iconColor: catDark,
                  iconBg: catLight,
                  children: [
                    _DetailRow(
                      label: 'Booking ID',
                      value: '#${b.bookingId}',
                      mono: true,
                    ),
                    _DetailRow(
                      label: 'Booked On',
                      value: _fmtDateFull(b.bookedAt),
                    ),
                    _DetailRow(
                      label: 'Via',
                      value: b.sourceScreen,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  title: 'Schedule',
                  icon: Icons.calendar_month_rounded,
                  iconColor: _kBlue,
                  iconBg: _kBlueBg,
                  children: [
                    _DetailRow(
                      label: 'Date',
                      value: b.sessionDate != null
                          ? _fmtDateFull(b.sessionDate!)
                          : _fmtDateFull(b.bookedAt),
                    ),
                    _DetailRow(
                      label: 'Time Slot',
                      value: b.timeSlot ?? 'To Be Decided',
                    ),
                    _DetailRow(
                      label: 'Mode',
                      value: isOnline ? '📹 Online Session' : '🏠 Home Visit',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  title: isDemo ? 'Customer' : 'Enquirer',
                  icon: Icons.person_rounded,
                  iconColor: catDark,
                  iconBg: catLight,
                  children: [
                    _DetailRow(
                      label: 'Name',
                      value: (isDemo ? b.customerName : b.enquirerName) ??
                          'Not specified',
                    ),
                    if (isDemo && (b.customerPhone ?? '').isNotEmpty)
                      _DetailRow(
                        label: 'Phone',
                        value: b.customerPhone!,
                        isPhone: true,
                      ),
                    if (!isDemo && (b.doubtMessage ?? '').isNotEmpty)
                      _DetailRow(
                        label: 'Query',
                        value: b.doubtMessage!,
                        multiline: true,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  title: 'Payment',
                  icon: Icons.payments_rounded,
                  iconColor: _kGreen,
                  iconBg: _kGreenBg,
                  children: [
                    _DetailRow(
                      label: 'Amount',
                      value: isDemo ? '₹${b.totalAmount}' : 'Free',
                    ),
                    _DetailRow(
                      label: 'Status',
                      value: isDemo ? 'Paid' : 'N/A',
                      valueColor: isDemo ? _kGreen : _kInkSub,
                    ),
                    if (isDemo && (b.paymentId ?? '').isNotEmpty)
                      _DetailRow(
                        label: 'Payment ID',
                        value: b.paymentId!,
                        mono: true,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isDemo && !isOnline)
                  _AddressCard(
                    controller: _addressCtrl,
                    isEditing: _editingAddress,
                    isSaving: _saving,
                    onEdit: () => setState(() => _editingAddress = true),
                    onCancel: () => setState(() => _editingAddress = false),
                    onSave: _saveAddress,
                  ),
                if ((b.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailCard(
                    title: 'Notes',
                    icon: Icons.sticky_note_2_rounded,
                    iconColor: _kYellowDark,
                    iconBg: _kYellowLight,
                    children: [
                      Text(
                        b.notes!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _kInkSub,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ],
                // Action buttons only shown on detail screen for active bookings
                if (b.status == BookingStatus.active) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Mark as Done',
                          icon: Icons.check_circle_rounded,
                          color: _kGreen,
                          bg: _kGreenBg,
                          onTap: () {
                            BookingStore.instance.updateStatus(
                                b.bookingId, BookingStatus.completed);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Expanded(
                      //   child: _ActionButton(
                      //     label: 'Cancel Booking',
                      //     icon: Icons.cancel_rounded,
                      //     color: _kRed,
                      //     bg: _kRedBg,
                      //     onTap: () {
                      //       BookingStore.instance.updateStatus(
                      //           b.bookingId, BookingStatus.cancelled);
                      //       Navigator.pop(context);
                      //     },
                        //),
                     // ),
                    ],
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDateFull(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April',    'May',      'June',
      'July',    'August',   'September', 'October', 'November', 'December'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ── Detail card ──────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor, iconBg;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 14, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool mono;
  final bool multiline;
  final bool isPhone;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.multiline = false,
    this.isPhone = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _kInkHint,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        color: _kInkSub,
                        height: 1.5)),
              ],
            )
          : Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kInkSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? _kInk,
                    fontFamily: mono ? 'monospace' : null,
                    letterSpacing: mono ? 0.5 : 0,
                  ),
                ),
                if (isPhone)
                  GestureDetector(
                    onTap: () {/* launch phone */},
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.call_rounded,
                          size: 14, color: _kGreen),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Address card ─────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing, isSaving;
  final VoidCallback onEdit, onCancel;
  final Future<void> Function() onSave;

  const _AddressCard({
    required this.controller,
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEditing ? _kYellow : _kBorder,
          width: isEditing ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _kYellowLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.location_on_rounded,
                      size: 14, color: _kYellowDark),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _kInk,
                    ),
                  ),
                ),
                if (!isEditing)
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _kYellowLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 11, color: _kYellowDark),
                          SizedBox(width: 4),
                          Text('Edit',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kYellowDark)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _kInk,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter full address...',
                          hintStyle:
                              const TextStyle(fontSize: 13, color: _kInkHint),
                          filled: true,
                          fillColor: _kBg,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: _kBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: _kBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: _kYellow, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onCancel,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _kBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _kBorder),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _kInkSub),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: isSaving ? null : onSave,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _kYellow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _kInk,
                                        ),
                                      )
                                    : const Text(
                                        'Save Address',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: _kInk),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Text(
                    controller.text.isNotEmpty
                        ? controller.text
                        : 'No address added yet.',
                    style: TextStyle(
                      fontSize: 13,
                      color: controller.text.isNotEmpty
                          ? _kInk
                          : _kInkHint,
                      height: 1.6,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}