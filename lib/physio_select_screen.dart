                  
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrcoach/home%20screens/scratch_card_screen.dart';
import 'package:mrcoach/profile_settings_pages/booking_store.dart';
import 'package:mrcoach/home%20screens/yoga_service_screen.dart';
import 'package:mrcoach/services/api_service.dart';

const Color kYellow      = Color(0xFFFFD54F);
const Color kYellowDark  = Color(0xFFFFC107);
const Color kYellowLight = Color(0xFFFFF8D6);
const Color kYellowMid   = Color(0xFFFFF3A3);
const Color kBg          = Color(0xFFFFFDE7);
const Color kTextDark    = Color(0xFF1A1200);
const Color kTextMid     = Color(0xFF5C4A00);
const Color kTextLight   = Color(0xFF9C8400);
const Color kBorder      = Color(0xFFFFB300);
const Color kCardSel     = Color(0xFFFFF9CC);
const Color kGreen       = Color(0xFF00BFA5);
const Color kGreenLight  = Color(0xFFE0F7F4);
const Color kDark        = Color(0xFF1A1200);
const Color kBlue        = Color(0xFF000000);
const Color kBlueLight   = Color(0xFFE8F0FF);

class PhysioService {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String tag;

  const PhysioService({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.tag,
  });
}

const List<PhysioService> kServices = [
  PhysioService(id: '0', name: 'Back / Neck / Knee Pain',       description: '', emoji: '🦴', tag: 'Medical'),
  PhysioService(id: '1', name: 'Elderly Care',                  description: '', emoji: '👴', tag: 'Family'),
  PhysioService(id: '2', name: 'Home Physiotherapy',            description: '', emoji: '🏠', tag: 'Fitness'),
  PhysioService(id: '3', name: 'Mobility Training',             description: '', emoji: '🚶', tag: 'Online'),
  PhysioService(id: '4', name: 'Physiotherapist (Home/Online)', description: '', emoji: '🩺', tag: 'Women'),
  PhysioService(id: '5', name: 'Post Surgery Recovery',         description: '', emoji: '🏥', tag: 'Sports'),
  PhysioService(id: '6', name: 'Posture Correction',            description: '', emoji: '🧍', tag: 'Sports'),
  PhysioService(id: '7', name: 'Sports Injury Rehab',           description: '', emoji: '⚡', tag: 'Sports'),
  PhysioService(id: '8', name: 'Stroke Rehab',                  description: '', emoji: '🧠', tag: 'Sports'),
];

const List<String> kTimeSlots = [
  '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
  '12:00 PM', '2:00 PM', '3:00 PM', '4:00 PM',
  '5:00 PM',  '6:00 PM', '7:00 PM',
];


class PhysioScreen extends StatefulWidget {
  final String? categoryImageUrl;
  const PhysioScreen({super.key, this.categoryImageUrl});

  @override
  State<PhysioScreen> createState() => _PhysioScreenState();
}

class _PhysioScreenState extends State<PhysioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBookingComplete(Booking booking) {
    BookingStore.instance.addBooking(booking);

