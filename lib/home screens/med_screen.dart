import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrcoach/home%20screens/scratch_card_screen.dart';
import 'package:mrcoach/profile_settings_pages/booking_store.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:mrcoach/utils/razorpay_payment_helper.dart';

const Color kYellow      = Color(0xFFFFD54F);
const Color kYellowDark  = Color(0xFFFFC107);
const Color kYellowLight = Color(0xFFFFF8D6);
const Color kBg          = Color(0xFFFFFDE7);
const Color kTextDark    = Color(0xFF1A1200);
const Color kTextMid     = Color(0xFF5C4A00);
const Color kTextLight   = Color(0xFF9C8400);
const Color kBorder      = Color(0xFFFFB300);
const Color kCardSel     = Color(0xFFFFF9CC);
const Color kGreen       = Color(0xFF00BFA5);
const Color kGreenLight  = Color(0xFFE0F7F4);
const Color kBlue        = Color(0xFF000000);
const Color kBlueLight   = Color(0xFFE8F0FF);

class DietService {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const DietService({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

const List<DietService> kServices = [
  DietService(id: '0', name: 'Diabetic Diet',            description: 'Blood sugar management & balanced nutrition',    emoji: '🩸'),
  DietService(id: '1', name: 'Kids Diet',                description: 'Growth-focused healthy meal plans for children', emoji: '🧒'),
  DietService(id: '2', name: 'Muscle Gain Diet',         description: 'High-protein plans for muscle building',          emoji: '💪'),
  DietService(id: '3', name: 'Online Diet Consultation', description: 'Live 1-on-1 session with expert dietitian',       emoji: '🖥️'),
  DietService(id: '4', name: 'PCOS Diet',                description: 'Hormone-balancing nutrition for PCOS',            emoji: '🌸'),
  DietService(id: '5', name: 'Sports Nutrition',         description: 'Performance & recovery fuel for athletes',        emoji: '🏅'),
  DietService(id: '6', name: 'Weight Loss Diet',         description: 'Sustainable, science-backed fat loss plans',      emoji: '⚖️'),
];

const List<String> kTimeSlots = [
  '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
  '12:00 PM', '2:00 PM', '3:00 PM',  '4:00 PM',
  '5:00 PM',  '6:00 PM', '7:00 PM',
];

// Reference lists for the expanded "Your Details & Address" step.
const List<String> kWeekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const List<String> kReferralSources = [
  'Instagram', 'Facebook', 'Google Search', 'Friend / Family', 'WhatsApp', 'Other',
];

class PriceTier {
  final String label;
  final String sublabel;
  final IconData icon;
  final double min, max;
  const PriceTier({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.min,
    required this.max,
  });
}

const List<PriceTier> kPriceTiers = [
  PriceTier(label: '₹600 - ₹700',     sublabel: 'Entry Level Dietitians',    icon: Icons.person_outline_rounded, min: 600,    max: 700),
  PriceTier(label: '₹700 - ₹1000',  sublabel: 'Entry to Mid Level',     icon: Icons.person_rounded,         min: 700,  max: 1000),
  PriceTier(label: '₹1000 - ₹1200', sublabel: 'Medium Level',           icon: Icons.headset_mic_rounded,    min: 1000, max: 1200),
  PriceTier(label: '₹1200 - ₹3000+',sublabel: 'Premium / Expert Level', icon: Icons.workspace_premium_rounded, min: 1200, max: 3000),
];

/// Single accent colour reused across every price tier — same fix that
/// was applied on the Sports/Fitness screens so the slider doesn't flash
/// between different colours as the user drags/taps through tiers.
const List<Color> kPriceTierColors = [
  kYellowDark,
  kYellowDark,
  kYellowDark,
  kYellowDark,
];

class DietBooking1Screen extends StatefulWidget {
  final String? preSelectedServiceName;
  const DietBooking1Screen({super.key, this.preSelectedServiceName});

  @override
  State<DietBooking1Screen> createState() => _DietBooking1ScreenState();
}

class _DietBooking1ScreenState extends State<DietBooking1Screen> {

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedServiceName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final incoming = widget.preSelectedServiceName!.toLowerCase().trim();
        final matched = kServices.firstWhere(
          (s) => s.name.toLowerCase().trim() == incoming,
          orElse: () => kServices.first,
        );
        _startBookingWithService(matched);
      });
    }
  }

  void _onBookingComplete(Booking booking) {
    BookingStore.instance.addBooking(booking);

    final card = ScratchCardStore().createBookingReward(
      earnedFrom: 'Diet Booking',
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

  void _startBooking(BookingType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _BookingFlowSheet(type: type, onComplete: _onBookingComplete),
    );
  }

  // Used by the arrow button on each plan card — pre-selects that one
  // service so the "Choose a Plan" step opens with it already checked.
  // The user can still ADD more services from inside the sheet (multi-select).
  void _startBookingWithService(DietService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingFlowSheet(
        type: BookingType.demo,
        onComplete: _onBookingComplete,
        initialService: service,
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
            onDemo:    () => _startBooking(BookingType.demo),
            onEnquire: () => _startBooking(BookingType.enquire),
          ),
          Expanded(
            child: _ServicesTab(
              onDemo:    () => _startBooking(BookingType.demo),
              onEnquire: () => _startBooking(BookingType.enquire),
              onSelectService: _startBookingWithService,
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
  const _Header({required this.onDemo, required this.onEnquire});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (ApiService.cachedDynamicInnerBannerMap?['Nutrition'] != null && ApiService.cachedDynamicInnerBannerMap!['Nutrition']!.isNotEmpty)
              ? NetworkImage(ApiService.getMediaUrl(ApiService.cachedDynamicInnerBannerMap!['Nutrition']!)) as ImageProvider
              : const AssetImage('assets/images/slider1.jpeg'),
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
                child: const Text('Diet',
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
  final VoidCallback onDemo;
  final VoidCallback onEnquire;
  final void Function(DietService) onSelectService;
  const _ServicesTab({
    required this.onDemo,
    required this.onEnquire,
    required this.onSelectService,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      children: [Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onDemo,
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
                      Text('₹99 / session  •  Pay Online',
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
                onTap: onEnquire,
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
                        style:
                            TextStyle(fontSize: 11, color: kTextMid, height: 1.4)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: onEnquire,
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
                  service: s,
                  onDemo: onDemo,
                  onEnquire: onEnquire,
                  onSelect: () => onSelectService(s)),
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
                ('🎓', 'Certified Dietitian with 5-10+ years experience'),
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
  final DietService service;
  final VoidCallback onDemo;
  final VoidCallback onEnquire;
  final VoidCallback onSelect;
  const _ServiceTile({
    required this.service,
    required this.onDemo,
    required this.onEnquire,
    required this.onSelect,
  });

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
                color: kYellowLight,
                borderRadius: BorderRadius.circular(14)),
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSelect,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: kYellowLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEE0A0)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: kTextDark),
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

class _BookingFlowSheet extends StatefulWidget {
  final BookingType type;
  final void Function(Booking) onComplete;
  final DietService? initialService;
  const _BookingFlowSheet({
    required this.type,
    required this.onComplete,
    this.initialService,
  });

  @override
  State<_BookingFlowSheet> createState() => _BookingFlowSheetState();
}

class _BookingFlowSheetState extends State<_BookingFlowSheet> {
  late int _step;
  bool _submitting = false;

  // Real multi-select: user can tick more than one service — same
  // pattern used on the Sports/Fitness screens.
  final Set<DietService> _selectedServices = {};
  ServiceMode _serviceMode = ServiceMode.home;

  DateTime? _selectedDate;
  String?   _selectedTime;
  final TextEditingController _addressCtrl   = TextEditingController();
  final TextEditingController _landmarkCtrl  = TextEditingController();
  final TextEditingController _custNameCtrl  = TextEditingController();
  final TextEditingController _custPhoneCtrl = TextEditingController();
  int _sessionCount = 1;

  // --- Extra fields for the expanded "Your Details & Address" step ---
  final TextEditingController _emailCtrl    = TextEditingController();
  String? _selectedGender;

  final TextEditingController _stateCtrl    = TextEditingController();
  final TextEditingController _districtCtrl = TextEditingController();
  final TextEditingController _areaCtrl     = TextEditingController();
  final TextEditingController _pincodeCtrl  = TextEditingController();

  DateTime? _planStartDate;
  final Set<String> _availableDays = {};
  String _referralSource = kReferralSources.first;

  RangeValues _priceRange = const RangeValues(0, 700);
  final TextEditingController _voucherCtrl = TextEditingController();
  String? _voucherStatus;

  final TextEditingController _nameCtrl  = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _doubtCtrl = TextEditingController();

  bool get _isDemo   => widget.type == BookingType.demo;
  bool get _isOnline => _serviceMode == ServiceMode.online;
  int  get _totalSteps => _isDemo ? (_isOnline ? 4 : 5) : 3;

  @override
  void initState() {
    super.initState();
    // Arrow button on the plan list pre-ticks that one service; user can
    // still add more from inside the sheet since selection is multi-select.
    if (widget.initialService != null) {
      _selectedServices.add(widget.initialService!);
    }
    _step = 0;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _custNameCtrl.dispose();
    _custPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _areaCtrl.dispose();
    _pincodeCtrl.dispose();
    _voucherCtrl.dispose();
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

  void _toggleService(DietService s) {
    setState(() {
      if (_selectedServices.contains(s)) {
        _selectedServices.remove(s);
      } else {
        _selectedServices.add(s);
      }
    });
  }

  void _applyVoucher() {
    final code = _voucherCtrl.text.trim();
    setState(() {
      _voucherStatus = code.isEmpty
          ? null
          : 'Voucher "$code" will be verified at session time.';
    });
  }

  void _confirmBooking() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
    });

    // Extra fields captured below (email, gender, state, district, area,
    // pincode, plan start date, available days, referral source, price
    // preference, voucher code) aren't part of the current `Booking`
    // model, so — same as Sports/Fitness — they're folded into the
    // address string until `Booking` is extended.
    final extraDetailsParts = <String>[
      if (_emailCtrl.text.trim().isNotEmpty) 'Email: ${_emailCtrl.text.trim()}',
      if (_selectedGender != null) 'Gender: $_selectedGender',
      if (_stateCtrl.text.trim().isNotEmpty || _districtCtrl.text.trim().isNotEmpty)
        'Location: ${_stateCtrl.text.trim()}${_districtCtrl.text.trim().isNotEmpty ? ", ${_districtCtrl.text.trim()}" : ""}',
      if (_areaCtrl.text.trim().isNotEmpty) 'Area: ${_areaCtrl.text.trim()}',
      if (_pincodeCtrl.text.trim().isNotEmpty) 'Pincode: ${_pincodeCtrl.text.trim()}',
      if (_planStartDate != null)
        'Plan start: ${_planStartDate!.day}/${_planStartDate!.month}/${_planStartDate!.year}',
      if (_availableDays.isNotEmpty) 'Available days: ${_availableDays.join(", ")}',
      'Heard via: $_referralSource',
      'Price preference: ₹${_priceRange.start.round()} - ₹${_priceRange.end.round()}',
      if (_voucherCtrl.text.trim().isNotEmpty) 'Voucher: ${_voucherCtrl.text.trim()}',
    ];
    final extraDetails = extraDetailsParts.join(' | ');

    final baseAddress = (_isDemo && !_isOnline)
        ? '${_addressCtrl.text.trim()}${_landmarkCtrl.text.trim().isNotEmpty ? ', ${_landmarkCtrl.text.trim()}' : ''}'
        : (_isOnline ? 'Online Session' : null);

    final servicesList = _selectedServices.toList();
    final primary = servicesList.first;
    final rest = servicesList.skip(1).map((s) => BookedService(
          id: s.id,
          name: s.name,
          emoji: s.emoji,
        )).toList();

    final serviceNameString = servicesList.map((s) => s.name).join(', ');
    final subcategoriesList = servicesList.map((s) => s.name).toList();

    final String finalAddress = (_isDemo && !_isOnline)
        ? '$baseAddress  [$extraDetails]'
        : (baseAddress ?? (_isOnline ? 'Online Session' : ''));

    final String finalName = _isDemo
        ? (!_isOnline ? _custNameCtrl.text.trim() : 'Not Provided')
        : _nameCtrl.text.trim();

    final String finalPhone = _isDemo
        ? (!_isOnline ? _custPhoneCtrl.text.trim() : 'Not Provided')
        : _phoneCtrl.text.trim();

    final double price = _isDemo ? 99.0 * _sessionCount : 0.0;
    if (_isDemo && price > 0) {
      RazorpayPaymentFlow.start(
        context: context,
        price: price,
        contact: finalPhone,
        email: _emailCtrl.text.trim(),
        onSuccess: () {
          _submitBookingToBackend(
            serviceNameString: serviceNameString,
            finalPhone: finalPhone,
            finalAddress: finalAddress,
            finalName: finalName,
            subcategoriesList: subcategoriesList,
            extraDetails: extraDetails,
            baseAddress: baseAddress,
            primary: primary,
            rest: rest,
          );
        },
        onCancel: () {
          setState(() {
            _submitting = false;
          });
        },
      );
    } else {
      _submitBookingToBackend(
        serviceNameString: serviceNameString,
        finalPhone: finalPhone,
        finalAddress: finalAddress,
        finalName: finalName,
        subcategoriesList: subcategoriesList,
        extraDetails: extraDetails,
        baseAddress: baseAddress,
        primary: primary,
        rest: rest,
      );
    }
  }

  void _submitBookingToBackend({
    required String serviceNameString,
    required String finalPhone,
    required String finalAddress,
    required String finalName,
    required List<String> subcategoriesList,
    required String extraDetails,
    required String? baseAddress,
    required DietService primary,
    required List<BookedService> rest,
  }) async {
    final result = await ApiService.createBooking({
      'serviceName': serviceNameString,
      'coachName': 'Pending Assignment',
      'date': _isDemo && _selectedDate != null
          ? _selectedDate!.toIso8601String().split('T')[0]
          : DateTime.now().toIso8601String().split('T')[0],
      'time': _isDemo ? (_selectedTime ?? 'N/A') : 'N/A',
      'price': _isDemo ? 99.0 * _sessionCount : 0.0,
      'mode': _isOnline ? 'Online' : 'Home Visit',
      'bookingType': _isDemo ? 'Demo' : 'Enquiry',
      'mobileNumber': finalPhone.isNotEmpty ? finalPhone : 'Not Provided',
      'address': finalAddress,
      'name': finalName.isNotEmpty ? finalName : 'Not Provided',
      'email': _emailCtrl.text.trim(),
      'gender': _selectedGender ?? '',
      'state': _stateCtrl.text.trim(),
      'district': _districtCtrl.text.trim(),
      'area': _areaCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'startPlan': _planStartDate != null ? _planStartDate!.toIso8601String().split('T')[0] : '',
      'availableDays': _availableDays.toList(),
      'sourceWebsite': _referralSource,
      'category': 'Diet',
      'subcategories': subcategoriesList,
      'priceRange': '₹${_priceRange.start.round()} - ₹${_priceRange.end.round()}',
    });

    if (!result['success']) {
      setState(() {
        _submitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final booking = Booking(
      bookingId:       'DB${DateTime.now().millisecondsSinceEpoch}',
      serviceCategory: ServiceCategory.diet,
      sourceScreen:    'Diet',
      service: BookedService(
        id:    primary.id,
        name:  primary.name,
        emoji: primary.emoji,
      ),
      additionalServices: rest.isNotEmpty ? rest : null,
      type:        widget.type,
      serviceMode: _serviceMode,
      sessionDate:  _isDemo ? _selectedDate : null,
      timeSlot:     _isDemo ? _selectedTime  : null,
      address: (_isDemo && !_isOnline)
          ? '$baseAddress  [$extraDetails]'
          : baseAddress,
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
        case 0: return _selectedServices.isNotEmpty;
        case 1: return true;
        case 2: return _selectedDate != null && _selectedTime != null;
        case 3:
          if (_isOnline) return true;
          return _addressCtrl.text.trim().isNotEmpty &&
              _custNameCtrl.text.trim().isNotEmpty &&
              _custPhoneCtrl.text.trim().length == 10;
        case 4: return true;
        default: return false;
      }
    } else {
      switch (_step) {
        case 0: return _selectedServices.isNotEmpty;
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
    final showAmountSummary =
        _isDemo && (_isLastStep || (_step == 3 && !_isOnline));
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
                  ? '📅  Book Demo  •  ₹99 / session  •  Pay Online'
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showAmountSummary) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Demo session subtotal',
                          style: TextStyle(
                              fontSize: 13,
                              color: kTextLight,
                              fontWeight: FontWeight.w500)),
                      Text('₹${99 * _sessionCount}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: kTextDark,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payable',
                          style: TextStyle(
                              fontSize: 15,
                              color: kTextDark,
                              fontWeight: FontWeight.w900)),
                      Text('₹${99 * _sessionCount}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: kTextDark,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 12),
                ],
                Row(
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
                        onPressed: _canProceed() && !_submitting
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
                        child: _submitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _isDemo ? kTextDark : Colors.white),
                                ),
                              )
                            : Text(
                                _isLastStep
                                    ? (_isDemo
                                        ? 'Pay Now  •  ₹${99 * _sessionCount}'
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
              selected: _selectedServices,
              onToggle: _toggleService);
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
                services:      _selectedServices.toList(),
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
              selectedServices:     _selectedServices.toList(),
              mode:                 _serviceMode,
              date:                 _selectedDate,
              time:                 _selectedTime,
              addressCtrl:          _addressCtrl,
              landmarkCtrl:         _landmarkCtrl,
              custNameCtrl:         _custNameCtrl,
              custPhoneCtrl:        _custPhoneCtrl,
              emailCtrl:            _emailCtrl,
              sessionCount:         _sessionCount,
              onSessionCountChange: (c) => setState(() => _sessionCount = c),
              selectedGender:       _selectedGender,
              onGenderSelect:       (g) => setState(() => _selectedGender = g),
              stateCtrl:            _stateCtrl,
              districtCtrl:         _districtCtrl,
              areaCtrl:             _areaCtrl,
              pincodeCtrl:          _pincodeCtrl,
              planStartDate:        _planStartDate,
              onPlanStartDatePick:  (d) => setState(() => _planStartDate = d),
              availableDays:        _availableDays,
              onToggleDay: (d) => setState(() {
                    _availableDays.contains(d)
                        ? _availableDays.remove(d)
                        : _availableDays.add(d);
                  }),
              referralSource:       _referralSource,
              onReferralChange:     (v) => setState(() => _referralSource = v),
              priceRange:           _priceRange,
              onPriceRangeChange:   (r) => setState(() => _priceRange = r),
              voucherCtrl:          _voucherCtrl,
              voucherStatus:        _voucherStatus,
              onApplyVoucher:       _applyVoucher,
              onChanged: () => setState(() {}));
        case 4:
          return _StepDemoConfirm(
              key: const ValueKey('s4'),
              services:      _selectedServices.toList(),
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
              selected: _selectedServices,
              onToggle: _toggleService);
        case 1:
          return _StepEnquireDetails(
              key: const ValueKey('e1'),
              nameCtrl:  _nameCtrl,
              phoneCtrl: _phoneCtrl,
              doubtCtrl: _doubtCtrl,
              services:  _selectedServices.toList(),
              onChanged: () => setState(() {}));
        case 2:
          return _StepEnquireConfirm(
              key: const ValueKey('e2'),
              services: _selectedServices.toList(),
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
          ? ['Services', 'Mode', 'Date & Time', 'Confirm']
          : ['Services', 'Mode', 'Date & Time', 'Address', 'Confirm'];
    } else {
      labels = ['Services', 'Your Details', 'Confirm'];
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


/// Step 0 — choose one OR MORE services.
/// Tapping a row TOGGLES it in/out of the selection (checkbox style,
/// square tick box, multiple rows can stay highlighted at once) —
/// same behaviour as the Sports/Fitness screens.
class _StepService extends StatelessWidget {
  final Set<DietService> selected;
  final void Function(DietService) onToggle;
  const _StepService(
      {super.key, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Diet Plan(s)',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 4),
        const Text('You can select more than one service',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
                color: kYellowLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder)),
            child: Text(
                '${selected.length} service${selected.length > 1 ? "s" : ""} selected',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: kTextDark)),
          ),
        ],
        const SizedBox(height: 16),
        ...kServices.map((s) {
          final isSelected = selected.contains(s);
          return GestureDetector(
            onTap: () => onToggle(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                  // Square checkbox (not circular) so multi-select reads
                  // clearly as "tick as many as you want".
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? kYellow : Colors.transparent,
                      border: Border.all(
                          color: isSelected ? kYellowDark : kBorder,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: kTextDark, size: 15)
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
          desc: 'Our certified Dietitian trainer visits your home',
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
          desc: 'Live video call with your Dietitian trainer',
          chips: [
            _FeatureChip(
                icon: Icons.public_rounded,
                label: 'All India',
                color: kBlue),
            _FeatureChip(
                icon: Icons.wifi_rounded,
                label: 'Video Call',
                color: kBlue),
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
                child: Text('Both modes are priced the same — ₹99 per session.',
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

/// Reusable "SECTION LABEL" heading used throughout the expanded
/// Your Details & Address step.
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFAAAAAA),
                letterSpacing: 1.0)),
      );
}

/// Step 3 (home visit) — expanded "Your Details & Address" step.
/// Shows ALL selected services (multi-select) as chips, matching the
/// Sports/Fitness screen pattern.
class _StepAddress extends StatelessWidget {
  final List<DietService> selectedServices;
  final ServiceMode mode;
  final DateTime? date;
  final String? time;

  final TextEditingController addressCtrl;
  final TextEditingController landmarkCtrl;
  final TextEditingController custNameCtrl;
  final TextEditingController custPhoneCtrl;
  final TextEditingController emailCtrl;
  final int sessionCount;
  final void Function(int) onSessionCountChange;

  final String? selectedGender;
  final void Function(String) onGenderSelect;

  final TextEditingController stateCtrl;
  final TextEditingController districtCtrl;
  final TextEditingController areaCtrl;
  final TextEditingController pincodeCtrl;

  final DateTime? planStartDate;
  final void Function(DateTime) onPlanStartDatePick;
  final Set<String> availableDays;
  final void Function(String) onToggleDay;
  final String referralSource;
  final void Function(String) onReferralChange;

  final RangeValues priceRange;
  final void Function(RangeValues) onPriceRangeChange;

  final TextEditingController voucherCtrl;
  final String? voucherStatus;
  final VoidCallback onApplyVoucher;

  final VoidCallback onChanged;

  const _StepAddress({
    super.key,
    required this.selectedServices,
    required this.mode,
    required this.date,
    required this.time,
    required this.addressCtrl,
    required this.landmarkCtrl,
    required this.custNameCtrl,
    required this.custPhoneCtrl,
    required this.emailCtrl,
    required this.sessionCount,
    required this.onSessionCountChange,
    required this.selectedGender,
    required this.onGenderSelect,
    required this.stateCtrl,
    required this.districtCtrl,
    required this.areaCtrl,
    required this.pincodeCtrl,
    required this.planStartDate,
    required this.onPlanStartDatePick,
    required this.availableDays,
    required this.onToggleDay,
    required this.referralSource,
    required this.onReferralChange,
    required this.priceRange,
    required this.onPriceRangeChange,
    required this.voucherCtrl,
    required this.voucherStatus,
    required this.onApplyVoucher,
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

  Future<void> _pickPlanStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: planStartDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      helpText: 'SELECT PLAN START DATE',
      confirmText: 'CONFIRM',
      cancelText: 'CANCEL',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kYellowDark,
            onPrimary: kTextDark,
            onSurface: kTextDark,
            surface: Colors.white,
            secondary: kYellow,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPlanStartDatePick(picked);
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
        const Text('Review your session and fill in your details',
            style: TextStyle(fontSize: 12, color: kTextLight)),
        const SizedBox(height: 18),

        // Mode / Date / Time summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: kGreenLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _InfoRow(
                  icon: mode == ServiceMode.online
                      ? Icons.videocam_rounded
                      : Icons.home_rounded,
                  label: 'Mode',
                  value: mode == ServiceMode.online
                      ? 'Online Session'
                      : 'Home Visit'),
              const Divider(height: 1, color: Color(0xFFD9F0EA)),
              _InfoRow(
                  icon: Icons.calendar_month_rounded,
                  label: 'Date',
                  value: date != null
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : '—'),
              const Divider(height: 1, color: Color(0xFFD9F0EA)),
              _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: time ?? '—',
                  showDivider: false),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected services — shows ALL ticked services as chips.
        const _SectionLabel(label: 'SELECTED SERVICES'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedServices
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(s.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kTextDark)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 18),

        // Contact details
        const _SectionLabel(label: 'CONTACT DETAILS'),
        TextField(
          controller: custNameCtrl,
          onChanged: (_) => onChanged(),
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _inputDecoration(
              hint: 'Enter your full name', icon: Icons.person_rounded),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailCtrl,
          onChanged: (_) => onChanged(),
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: _inputDecoration(
              hint: 'Email address (Optional)', icon: Icons.email_rounded),
        ),
        const SizedBox(height: 12),
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
        if (custPhoneCtrl.text.isNotEmpty &&
            custPhoneCtrl.text.trim().length != 10) ...[
          const SizedBox(height: 6),
          const Text('Please enter a valid phone number',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 18),

        // Personal details
        const _SectionLabel(label: 'PERSONAL DETAILS'),
        const Text('Gender (Optional)',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            final isSelected = selectedGender == g;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: g != 'Other' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onGenderSelect(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? kCardSel : Colors.white,
                      border: Border.all(
                          color:
                              isSelected ? kYellowDark : const Color(0xFFE0E0E0),
                          width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(g,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kTextDark)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Location details
        const _SectionLabel(label: 'LOCATION DETAILS'),
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: stateCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(fontSize: 13, color: kTextDark),
                decoration: _inputDecoration(hint: 'State (Optional)', icon: Icons.map_rounded),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: districtCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(fontSize: 13, color: kTextDark),
                decoration: _inputDecoration(
                    hint: 'District (Optional)', icon: Icons.location_city_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: areaCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(fontSize: 13, color: kTextDark),
                decoration: _inputDecoration(
                    hint: 'Area / Locality (Optional)', icon: Icons.near_me_rounded),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: pincodeCtrl,
                onChanged: (_) => onChanged(),
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 13, color: kTextDark),
                decoration: _inputDecoration(
                        hint: 'Pincode (Optional)', icon: Icons.pin_drop_rounded)
                    .copyWith(counterText: ''),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('How did you hear about us? (Optional)',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF0),
            border: Border.all(color: const Color(0xFFE8D000)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: referralSource,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: kTextLight),
              style: const TextStyle(fontSize: 13, color: kTextDark),
              items: kReferralSources
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onReferralChange(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Price preference
        const _SectionLabel(label: 'PRICE PREFERENCE'),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                  'Please provide the pricing range for coaching services.',
                  style: TextStyle(
                      fontSize: 11, color: kTextLight, height: 1.4)),
            ),
            const SizedBox(width: 6),
            Icon(Icons.info_outline_rounded,
                size: 14, color: Colors.grey[400]),
          ],
        ),
        const SizedBox(height: 18),

        _CatPriceSlider(
          value: kPriceTiers
              .indexWhere((t) =>
                  t.min == priceRange.start && t.max == priceRange.end)
              .clamp(0, kPriceTiers.length - 1),
          colors: kPriceTierColors,
          onChanged: (i) => onPriceRangeChange(
              RangeValues(kPriceTiers[i].min, kPriceTiers[i].max)),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: kPriceTiers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final t = kPriceTiers[index];
              // Only the SELECTED tier shows a colour — every other tier
              // stays neutral grey so the row doesn't look "all lit up"
              // at once. Selected uses the shared yellow accent.
              final isSel =
                  priceRange.start == t.min && priceRange.end == t.max;
              const neutral = Color(0xFFB0B0B0);
              final tierColor = isSel ? kYellowDark : neutral;
              return GestureDetector(
                onTap: () =>
                    onPriceRangeChange(RangeValues(t.min, t.max)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 136,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? kYellowLight : Colors.white,
                    border: Border.all(
                        color: isSel ? kYellowDark : const Color(0xFFE0E0E0),
                        width: isSel ? 1.5 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(t.icon, size: 13, color: tierColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(t.label,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isSel ? kTextDark : neutral)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(t.sublabel,
                          style: TextStyle(
                              fontSize: 10,
                              color: isSel
                                  ? kTextMid
                                  : neutral.withOpacity(0.85))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 22),

        // Voucher
        const _SectionLabel(label: 'VOUCHER / PROMO CODE (OPTIONAL)'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: voucherCtrl,
                onChanged: (_) => onChanged(),
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 14, color: kTextDark),
                decoration: _inputDecoration(
                    hint: 'Enter voucher code (Optional)', icon: Icons.card_giftcard_rounded),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onApplyVoucher,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                    color: kYellow, borderRadius: BorderRadius.circular(14)),
                child: const Text('Apply',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: kTextDark)),
              ),
            ),
          ],
        ),
        if (voucherStatus != null) ...[
          const SizedBox(height: 8),
          Text(voucherStatus!,
              style: const TextStyle(fontSize: 11, color: kTextMid)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool showDivider;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: kGreen),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: kGreen,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  color: kTextDark,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StepDemoConfirm extends StatelessWidget {
  final List<DietService> services;
  final DateTime date;
  final String time, address, landmark;
  final int sessionCount;
  final bool isOnline;
  final String? customerName, customerPhone;

  const _StepDemoConfirm({
    super.key,
    required this.services,
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
                      : 'Home Visit · Dietitian Trainer comes to you',
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
              // Show ALL selected services, not just one.
              ...services.map((service) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text(service.emoji,
                              style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(service.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: kTextDark)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 6),
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
                        'Pay directly to the dietitian trainer at session time',
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
  final List<DietService> services;
  final VoidCallback onChanged;

  const _StepEnquireDetails({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.doubtCtrl,
    required this.services,
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
    final serviceNames = services.map((s) => s.name).join(', ');
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
              color: kYellowLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder)),
          child: Text('Enquiry for: $serviceNames',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kTextDark)),
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
          decoration:
              _dec(hint: '10-digit mobile number', icon: Icons.phone_rounded)
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
              hint: 'e.g. I want to lose weight — which plan suits me?',
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
                    'Our dietitian trainer will call you within 24 hours — completely FREE!',
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
  final List<DietService> services;
  final String name, phone, doubt;
  const _StepEnquireConfirm({
    super.key,
    required this.services,
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
              ...services.map((service) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text(service.emoji,
                              style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(service.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: kTextDark)),
                        ),
                      ],
                    ),
                  )),
              Row(
                children: [
                  const Spacer(),
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
              const SizedBox(height: 6),
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
    final allServiceNames = [
      booking.service.name,
      ...?booking.additionalServices?.map((s) => s.name),
    ].join(', ');

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
                          child: Text(allServiceNames,
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

/// Draggable / tappable slider used in the "Price Preference" section.
/// `value` is the currently-selected index into [kPriceTiers] (0..3).
/// Uses a single fixed yellow accent throughout — same fix ported from
/// the Sports/Fitness screens so the slider doesn't flash different
/// colours as the user drags/taps between tiers.
class _CatPriceSlider extends StatefulWidget {
  final int value;
  final List<Color> colors;
  final void Function(int) onChanged;
  const _CatPriceSlider({
    required this.value,
    required this.onChanged,
    this.colors = const [kYellowDark, kYellowDark, kYellowDark, kYellowDark],
  });

  @override
  State<_CatPriceSlider> createState() => _CatPriceSliderState();
}

class _CatPriceSliderState extends State<_CatPriceSlider> {
  double? _dragX;

  static const Color _accent = kYellowDark;

  int _nearestIndex(double dx, double width, int count) {
    if (width <= 0) return widget.value;
    final step = width / (count - 1);
    final idx = (dx / step).round();
    return idx.clamp(0, count - 1);
  }

  @override
  Widget build(BuildContext context) {
    final count = kPriceTiers.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        const thumbR = 12.0;
        final trackWidth = constraints.maxWidth - thumbR * 2;

        void updateFromLocalX(double localX) {
          final clampedX = (localX - thumbR).clamp(0.0, trackWidth);
          setState(() => _dragX = clampedX);
        }

        void commitDrag() {
          if (_dragX == null) return;
          final idx = _nearestIndex(_dragX!, trackWidth, count);
          widget.onChanged(idx);
          setState(() => _dragX = null);
        }

        final activeStep = trackWidth / (count - 1);
        final thumbX = _dragX ?? (widget.value * activeStep);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) =>
              updateFromLocalX(d.localPosition.dx),
          onHorizontalDragUpdate: (d) =>
              updateFromLocalX(d.localPosition.dx),
          onHorizontalDragEnd: (_) => commitDrag(),
          onTapUp: (d) {
            updateFromLocalX(d.localPosition.dx);
            commitDrag();
          },
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: thumbR,
                  right: thumbR,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  left: thumbR,
                  child: Container(
                    height: 4,
                    width: thumbX,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ...List.generate(count, (i) {
                  final dotX = thumbR + (i * activeStep) - 5;
                  final passed = i * activeStep <= thumbX + 0.5;
                  return Positioned(
                    left: dotX,
                    child: GestureDetector(
                      onTap: () => widget.onChanged(i),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: passed ? _accent : Colors.white,
                          border: Border.all(
                            color: passed
                                ? _accent
                                : const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Positioned(
                  left: thumbX,
                  child: Container(
                    width: thumbR * 2,
                    height: thumbR * 2,
                    decoration: BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(count, (i) {
                      final isSel = i == widget.value;
                      return Text(
                        '₹${kPriceTiers[i].min.round()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSel ? FontWeight.w800 : FontWeight.w500,
                          color: isSel ? _accent : kTextLight,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}