    final card = ScratchCardStore().createBookingReward(
      earnedFrom: 'Physio Booking',
      theme: ScratchTheme.gold,
    );
    ScratchCardStore().addCard(card);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        booking: booking,
        onDone: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            ScratchCardBottomSheet.show(
              context,
              card: card,
              onViewAll: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScratchRewardsPage()),
                );
              },
            );
          });
        },
      ),
    );
  }

  void _startBooking(BookingType type, [String? serviceName]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YogaServiceScreen(
          preSelectedServiceName: serviceName ?? 'Back / Neck / Knee Pain',
          categoryName: 'Physiotherapy',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _Header(
            categoryImageUrl: widget.categoryImageUrl,
            onDemo:    () => _startBooking(BookingType.demo),
            onEnquire: () => _startBooking(BookingType.enquire),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: kYellow,
              indicatorWeight: 3,
              labelColor: kTextDark,
              unselectedLabelColor: const Color(0xFFAAAAAA),
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                const Tab(text: 'Physio Plans'),
                Tab(
                  child: ListenableBuilder(
                    listenable: BookingStore.instance,
                    builder: (context, _) {
                      final count = BookingStore.instance.bookings
                          .where((b) =>
                              b.serviceCategory == ServiceCategory.physio)
                          .length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('My Bookings'),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: kYellow,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text('$count',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: kTextDark,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ServicesTab(
                  onDemo:    (name) => _startBooking(BookingType.demo, name),
                  onEnquire: (name) => _startBooking(BookingType.enquire, name),
                ),
                ListenableBuilder(
                  listenable: BookingStore.instance,
                  builder: (context, _) {
                    final bookings = BookingStore.instance.bookings
                        .where((b) =>
                            b.serviceCategory == ServiceCategory.physio)
                        .toList();
                    return _MyBookingsTab(bookings: bookings);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _Header extends StatelessWidget {
  final VoidCallback onDemo;
  final VoidCallback onEnquire;
  final String? categoryImageUrl;
  const _Header({required this.onDemo, required this.onEnquire, this.categoryImageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: categoryImageUrl != null && categoryImageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(ApiService.getMediaUrl(categoryImageUrl!)),
                fit: BoxFit.cover,
              )
            : const DecorationImage(
                image: AssetImage('assets/images/slider1.jpeg'),
                fit: BoxFit.cover,
              ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Physio',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SizedBox(height: 70),
          const SizedBox(height: 56),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


class _ServicesTab extends StatelessWidget {
  final void Function(String?) onDemo;
  final void Function(String?) onEnquire;
  const _ServicesTab({required this.onDemo, required this.onEnquire});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onDemo(null),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: kTextDark,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Text('Book Demo',
                          style: TextStyle(
                              color: kYellow,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                      Text('₹99 / session  •  Razorpay',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => onEnquire(null),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kYellowDark, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Text('Enquire',
                          style: TextStyle(
                              color: kTextDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                      Text('Free  •  Get your doubts cleared',
                          style: TextStyle(
                              color: kTextLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [kYellow, Color(0xFFFFEC5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Not sure which plan?',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kTextDark)),
                    const SizedBox(height: 4),
                    const Text(
                        'Enquire for FREE and our expert will guide you!',
                        style: TextStyle(
                            fontSize: 11, color: kTextMid, height: 1.4)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => onEnquire(null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                            color: kTextDark,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Enquire Free →',
                            style: TextStyle(
                                color: kYellow,
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
              const Text('🤔', style: TextStyle(fontSize: 42)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('AVAILABLE PLANS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFAAAAAA),
                letterSpacing: 1.2)),
        const SizedBox(height: 4),
        const Text('Tap a plan to Book Demo or Enquire',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 14),
        ...kServices.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ServiceTile(
                  service: s, onDemo: onDemo, onEnquire: onEnquire),
            )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kYellowLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Why Choose Us?',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kTextDark)),
              const SizedBox(height: 12),
              ...[
                ('🎓', 'Certified Physio Trainers with 5+ years experience'),
                ('📍', 'Home visits + Online consultations available'),
                ('📋', 'Personalised treatment plans, not generic ones'),
                ('🔁', 'Follow-up support included in every session'),
              ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(item.$1, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(item.$2,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: kTextMid,
                                    height: 1.4))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final PhysioService service;
  final void Function(String?) onDemo;
  final void Function(String?) onEnquire;
  const _ServiceTile(
      {required this.service, required this.onDemo, required this.onEnquire});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEE0A0), width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kYellow.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: kYellowLight, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Text(service.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kTextDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SmallModeBadge(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        color: kTextDark,
                        bg: kYellowLight),
                    const SizedBox(width: 5),
                    _SmallModeBadge(
                        icon: Icons.videocam_rounded,
                        label: 'Online',
                        color: kBlue,
                        bg: kBlueLight),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onDemo(service.name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                              color: kYellow,
                              borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: const Text('Book Demo ₹99',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: kTextDark)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onEnquire(service.name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: kYellow),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Enquire Free',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: kTextMid)),
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
    );
  }
}

class _SmallModeBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  const _SmallModeBadge(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 9, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}



class _MyBookingsTab extends StatelessWidget {
  final List<Booking> bookings;
  const _MyBookingsTab({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84, height: 84,
              decoration: BoxDecoration(
                  color: kYellowLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorder, width: 1.5)),
              alignment: Alignment.center,
              child: const Text('📋', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 16),
            const Text('No Bookings Yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: kTextDark)),
            const SizedBox(height: 6),
            const Text('Book a demo or enquire from\nthe Physio Plans tab!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kTextMid, height: 1.5)),
          ],
        ),
      );
    }

    final reversed = bookings.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: reversed.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _BookingCard(
            booking: reversed[i], index: reversed.length - i),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final int index;
  const _BookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context) {
    final t = booking.bookedAt;
    final bookedStr =
        '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';
    final isDemo   = booking.type == BookingType.demo;
    final isOnline = booking.serviceMode == ServiceMode.online;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kYellow),
        boxShadow: [
          BoxShadow(
              color: kYellow.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [kYellow, kYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(booking.service.emoji,
                      style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.service.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: kTextDark)),
                      Text(
                          '${isDemo ? "Demo" : "Enquiry"} #$index  ·  $bookedStr',
                          style: TextStyle(
                              fontSize: 11,
                              color: kTextMid.withOpacity(0.8))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDemo ? kTextDark : kGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDemo ? 'DEMO' : 'ENQUIRY',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isDemo ? kYellow : Colors.white,
                            letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOnline ? kBlue : kTextDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              isOnline
                                  ? Icons.videocam_rounded
                                  : Icons.home_rounded,
                              size: 9,
                              color: Colors.white),
                          const SizedBox(width: 3),
                          Text(isOnline ? 'ONLINE' : 'HOME',
                              style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isDemo
                ? _DemoCardDetails(booking: booking)
                : _EnquireCardDetails(booking: booking),
          ),
        ],
      ),
    );
  }
}

class _DemoCardDetails extends StatelessWidget {
  final Booking booking;
  const _DemoCardDetails({required this.booking});

  @override
  Widget build(BuildContext context) {
    final sd = booking.sessionDate!;
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final sessionStr =
        '${sd.day.toString().padLeft(2, '0')} ${monthNames[sd.month - 1]} ${sd.year}';
    final sessions  = booking.sessionCount ?? 1;
    final total     = 99 * sessions;
    final isOnline  = booking.serviceMode == ServiceMode.online;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isOnline ? kBlueLight : kYellowLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isOnline ? kBlue.withOpacity(0.3) : kYellow),
          ),
          child: Row(
            children: [
              Icon(isOnline ? Icons.videocam_rounded : Icons.home_rounded,
                  size: 14, color: isOnline ? kBlue : kTextDark),
              const SizedBox(width: 6),
              Text(
                isOnline
                    ? 'Online Session · Video Call'
                    : 'Home Visit · Physio Trainer comes to you',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isOnline ? kBlue : kTextDark),
              ),
            ],
          ),
        ),
        if (booking.customerName != null &&
            booking.customerName!.isNotEmpty) ...[
          _DetailRow(
              icon: Icons.person_rounded,
              label: 'Name',
              value: booking.customerName!),
          const SizedBox(height: 10),
        ],
        if (booking.customerPhone != null &&
            booking.customerPhone!.isNotEmpty) ...[
          _DetailRow(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: booking.customerPhone!),
          const SizedBox(height: 10),
        ],
        _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Session Date',
            value: sessionStr),
        const SizedBox(height: 10),
        _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'Time Slot',
            value: booking.timeSlot!),
        const SizedBox(height: 10),
        if (!isOnline) ...[
          _DetailRow(
              icon: Icons.location_on_rounded,
              label: 'Address',
              value: booking.address ?? '-'),
          const SizedBox(height: 10),
        ],
        _DetailRow(
            icon: Icons.repeat_rounded,
            label: 'Sessions',
            value: '$sessions session${sessions > 1 ? "s" : ""}'),
        const SizedBox(height: 10),
        _DetailRow(
            icon: Icons.payments_rounded,
            label: 'Payment',
            value: '₹$total  •  Cash at session'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: kTextDark, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
              Text('₹$total',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kYellow)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnquireCardDetails extends StatelessWidget {
  final Booking booking;
  const _EnquireCardDetails({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isOnline = booking.serviceMode == ServiceMode.online;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isOnline ? kBlueLight : kYellowLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isOnline ? kBlue.withOpacity(0.3) : kYellow),
          ),
          child: Row(
            children: [
              Icon(isOnline ? Icons.videocam_rounded : Icons.home_rounded,
                  size: 14, color: isOnline ? kBlue : kTextDark),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'Online Consultation' : 'Home Visit Enquiry',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isOnline ? kBlue : kTextDark),
              ),
            ],
          ),
        ),
        _DetailRow(
            icon: Icons.person_rounded,
            label: 'Name',
            value: booking.enquirerName ?? '-'),
        const SizedBox(height: 10),
        _DetailRow(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: booking.enquirerPhone ?? '-'),
        const SizedBox(height: 10),
        _DetailRow(
            icon: Icons.help_outline_rounded,
            label: 'Service Interest',
            value: booking.service.name),
        const SizedBox(height: 10),
        _DetailRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Doubt / Question',
            value: booking.doubtMessage ?? '-'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kGreenLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGreen.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Consultation Fee',
                  style: TextStyle(
                      fontSize: 13,
                      color: kTextMid,
                      fontWeight: FontWeight.w500)),
              Text('FREE',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kGreen)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
              color: kYellowLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: kTextMid),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: kTextLight,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      color: kTextDark,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}


class _BookingFlowSheet extends StatefulWidget {
  final BookingType type;
  final void Function(Booking) onComplete;
  const _BookingFlowSheet({required this.type, required this.onComplete});

  @override
  State<_BookingFlowSheet> createState() => _BookingFlowSheetState();
}

class _BookingFlowSheetState extends State<_BookingFlowSheet> {
  int _step = 0;

  PhysioService? _selectedService;
  ServiceMode _serviceMode = ServiceMode.home;

  DateTime? _selectedDate;
  String?   _selectedTime;
  final TextEditingController _addressCtrl   = TextEditingController();
  final TextEditingController _landmarkCtrl  = TextEditingController();
  final TextEditingController _custNameCtrl  = TextEditingController();
  final TextEditingController _custPhoneCtrl = TextEditingController();
  int _sessionCount = 1;

  final TextEditingController _nameCtrl  = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _doubtCtrl = TextEditingController();

  bool get _isDemo   => widget.type == BookingType.demo;
  bool get _isOnline => _serviceMode == ServiceMode.online;
  int  get _totalSteps => _isDemo ? (_isOnline ? 4 : 5) : 3;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _custNameCtrl.dispose();
    _custPhoneCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _doubtCtrl.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step++);
  void _back() {
    if (_step == 0) Navigator.pop(context);
    else setState(() => _step--);
  }

  void _confirmBooking() {
    final booking = Booking(
      bookingId:       'PB${DateTime.now().millisecondsSinceEpoch}',
      serviceCategory: ServiceCategory.physio,
      sourceScreen:    'Physio',
      service: BookedService(
        id:    _selectedService!.id,
        name:  _selectedService!.name,
        emoji: _selectedService!.emoji,
      ),
      type:        widget.type,
      serviceMode: _serviceMode,
      sessionDate:  _isDemo ? _selectedDate : null,
      timeSlot:     _isDemo ? _selectedTime  : null,
      address: (_isDemo && !_isOnline)
          ? '${_addressCtrl.text.trim()}${_landmarkCtrl.text.trim().isNotEmpty ? ', ${_landmarkCtrl.text.trim()}' : ''}'
          : (_isOnline ? 'Online Session' : null),
      sessionCount:  _isDemo ? _sessionCount : null,
      customerName:  (_isDemo && !_isOnline) ? _custNameCtrl.text.trim()  : null,
      customerPhone: (_isDemo && !_isOnline) ? _custPhoneCtrl.text.trim() : null,
      enquirerName:  !_isDemo ? _nameCtrl.text.trim()  : null,
      enquirerPhone: !_isDemo ? _phoneCtrl.text.trim() : null,
      doubtMessage:  !_isDemo ? _doubtCtrl.text.trim() : null,
      bookedAt: DateTime.now(), totalAmount: 99 * (_isDemo ? _sessionCount : 0),
    );
    Navigator.pop(context);
    widget.onComplete(booking);
  }

  bool _canProceed() {
    if (_isDemo) {
      switch (_step) {
        case 0: return _selectedService != null;
        case 1: return true;
        case 2: return _selectedDate != null && _selectedTime != null;
        case 3:
          if (_isOnline) return true;
          return _addressCtrl.text.trim().length >= 10 &&
              _custNameCtrl.text.trim().isNotEmpty &&
              _custPhoneCtrl.text.trim().length == 10;
        case 4: return true;
        default: return false;
      }
    } else {
      switch (_step) {
        case 0: return _selectedService != null;
        case 1:
          return _nameCtrl.text.trim().isNotEmpty &&
              _phoneCtrl.text.trim().length == 10 &&
              _doubtCtrl.text.trim().isNotEmpty;
        case 2: return true;
        default: return false;
      }
    }
  }

  bool get _isLastStep => _step == _totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _isDemo ? kYellow : kGreenLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _isDemo ? kYellowDark : kGreen.withOpacity(0.4)),
            ),
            child: Text(
              _isDemo
                  ? '📅  Book Demo  •  ₹99 / session  •  Cash only'
                  : '💬  Enquiry  •  Completely FREE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _isDemo ? kTextDark : kGreen),
            ),
          ),
          const SizedBox(height: 14),
          _StepIndicator(
            currentStep: _step,
            totalSteps:  _totalSteps,
            isDemo:      _isDemo,
            isOnline:    _isOnline,
          ),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!))),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _back,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                        border: Border.all(color: kBorder, width: 1.5),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(
                        _step == 0
                            ? Icons.close_rounded
                            : Icons.arrow_back_rounded,
                        color: kTextMid,
                        size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed()
                        ? (_isLastStep ? _confirmBooking : _next)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:         _isDemo ? kYellow : kGreen,
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _isLastStep
                          ? (_isDemo
                              ? 'Confirm  •  Cash ₹${99 * _sessionCount}'
                              : 'Submit Enquiry  •  FREE')
                          : 'Continue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _isDemo ? kTextDark : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    if (_isDemo) {
      switch (_step) {
        case 0:
          return _StepService(
              key: const ValueKey('s0'),
              selected: _selectedService,
              onSelect: (s) => setState(() => _selectedService = s));
        case 1:
          return _StepServiceMode(
              key: const ValueKey('s1'),
              selectedMode: _serviceMode,
              onSelect: (m) => setState(() => _serviceMode = m));
        case 2:
          return _StepDateTime(
              key: const ValueKey('s2'),
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onDatePick: (d) => setState(() => _selectedDate = d),
              onTimePick: (t) => setState(() => _selectedTime = t));
        case 3:
          if (_isOnline) {
            return _StepDemoConfirm(
                key: const ValueKey('s3o'),
                service:       _selectedService!,
                date:          _selectedDate!,
                time:          _selectedTime!,
                address:       'Online Session',
                landmark:      '',
                sessionCount:  _sessionCount,
                isOnline:      true,
                customerName:  null,
                customerPhone: null);
          }
          return _StepAddress(
              key: const ValueKey('s3h'),
              addressCtrl:          _addressCtrl,
              landmarkCtrl:         _landmarkCtrl,
              custNameCtrl:         _custNameCtrl,
              custPhoneCtrl:        _custPhoneCtrl,
              sessionCount:         _sessionCount,
              onSessionCountChange: (c) => setState(() => _sessionCount = c),
              onChanged: () => setState(() {}));
        case 4:
          return _StepDemoConfirm(
              key: const ValueKey('s4'),
              service:       _selectedService!,
              date:          _selectedDate!,
              time:          _selectedTime!,
              address:       _addressCtrl.text.trim(),
              landmark:      _landmarkCtrl.text.trim(),
              sessionCount:  _sessionCount,
              isOnline:      false,
              customerName:  _custNameCtrl.text.trim(),
              customerPhone: _custPhoneCtrl.text.trim());
        default:
          return const SizedBox();
      }
    } else {
      switch (_step) {
        case 0:
          return _StepService(
              key: const ValueKey('e0'),
              selected: _selectedService,
              onSelect: (s) => setState(() => _selectedService = s));
        case 1:
          return _StepEnquireDetails(
              key: const ValueKey('e1'),
              nameCtrl:  _nameCtrl,
              phoneCtrl: _phoneCtrl,
              doubtCtrl: _doubtCtrl,
              service:   _selectedService!,
              onChanged: () => setState(() {}));
        case 2:
          return _StepEnquireConfirm(
              key: const ValueKey('e2'),
              service: _selectedService!,
              name:    _nameCtrl.text.trim(),
              phone:   _phoneCtrl.text.trim(),
              doubt:   _doubtCtrl.text.trim());
        default:
          return const SizedBox();
      }
    }
  }
}


class _StepIndicator extends StatelessWidget {
  final int currentStep, totalSteps;
  final bool isDemo, isOnline;
  const _StepIndicator(
      {required this.currentStep,
      required this.totalSteps,
      required this.isDemo,
      required this.isOnline});

  @override
  Widget build(BuildContext context) {
    List<String> labels;
    if (isDemo) {
      labels = isOnline
          ? ['Service', 'Mode', 'Date & Time', 'Confirm']
          : ['Service', 'Mode', 'Date & Time', 'Address', 'Confirm'];
    } else {
      labels = ['Service', 'Your Details', 'Confirm'];
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final done   = i < currentStep;
          final active = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: done || active
                              ? kYellow
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(labels[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w400,
                            color: active
                                ? kTextDark
                                : done
                                    ? kTextMid
                                    : const Color(0xFFCCCCCC),
                          )),
                    ],
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}


class _StepService extends StatelessWidget {
  final PhysioService? selected;
  final void Function(PhysioService) onSelect;
  const _StepService(
      {super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose a Physio Plan',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text('Select the service that fits your goal',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 16),
        ...kServices.map((s) {
          final isSelected = selected?.id == s.id;
          return GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected ? kCardSel : Colors.white,
                border: Border.all(
                    color: isSelected ? kYellow : const Color(0xFFE8E8E8),
                    width: isSelected ? 2 : 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                        color: isSelected
                            ? kYellowLight
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child:
                        Text(s.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(s.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextDark)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? kYellow : Colors.transparent,
                      border: Border.all(
                          color: isSelected ? kYellowDark : kBorder,
                          width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: kTextDark, size: 13)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}


class _StepServiceMode extends StatelessWidget {
  final ServiceMode selectedMode;
  final void Function(ServiceMode) onSelect;
  const _StepServiceMode(
      {super.key, required this.selectedMode, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How do you prefer?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text('Choose your session mode',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 24),
        _ModeOption(
          mode: ServiceMode.home,
          selectedMode: selectedMode,
          icon: Icons.home_rounded,
          title: 'Home Visit',
          badgeLabel: 'Popular',
          desc: 'Our certified physio trainer visits your home',
          chips: [
            _FeatureChip(
                icon: Icons.location_on_rounded,
                label: 'Within 15 km',
                color: kTextDark),
            _FeatureChip(
                icon: Icons.people_rounded,
                label: 'In-person',
                color: kTextDark),
          ],
          selectedColor: kYellow,
          onTap: () => onSelect(ServiceMode.home),
        ),
        const SizedBox(height: 14),
        _ModeOption(
          mode: ServiceMode.online,
          selectedMode: selectedMode,
          icon: Icons.videocam_rounded,
          title: 'Online Session',
          badgeLabel: 'Anywhere',
          desc: 'Live video call with your physio trainer',
          chips: [
            _FeatureChip(
                icon: Icons.public_rounded,
                label: 'All India',
                color: kBlue),
            _FeatureChip(
                icon: Icons.wifi_rounded, label: 'Video Call', color: kBlue),
          ],
          selectedColor: const Color(0xFF1565C0),
          onTap: () => onSelect(ServiceMode.online),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kYellowLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Both modes are priced the same — ₹99 per session.',
                    style:
                        TextStyle(fontSize: 12, color: kTextMid, height: 1.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  final ServiceMode mode, selectedMode;
  final IconData icon;
  final String title, badgeLabel, desc;
  final List<Widget> chips;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ModeOption({
    required this.mode,
    required this.selectedMode,
    required this.icon,
    required this.title,
    required this.badgeLabel,
    required this.desc,
    required this.chips,
    required this.selectedColor,
    required this.onTap,
  });

  bool get isSelected => mode == selectedMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? (mode == ServiceMode.home ? kCardSel : kBlueLight)
              : Colors.white,
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: selectedColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor
                    : (mode == ServiceMode.home ? kYellowLight : kBlueLight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  color: isSelected
                      ? (mode == ServiceMode.home ? kTextDark : Colors.white)
                      : selectedColor,
                  size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: kTextDark)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: mode == ServiceMode.home
                                ? kYellow
                                : selectedColor,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(badgeLabel,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: mode == ServiceMode.home
                                    ? kTextDark
                                    : Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 12, color: kTextMid, height: 1.4)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 4, children: chips),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : Colors.transparent,
                border: Border.all(
                    color: isSelected
                        ? selectedColor
                        : const Color(0xFFDDDDDD),
                    width: 2),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      color: mode == ServiceMode.home
                          ? kTextDark
                          : Colors.white,
                      size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}


class _StepDateTime extends StatelessWidget {
  final DateTime? selectedDate;
  final String?   selectedTime;
  final void Function(DateTime) onDatePick;
  final void Function(String)   onTimePick;

  const _StepDateTime({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDatePick,
    required this.onTimePick,
  });

  Future<void> _openCalendar(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate:  now.add(const Duration(days: 60)),
      helpText:    'SELECT SESSION DATE',
      confirmText: 'CONFIRM',
      cancelText:  'CANCEL',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kYellowDark,
            onPrimary: kTextDark,
            onSurface: kTextDark,
            surface: Colors.white,
            secondary: kYellow,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: kTextDark,
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDatePick(picked);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const days = [
      'Monday','Tuesday','Wednesday','Thursday',
      'Friday','Saturday','Sunday'
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Date & Time',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text('Pick a convenient day and slot',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 24),
        const Text('SESSION DATE',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFAAAAAA),
                letterSpacing: 1.0)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _openCalendar(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: selectedDate != null ? kCardSel : Colors.white,
              border: Border.all(
                  color: selectedDate != null
                      ? kYellowDark
                      : const Color(0xFFE0E0E0),
                  width: selectedDate != null ? 2 : 1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: selectedDate != null
                  ? [
                      BoxShadow(
                          color: kYellow.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: selectedDate != null ? kYellow : kYellowLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month_rounded,
                      color: kTextDark, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Choose Session Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selectedDate != null
                          ? kTextDark
                          : const Color(0xFFBBBBBB),
                    ),
                  ),
                ),
                Icon(
                  selectedDate != null
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: selectedDate != null
                      ? kGreen
                      : const Color(0xFFCCCCCC),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (selectedDate != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _openCalendar(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.edit_calendar_rounded,
                    size: 13, color: kTextLight),
                SizedBox(width: 4),
                Text('Change date',
                    style: TextStyle(
                        fontSize: 11,
                        color: kTextLight,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text('AVAILABLE SLOTS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFAAAAAA),
                letterSpacing: 1.0)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kTimeSlots.map((slot) {
            final isSelected = slot == selectedTime;
            return GestureDetector(
              onTap: () => onTimePick(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? kYellow : Colors.white,
                  border: Border.all(
                      color: isSelected
                          ? kYellowDark
                          : const Color(0xFFE8E8E8),
                      width: isSelected ? 0 : 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(slot,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? kTextDark : kTextMid,
                    )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


class _StepAddress extends StatelessWidget {
  final TextEditingController addressCtrl;
  final TextEditingController landmarkCtrl;
  final TextEditingController custNameCtrl;
  final TextEditingController custPhoneCtrl;
  final int sessionCount;
  final void Function(int) onSessionCountChange;
  final VoidCallback onChanged;

  const _StepAddress({
    super.key,
    required this.addressCtrl,
    required this.landmarkCtrl,
    required this.custNameCtrl,
    required this.custPhoneCtrl,
    required this.sessionCount,
    required this.onSessionCountChange,
    required this.onChanged,
  });

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
      prefixIcon: Icon(icon, color: kTextLight, size: 20),
      filled: true,
      fillColor: const Color(0xFFFFFDF0),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8D000))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kYellow, width: 2)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Details & Address',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text('Our physio trainer will visit you at this location',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 24),
        _FieldLabel(label: 'Your Full Name *'),
        const SizedBox(height: 8),
        TextField(
          controller: custNameCtrl,
          onChanged: (_) => onChanged(),
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _inputDecoration(
              hint: 'Enter your full name', icon: Icons.person_rounded),
        ),
        const SizedBox(height: 16),
        _FieldLabel(label: 'Mobile Number *'),
        const SizedBox(height: 8),
        TextField(
          controller: custPhoneCtrl,
          onChanged: (_) => onChanged(),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _inputDecoration(
                  hint: '10-digit mobile number',
                  icon: Icons.phone_rounded)
              .copyWith(counterText: ''),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kYellowLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: const Row(
            children: [
              Text('📍', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Now enter your address where the trainer should visit.',
                    style:
                        TextStyle(fontSize: 12, color: kTextMid, height: 1.5)),
              ),
            ],
          ),
        ),
        _FieldLabel(label: 'Full Address *'),
        const SizedBox(height: 8),
        TextField(
          controller: addressCtrl,
          onChanged: (_) => onChanged(),
          maxLines: 3,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _inputDecoration(
              hint: 'House/Flat No., Street, Area, City...',
              icon: Icons.home_rounded),
        ),
        const SizedBox(height: 16),
        _FieldLabel(label: 'Landmark (Optional)'),
        const SizedBox(height: 8),
        TextField(
          controller: landmarkCtrl,
          onChanged: (_) => onChanged(),
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _inputDecoration(
              hint: 'Near bus stop, temple, school...',
              icon: Icons.place_rounded),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: kYellowLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder)),
          child: const Row(
            children: [
              Text('🏠', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Home visits within 15 km of Chennai. Online available anywhere.',
                    style:
                        TextStyle(fontSize: 12, color: kTextMid, height: 1.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


class _StepDemoConfirm extends StatelessWidget {
  final PhysioService service;
  final DateTime date;
  final String time, address, landmark;
  final int sessionCount;
  final bool isOnline;
  final String? customerName, customerPhone;

  const _StepDemoConfirm({
    super.key,
    required this.service,
    required this.date,
    required this.time,
    required this.address,
    required this.landmark,
    required this.sessionCount,
    required this.isOnline,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  Widget build(BuildContext context) {
    const monthNames = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final dateStr =
        '${date.day} ${monthNames[date.month - 1]} ${date.year}';
    final fullAddress = isOnline
        ? 'Online Session · Video Call'
        : (landmark.isNotEmpty ? '$address, $landmark' : address);
    final total = 99 * sessionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review & Confirm',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text('Confirm your demo booking details',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isOnline ? kBlueLight : kYellowLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isOnline ? kBlue.withOpacity(0.3) : kBorder),
          ),
          child: Row(
            children: [
              Icon(isOnline ? Icons.videocam_rounded : Icons.home_rounded,
                  size: 16, color: isOnline ? kBlue : kTextDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOnline
                      ? 'Online Session · Video Call'
                      : 'Home Visit · Physio Trainer comes to you',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOnline ? kBlue : kTextDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kYellowLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(service.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(service.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kTextDark)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE8D000), height: 1),
              const SizedBox(height: 12),
              if (!isOnline &&
                  customerName != null &&
                  customerName!.isNotEmpty) ...[
                _SummaryRow(icon: '👤', label: customerName!),
                const SizedBox(height: 6),
              ],
              if (!isOnline &&
                  customerPhone != null &&
                  customerPhone!.isNotEmpty) ...[
                _SummaryRow(icon: '📱', label: customerPhone!),
                const SizedBox(height: 6),
              ],
              _SummaryRow(icon: '📅', label: dateStr),
              const SizedBox(height: 6),
              _SummaryRow(icon: '🕐', label: time),
              const SizedBox(height: 6),
              _SummaryRow(
                  icon: isOnline ? '🖥️' : '📍', label: fullAddress),
              const SizedBox(height: 6),
              _SummaryRow(
                  icon: '🔁',
                  label:
                      '$sessionCount session${sessionCount > 1 ? "s" : ""} booked'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGreen.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Text('💵', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cash Payment Only',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kTextDark)),
                    Text(
                        'Pay directly to the physio trainer at session time',
                        style: TextStyle(
                            fontSize: 11, color: kTextMid, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: kTextDark, borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500)),
                  Text(
                      '₹99 × $sessionCount session${sessionCount > 1 ? "s" : ""}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white38)),
                ],
              ),
              Text('₹$total',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: kYellow)),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


class _StepEnquireDetails extends StatelessWidget {
  final TextEditingController nameCtrl, phoneCtrl, doubtCtrl;
  final PhysioService service;
  final VoidCallback onChanged;

  const _StepEnquireDetails({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.doubtCtrl,
    required this.service,
    required this.onChanged,
  });

  InputDecoration _dec({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
        prefixIcon: Icon(icon, color: kTextLight, size: 20),
        filled: true,
        fillColor: const Color(0xFFFFFDF0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8D000))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kYellow, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Details',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text("We'll call you back to clear your doubts — FREE!",
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
              color: kYellowLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(service.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Enquiry for: ${service.name}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kTextDark)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _FieldLabel(label: 'Your Full Name *'),
        const SizedBox(height: 8),
        TextField(
          controller: nameCtrl,
          onChanged: (_) => onChanged(),
          style: const TextStyle(fontSize: 14, color: kTextDark),
          textCapitalization: TextCapitalization.words,
          decoration:
              _dec(hint: 'Enter Your Name', icon: Icons.person_rounded),
        ),
        const SizedBox(height: 16),
        _FieldLabel(label: 'Mobile Number *'),
        const SizedBox(height: 8),
        TextField(
          controller: phoneCtrl,
          onChanged: (_) => onChanged(),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _dec(
                  hint: '10-digit mobile number',
                  icon: Icons.phone_rounded)
              .copyWith(counterText: ''),
        ),
        const SizedBox(height: 16),
        _FieldLabel(label: 'Your Doubt / Question *'),
        const SizedBox(height: 8),
        TextField(
          controller: doubtCtrl,
          onChanged: (_) => onChanged(),
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _dec(
              hint: 'e.g. I have knee pain — which therapy suits me?',
              icon: Icons.help_outline_rounded),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: kGreenLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGreen.withOpacity(0.3))),
          child: const Row(
            children: [
              Text('✅', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Our physio trainer will call you within 24 hours — completely FREE!',
                    style: TextStyle(
                        fontSize: 12, color: kTextMid, height: 1.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


class _StepEnquireConfirm extends StatelessWidget {
  final PhysioService service;
  final String name, phone, doubt;
  const _StepEnquireConfirm({
    super.key,
    required this.service,
    required this.name,
    required this.phone,
    required this.doubt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Enquiry',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text('Review your details before submitting',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kYellowLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(service.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(service.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kTextDark)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: kGreen,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('FREE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE8D000), height: 1),
              const SizedBox(height: 12),
              _SummaryRow(icon: '👤', label: name),
              const SizedBox(height: 6),
              _SummaryRow(icon: '📱', label: phone),
              const SizedBox(height: 6),
              _SummaryRow(icon: '💬', label: doubt),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: kGreenLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGreen.withOpacity(0.3))),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consultation Fee',
                      style: TextStyle(
                          fontSize: 12,
                          color: kTextMid,
                          fontWeight: FontWeight.w500)),
                  Text('Expert will call you back',
                      style: TextStyle(fontSize: 11, color: kTextLight)),
                ],
              ),
              Text('FREE',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: kGreen)),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}



class _SummaryRow extends StatelessWidget {
  final String icon, label;
  const _SummaryRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: kTextDark,
                    fontWeight: FontWeight.w500))),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: kTextMid));
}



class _SuccessDialog extends StatelessWidget {
  final Booking booking;
  final VoidCallback onDone;
  const _SuccessDialog({required this.booking, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final isDemo   = booking.type == BookingType.demo;
    final isOnline = booking.serviceMode == ServiceMode.online;
    const monthNames = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDemo
                      ? [kYellow, kYellowDark]
                      : [kGreen, const Color(0xFF00E5CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(isDemo ? '✅' : '💬',
                  style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 16),
            Text(
              isDemo ? 'Demo Booked!' : 'Enquiry Submitted!',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kTextDark),
            ),
            const SizedBox(height: 8),
            Text(
              isDemo
                  ? '₹${booking.totalAmount} to be paid in Cash at session'
                  : 'Our expert will call you within 24 hours',
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kYellowLight,
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(booking.service.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(booking.service.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kTextDark))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isDemo) ...[
                    Text(
                      '📅  ${booking.sessionDate!.day} ${monthNames[booking.sessionDate!.month - 1]} ${booking.sessionDate!.year}  ·  🕐  ${booking.timeSlot}',
                      style: const TextStyle(fontSize: 12, color: kTextMid),
                    ),
                    const SizedBox(height: 4),
                    if (isOnline)
                      const Text('🖥️  Online Session · Video Call',
                          style: TextStyle(fontSize: 12, color: kTextMid))
                    else
                      Text('📍  ${booking.address}',
                          style: const TextStyle(
                              fontSize: 12, color: kTextMid),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('💵  ₹${booking.totalAmount} Cash',
                        style: const TextStyle(
                            fontSize: 12, color: kTextMid)),
                  ] else ...[
                    Text('👤  ${booking.enquirerName}',
                        style: const TextStyle(
                            fontSize: 12, color: kTextMid)),
                    const SizedBox(height: 4),
                    Text('📱  ${booking.enquirerPhone}',
                        style: const TextStyle(
                            fontSize: 12, color: kTextMid)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFFD966),
                  Color(0xFFF9C413),
                  Color(0xFFE0AC00)
                ]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Text('🎁', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You earned a Scratch Card!',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: kTextDark)),
                        Text('Scratch & win cashback, discounts & more!',
                            style: TextStyle(
                                fontSize: 10,
                                color: kTextMid,
                                height: 1.3)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: kTextDark),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kYellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Scratch Your Reward 🎉',
                    style: TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}