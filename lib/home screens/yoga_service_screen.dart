import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mrcoach/home%20screens/home2_screen.dart';
import 'package:mrcoach/home%20screens/scratch_card_screen.dart';
import 'package:mrcoach/home%20screens/med_screen.dart';
import 'package:mrcoach/profile_settings_pages/booking_store.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:mrcoach/utils/razorpay_payment_helper.dart';

class YogaService {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const YogaService({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

const List<YogaService> kYogaServices = [
  YogaService(id: '0',  name: 'Meditation',                description: 'Mindfulness & breathing techniques',       emoji: '🧘'),
  YogaService(id: '1',  name: 'Online Yoga',               description: 'Live sessions from home',                  emoji: '🖥️'),
  YogaService(id: '2',  name: 'Power Yoga',                description: 'High-energy strength & flexibility',       emoji: '💪'),
  YogaService(id: '3',  name: 'Pre / Post Pregnancy Yoga', description: 'Safe yoga for all stages',                 emoji: '🤰'),
  YogaService(id: '4',  name: 'Stress Relief',             description: 'Calming asanas & relaxation',              emoji: '🌿'),
  YogaService(id: '5',  name: 'Therapeutic Yoga',          description: 'Healing & rehabilitation focused',         emoji: '🩺'),
  YogaService(id: '6',  name: 'Yoga at Home',              description: 'Personalised in-home sessions',            emoji: '🏠'),
  YogaService(id: '7',  name: 'Strength Training',         description: 'Build muscle & power with expert guidance',emoji: '🏋️'),
  YogaService(id: '8',  name: 'Weight Loss',               description: 'Fat-loss programs tailored to your body',  emoji: '⚖️'),
  YogaService(id: '9',  name: 'Body Toning',               description: 'Sculpt & tone with targeted exercises',    emoji: '🎯'),
  YogaService(id: '10', name: 'Kids Fitness',              description: 'Fun, age-appropriate fitness programs',    emoji: '🧒'),
  YogaService(id: '11', name: 'Posture Correction',        description: 'Correct imbalances & improve alignment',   emoji: '🧍'),
  YogaService(id: '12', name: 'Senior Fitness',            description: 'Gentle fitness for older adults',          emoji: '🧓'),
  YogaService(id: '13', name: 'Muscle Gain',               description: 'Structured hypertrophy programs',          emoji: '💪'),
  YogaService(id: '14', name: 'Personal Trainer',          description: 'One-on-one certified trainer sessions',    emoji: '🏅'),
  YogaService(id: '15', name: 'Back / Neck / Knee Pain',   description: 'Relieve pain and improve movement.',       emoji: '🩻'),
  YogaService(id: '16', name: 'Elderly Care',              description: 'Help seniors stay active and independent.',emoji: '👴'),
  YogaService(id: '17', name: 'Home Physiotherapy',        description: 'Professional physiotherapy at home.',      emoji: '🏠'),
  YogaService(id: '18', name: 'Mobility Training',         description: 'Improve balance, flexibility, movement.',  emoji: '🚶'),
  YogaService(id: '19', name: 'Physiotherapist (Home/Online)', description: 'Expert physiotherapy at home or online.', emoji: '💻'),
  YogaService(id: '20', name: 'Post Surgery Recovery',     description: 'Regain strength after surgery safely.',    emoji: '🏥'),
  YogaService(id: '21', name: 'Posture Correction (Physio)', description: 'Correct body posture with expert guidance.', emoji: '🧍'),
  YogaService(id: '22', name: 'Sports Injury Rehab',       description: 'Recover from sports injuries faster.',     emoji: '⚽'),
  YogaService(id: '23', name: 'Stroke Rehab',              description: 'Specialized rehabilitation after stroke.', emoji: '🧠'),
  YogaService(id: '24', name: 'Acupressure',               description: 'Stimulate pressure points to reduce pain.',emoji: '🖐️'),
  YogaService(id: '25', name: 'Acupuncture',               description: 'Traditional needle therapy for pain relief.', emoji: '🪡'),
  YogaService(id: '26', name: 'Cupping Therapy',           description: 'Improve blood flow and reduce muscle tension.', emoji: '🥣'),
  YogaService(id: '27', name: 'Detox Therapy',             description: 'Cleanse your body with natural detox therapies.', emoji: '🌿'),
  YogaService(id: '28', name: 'Naturopathy',               description: 'Natural healing focused on overall wellness.', emoji: '🍃'),
  YogaService(id: '29', name: 'Touch Healing',             description: 'Gentle healing for relaxation and balance.', emoji: '✨'),
  YogaService(id: '30', name: 'Athletics',                 description: 'Improve speed, stamina, agility.',          emoji: '🏃'),
  YogaService(id: '31', name: 'Badminton',                 description: 'Enhance reflexes, footwork, and strategy.', emoji: '🏸'),
  YogaService(id: '32', name: 'Boxing / Kickboxing',       description: 'Build strength and self-defense skills.',   emoji: '🥊'),
  YogaService(id: '33', name: 'Cricket',                   description: 'Coaching for batting, bowling, fielding.',  emoji: '🏏'),
  YogaService(id: '34', name: 'Football',                  description: 'Develop teamwork, stamina, ball control.',  emoji: '⚽'),
  YogaService(id: '35', name: 'Karate',                    description: 'Discipline, flexibility, self-defense.',    emoji: '🥋'),
  YogaService(id: '36', name: 'Kids Sports Training',      description: 'Fun sports activities for kids.',           emoji: '🧒'),
  YogaService(id: '37', name: 'Running / Marathon',        description: 'Programs for endurance and marathon prep.', emoji: '🏃‍♂️'),
  YogaService(id: '38', name: 'Skating',                   description: 'Balance, coordination, and skating techniques.', emoji: '🛼'),
  YogaService(id: '39', name: 'Swimming',                  description: 'Professional swimming sessions.',           emoji: '🏊'),
  YogaService(id: '40', name: 'Diabetic Diet',             description: 'Balanced meal plans to manage blood sugar.',emoji: '🩺'),
  YogaService(id: '41', name: 'Kids Diet',                 description: 'Nutritious diet plans for growing kids.',   emoji: '🧒'),
  YogaService(id: '42', name: 'Muscle Gain Diet',          description: 'High-protein plans for muscle growth.',     emoji: '💪'),
  YogaService(id: '43', name: 'Online Diet Consultation',  description: 'Expert nutrition guidance online.',         emoji: '💻'),
  YogaService(id: '44', name: 'PCOS Diet',                 description: 'Hormone-friendly meal plans for PCOS.',    emoji: '🌸'),
  YogaService(id: '45', name: 'Sports Nutrition',          description: 'Performance nutrition for athletes.',       emoji: '🏋️'),
  YogaService(id: '46', name: 'Weight Loss Diet',          description: 'Safe and sustainable weight loss diet.',    emoji: '⚖️'),
];

const List<String> kYogaTimeSlots = [
  '6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM',
  '11:00 AM', '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM',
];
const Color kPrimary      =kYellow;
const Color kPrimaryDark  =kYellow;
const Color kPrimaryLight = Color(0xFFE8F5E9);
const Color kPrimaryBg    = Color(0xFFF1F8F1);
const Color kAccent       = kYellow;
const Color kTextDark     = Color(0xFF1A2E1A);
const Color kTextMid      =kYellow;
const Color kTextLight    = kYellow;
const Color kBorderColor  = Color.fromARGB(255, 230, 227, 200);
const Color kCardSelected = Color(0xFFE8F5E9);

class YogaServiceScreen extends StatefulWidget {
  final String? preSelectedServiceName;
  final String? categoryName;
  const YogaServiceScreen({super.key, this.preSelectedServiceName, this.categoryName});

  @override
  State<YogaServiceScreen> createState() => _YogaServiceScreenState();
}

class _YogaServiceScreenState extends State<YogaServiceScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selected = {};

  String _serviceMode = 'online';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = kYogaTimeSlots[0];

  List<dynamic> _allSlots = [];
  bool _loadingSlots = true;

  late TabController _tabController;
  late Razorpay _razorpay;
  Map<String, dynamic>? _pendingBookingData;

  final List<Booking> _sessionBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }

    if (widget.preSelectedServiceName != null) {
      final incomingName = widget.preSelectedServiceName!.toLowerCase().trim();
      for (final service in kYogaServices) {
        if (service.name.toLowerCase().trim() == incomingName) {
          _selected.add(service.id);
          break;
        }
      }
    }

    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() => _loadingSlots = true);
    final slots = await ApiService.getSlots();
    setState(() {
      _allSlots = slots;
      _loadingSlots = false;
      _updateSelectedTimeForDate();
    });
  }

  List<String> get _availableTimeSlotsForSelectedDate {
    final dateStr = _selectedDate.toIso8601String().split('T')[0]; // "YYYY-MM-DD"
    final filtered = _allSlots.where((slot) {
      final slotDate = slot['date'] as String?;
      final isAvailable = slot['isAvailable'] as bool? ?? true;
      return slotDate == dateStr && isAvailable;
    }).map((slot) => slot['time'] as String).toList();
    
    if (filtered.isEmpty) {
      return kYogaTimeSlots;
    }
    return filtered;
  }

  void _updateSelectedTimeForDate() {
    final available = _availableTimeSlotsForSelectedDate;
    if (available.isNotEmpty) {
      if (!available.contains(_selectedTime)) {
        setState(() {
          _selectedTime = available[0];
        });
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
    _tabController.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_pendingBookingData != null) {
      _finalizeBooking(
        List<YogaService>.from(_pendingBookingData!['services']),
        _pendingBookingData!['bookingType'],
        _pendingBookingData!,
      );
      _pendingBookingData = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
      );
    }
  }

  void _openConfirmSheet({required String bookingType}) {
    final selectedServices =
        kYogaServices.where((s) => _selected.contains(s.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        services: selectedServices,
        serviceMode: _serviceMode,
        sessionDate: _selectedDate,
        sessionTime: _selectedTime,
        bookingType: bookingType,
        onConfirm: (Map<String, dynamic> data) {
          Navigator.pop(context);
          _processBookingSubmit(selectedServices, bookingType, data);
        },
      ),
    );
  }

  void _processBookingSubmit(
    List<YogaService> services,
    String bookingType,
    Map<String, dynamic> data,
  ) async {
    final isDemo = bookingType == 'demo';
    final sessionCount = data['sessionCount'] as int? ?? 1;
    final price = isDemo ? (99.0 * sessionCount) : 0.0;

    if (isDemo && price > 0) {
      // 1. Create Order on Backend
      final orderRes = await ApiService.createRazorpayOrder(price);
      if (!orderRes['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(orderRes['message'] ?? 'Payment error'), backgroundColor: Colors.red)
          );
        }
        return;
      }
      
      // 2. Save data temporarily for when payment succeeds
      _pendingBookingData = {
         'services': services,
         'bookingType': bookingType,
         'sessionCount': sessionCount,
         ...data,
      };
      
      // 3. Open Razorpay Interface
      var options = {
        'key': orderRes['key'] ?? 'rzp_test_YOUR_KEY_ID', 
        'amount': price * 100,
        'name': 'MrCoach',
        'order_id': orderRes['orderId'],
        'description': 'Demo Session Booking',
        'prefill': {
          'contact': data['phone'] ?? '',
          'email': data['email'] ?? '',
        }
      };
      
      try {
        if (kIsWeb) {
          openRazorpayWeb(
            options: options,
            onSuccess: (paymentId, orderId, signature) {
              if (_pendingBookingData != null) {
                _finalizeBooking(
                  List<YogaService>.from(_pendingBookingData!['services']),
                  _pendingBookingData!['bookingType'],
                  _pendingBookingData!,
                );
                _pendingBookingData = null;
              }
            },
            onFailure: (errorMsg) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment Failed: $errorMsg'), backgroundColor: Colors.red),
                );
              }
            },
          );
        } else {
          _razorpay.open(options);
        }
      } catch (e) {
        debugPrint('Error opening Razorpay: $e');
      }
    } else {
      // Free Enquiry Flow
      _finalizeBooking(services, bookingType, data);
    }
  }

  void _finalizeBooking(
    List<YogaService> services,
    String bookingType,
    Map<String, dynamic> data,
  ) async {
    final isDemo = bookingType == 'demo';
    final isOnline = _serviceMode == 'online';
    final sessionCount = data['sessionCount'] as int? ?? 1;
    final name = data['name'] as String?;
    final phone = data['phone'] as String?;
    final address = data['address'] as String?;

    final primaryService = services.first;
    
    final serviceNameString = services.length > 1
        ? '${primaryService.name} +${services.length - 1} more'
        : primaryService.name;

    final subcategoriesList = services.map((s) => s.name).toList();

    // Dynamically derive Category, Source Screen, and Local Enum Category
    final lowerName = serviceNameString.toLowerCase();
    ServiceCategory localCategory = ServiceCategory.yoga;
    String sourceScreenName = 'Yoga & Wellness';
    String derivedCategory = 'Yoga & Wellness';
    
    if (widget.categoryName != null) {
      final catLower = widget.categoryName!.toLowerCase();
      if (catLower.contains('fitness')) {
        localCategory = ServiceCategory.fitness;
        sourceScreenName = 'Fitness';
        derivedCategory = 'Fitness';
      } else if (catLower.contains('yoga') || catLower.contains('wellness')) {
        localCategory = ServiceCategory.yoga;
        sourceScreenName = 'Yoga & Wellness';
        derivedCategory = 'Yoga & Wellness';
      } else if (catLower.contains('diet')) {
        localCategory = ServiceCategory.diet;
        sourceScreenName = 'Diet';
        derivedCategory = 'Diet';
      } else if (catLower.contains('nutrition')) {
        localCategory = ServiceCategory.nutrition;
        sourceScreenName = 'Nutrition';
        derivedCategory = 'Nutrition';
      } else if (catLower.contains('physio')) {
        localCategory = ServiceCategory.physio;
        sourceScreenName = 'Physio';
        derivedCategory = 'Physiotherapy';
      } else if (catLower.contains('sport')) {
        localCategory = ServiceCategory.sports;
        sourceScreenName = 'Sports';
        derivedCategory = 'Sports';
      } else if (catLower.contains('therapy')) {
        localCategory = ServiceCategory.therapy;
        sourceScreenName = 'Therapy';
        derivedCategory = 'Therapy';
      } else {
        derivedCategory = widget.categoryName!;
        sourceScreenName = widget.categoryName!;
      }
    } else {
      if (lowerName.contains('diet')) {
        localCategory = ServiceCategory.diet;
        sourceScreenName = 'Diet';
        derivedCategory = 'Diet';
      } else if (lowerName.contains('fitness') || lowerName.contains('gym') || lowerName.contains('strength') || lowerName.contains('body') || lowerName.contains('weight') || lowerName.contains('kids') || lowerName.contains('senior') || lowerName.contains('muscle') || lowerName.contains('trainer')) {
        localCategory = ServiceCategory.fitness;
        sourceScreenName = 'Fitness';
        derivedCategory = 'Fitness';
      } else if (lowerName.contains('yoga') || lowerName.contains('stress') || lowerName.contains('pregnancy')) {
        localCategory = ServiceCategory.yoga;
        sourceScreenName = 'Yoga & Wellness';
        derivedCategory = 'Yoga & Wellness';
      } else if (lowerName.contains('physio')) {
        localCategory = ServiceCategory.physio;
        sourceScreenName = 'Physio';
        derivedCategory = 'Physio';
      } else if (lowerName.contains('nutrition')) {
        localCategory = ServiceCategory.nutrition;
        sourceScreenName = 'Nutrition';
        derivedCategory = 'Nutrition';
      } else if (lowerName.contains('sport')) {
        localCategory = ServiceCategory.sports;
        sourceScreenName = 'Sports';
        derivedCategory = 'Sports';
      } else if (lowerName.contains('therapy') || lowerName.contains('acupressure') || lowerName.contains('acupuncture')) {
        localCategory = ServiceCategory.therapy;
        sourceScreenName = 'Therapy';
        derivedCategory = 'Therapy';
      } else if (lowerName.contains('meditation') || lowerName.contains('breath')) {
        localCategory = ServiceCategory.yoga;
        sourceScreenName = 'Meditation';
        derivedCategory = 'Yoga & Wellness';
      }
    }

    // --- SEND TO BACKEND ---
    final result = await ApiService.createBooking({
      'serviceName': serviceNameString,
      'coachName': 'Pending Assignment', // Will be assigned by Admin
      'date': _selectedDate.toIso8601String().split('T')[0],
      'time': _selectedTime,
      'price': isDemo ? (99 * sessionCount) : 0,
      'mode': isOnline ? 'Online' : 'Home Visit',
      'bookingType': isDemo ? 'Demo' : 'Enquiry',
      'mobileNumber': phone ?? 'Not Provided',
      'address': address ?? (isOnline ? 'Online Session' : ''),
      'name': name,
      'email': data['email'],
      'gender': data['gender'],
      'state': data['state'],
      'district': data['district'],
      'area': data['area'],
      'pincode': data['pincode'],
      'startPlan': data['startPlan'],
      'availableDays': data['availableDays'],
      'sourceWebsite': data['sourceWebsite'],
      'category': derivedCategory,
      'subcategories': subcategoriesList,
    });

    if (!result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
      return; // Stop if the backend rejected it (e.g., not logged in)
    }
    // -----------------------

    GlobalScratchCard? rewardCard;
    if (result['reward'] != null) {
      rewardCard = GlobalScratchCard.fromJson(result['reward']);
      ScratchCardStore().addCard(rewardCard);
    }

    final globalBooking = Booking(
      bookingId: 'YG${DateTime.now().millisecondsSinceEpoch}',
      serviceCategory: localCategory,
      sourceScreen: sourceScreenName,
      service: BookedService(
        id: primaryService.id,
        name: services.length > 1
            ? '${primaryService.name} +${services.length - 1} more'
            : primaryService.name,
        emoji: primaryService.emoji,
      ),
      type: isDemo ? BookingType.demo : BookingType.enquire,
      serviceMode: isOnline ? ServiceMode.online : ServiceMode.home,
      sessionDate: isDemo ? _selectedDate : null,
      timeSlot: isDemo ? _selectedTime : null,
      address: isDemo
          ? (isOnline ? 'Online Session' : (address ?? ''))
          : null,
      sessionCount: isDemo ? sessionCount : null,
      customerName: isDemo ? name : null,
      customerPhone: isDemo ? phone : null,
      enquirerName: !isDemo ? name : null,
      enquirerPhone: !isDemo ? phone : null,
      totalAmount: isDemo ? (99 * sessionCount) : 0,
      bookedAt: DateTime.now(),
    );
    BookingStore.instance.addBooking(globalBooking);

    setState(() {
      _sessionBookings.add(globalBooking);
      _selected.clear();
      _tabController.animateTo(1);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        services: services,
        bookingType: bookingType,
        sessionCount: sessionCount,
        onDone: () {
          Navigator.pop(context);
          // Show scratch card bottom sheet after dialog closes if reward was issued
          if (rewardCard != null) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              ScratchCardBottomSheet.show(
                context,
                card: rewardCard!,
                onViewAll: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScratchRewardsPage()),
                  );
                },
              );
            });
          }
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kYellow,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kTextDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _updateSelectedTimeForDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedServices =
        kYogaServices.where((s) => _selected.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: kPrimaryBg,
      body: Column(
        children: [
          _Header(
            preSelectedName: widget.preSelectedServiceName,
            categoryName: widget.categoryName,
          ),

          if (selectedServices.isNotEmpty)
            _SelectedServicesBar(
              services: selectedServices,
              onRemove: (id) => _toggle(id),
            ),

          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: kYellow,
              indicatorWeight: 3,
              labelColor: kYellow,
              unselectedLabelColor: const Color(0xFFAAAAAA),
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                const Tab(text: 'Services'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('My Bookings'),
                      if (_sessionBookings.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kYellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_sessionBookings.length}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ]
                    ],
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
                  selected: _selected,
                  onToggle: _toggle,
                  serviceMode: _serviceMode,
                  onModeChanged: (m) => setState(() => _serviceMode = m),
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onPickDate: _pickDate,
                  onTimeChanged: (t) => setState(() => _selectedTime = t),
                  preSelectedServiceName: widget.preSelectedServiceName,
                  availableTimeSlots: _availableTimeSlotsForSelectedDate,
                ),
                _MyBookingsTab(bookings: _sessionBookings),
              ],
            ),
          ),

          _BottomBar(
            enabled: _selected.isNotEmpty,
            bookingCount: _sessionBookings.length,
            onBookDemo: () => _openConfirmSheet(bookingType: 'demo'),
            onEnquire: () => _openConfirmSheet(bookingType: 'enquiry'),
          ),
        ],
      ),
    );
  }
}

class _SelectedServicesBar extends StatelessWidget {
  final List<YogaService> services;
  final void Function(String id) onRemove;

  const _SelectedServicesBar({required this.services, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      color: const Color(0xFFFFFDE7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded,
                  size: 14, color: Color(0xFF795548)),
              const SizedBox(width: 5),
              Text(
                '${services.length} service${services.length > 1 ? 's' : ''} selected  •  tap ✕ to remove',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF795548),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final s = services[i];
                return Container(
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kYellow.withOpacity(0.30),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => onRemove(s.id),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.close_rounded,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _Header extends StatelessWidget {
  final String? preSelectedName;
  final String? categoryName;
  const _Header({this.preSelectedName, this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 22,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (preSelectedName != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 5),
                      Text(
                        '$preSelectedName selected',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categoryName ?? 'Yoga & Wellness',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose Your\nServices',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select services, mode & preferred slot',
                style: TextStyle(color: Color(0xFFB9F6CA), fontSize: 12),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 208, 0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Demo ₹99/session',
                    style: TextStyle(
                        color: Color(0xFF2C1A00),
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Enquire FREE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _ServicesTab extends StatelessWidget {
  final Set<String> selected;
  final void Function(String) onToggle;
  final String serviceMode;
  final void Function(String) onModeChanged;
  final DateTime selectedDate;
  final String selectedTime;
  final VoidCallback onPickDate;
  final void Function(String) onTimeChanged;
  final String? preSelectedServiceName;
  final List<String> availableTimeSlots;

  const _ServicesTab({
    required this.selected,
    required this.onToggle,
    required this.serviceMode,
    required this.onModeChanged,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onTimeChanged,
    required this.availableTimeSlots,
    this.preSelectedServiceName,
  });

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      children: [
        if (preSelectedServiceName != null) ...[
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              border: Border.all(
                  color: const Color(0xFF2E7D32).withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                     size: 16, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"$preSelectedServiceName" is pre-selected for you. '
                    'You can add more services below.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        _ServiceModeSection(
          serviceMode: serviceMode,
          onModeChanged: onModeChanged,
        ),

        const SizedBox(height: 20),

        _SectionLabel(label: 'SELECT DATE & TIME'),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: onPickDate,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.calendar_today_rounded,
                      color: kYellow, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Session Date',
                          style:
                              TextStyle(fontSize: 11, color:kYellow)),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(selectedDate),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextDark),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: kYellow),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: availableTimeSlots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final t = availableTimeSlots[i];
              final isSelected = t == selectedTime;
              return GestureDetector(
                onTap: () => onTimeChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? kYellow : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color.fromARGB(255, 24, 23, 14)
                          : kBorderColor,
                      width: isSelected ? 1.8 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        _SectionLabel(label: 'AVAILABLE SERVICES'),
        const SizedBox(height: 6),
        const Row(
          children: [
            Icon(Icons.touch_app_rounded, size: 13, color: kYellow),
            SizedBox(width: 5),
            Text('Tap to select one or more services',
                style: TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 14),

        ...kYogaServices.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ServiceCard(
                service: s,
                isSelected: selected.contains(s.id),
                isPreSelected: preSelectedServiceName != null &&
                    s.name.toLowerCase().trim() ==
                        preSelectedServiceName!.toLowerCase().trim(),
                onTap: () => onToggle(s.id),
              ),
            )),
        const SizedBox(height: 14),
        if (selected.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Services selected',
                    style: TextStyle(
                        fontSize: 13,
                        color: kYellow,
                        fontWeight: FontWeight.w500)),
                Text(
                  '${selected.length}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 188, 175, 94)),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFAAAAAA),
          letterSpacing: 1.0),
    );
  }
}
class _ModeToggle extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool selected;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.label,
    required this.subLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ?kYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white :kYellow,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: selected
                      ? Colors.white.withOpacity(0.8)
                      :kYellow,
                ),
              ),
            ],
          ),
        ),
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: kBorderColor, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text('📋', style: TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 16),
            const Text('No Bookings Yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextDark)),
            const SizedBox(height: 6),
            const Text(
              'Book a demo or send an enquiry\nfrom the Services tab!',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color:kYellow, height: 1.5),
            ),
          ],
        ),
      );
    }

    final reversed = bookings.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: reversed.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _BookingCard(
          booking: reversed[index],
          index: reversed.length - index,
        ),
      ),
    );
  }
}
class _BookingCard extends StatelessWidget {
  final Booking booking;
  final int index;
  const _BookingCard({required this.booking, required this.index});

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = booking.bookedAt;
    final bookedStr =
        '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}  '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final isEnquiry = booking.type == BookingType.enquire;
    final isOnline  = booking.serviceMode == ServiceMode.online;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnquiry
              ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
              : [
                  const Color.fromARGB(255, 125, 121, 46),
                  const Color(0xFF66BB6A)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnquiry
                        ? 'Enquiry #$index'
                        : 'Demo Session #$index',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(bookedStr,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFE8F5E9))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isEnquiry ? 'FREE' : 'CONFIRMED',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text('ID: ${booking.bookingId}',
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFFE8F5E9))),

          // Customer / Enquirer info
          if (!isEnquiry && (booking.customerName ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Text(booking.customerName!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
                if ((booking.customerPhone ?? '').isNotEmpty) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.phone_rounded,
                      size: 13, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(booking.customerPhone!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70)),
                ],
              ],
            ),
          ],

          if (isEnquiry && (booking.enquirerName ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Text(booking.enquirerName!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
                if ((booking.enquirerPhone ?? '').isNotEmpty) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.phone_rounded,
                      size: 13, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(booking.enquirerPhone!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70)),
                ],
              ],
            ),
          ],

          if (!isEnquiry && (booking.address ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(booking.address!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(
                icon: isOnline
                    ? Icons.videocam_rounded
                    : Icons.home_rounded,
                label: isOnline ? 'Online' : 'Home Visit',
              ),
              if (booking.sessionDate != null)
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: _formatDate(booking.sessionDate!),
                ),
              if ((booking.timeSlot ?? '').isNotEmpty)
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  label: booking.timeSlot!,
                ),
              if (!isEnquiry && (booking.sessionCount ?? 1) > 1)
                _InfoChip(
                  icon: Icons.repeat_rounded,
                  label: '${booking.sessionCount} sessions',
                ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          const SizedBox(height: 14),

          const Text('SERVICE',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 1.0)),
          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(booking.service.emoji,
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.service.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Yoga & Wellness',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text(
                isEnquiry
                    ? 'Enquiry — FREE'
                    : '₹${booking.totalAmount} — Cash',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
class _ServiceCard extends StatelessWidget {
  final YogaService service;
  final bool isSelected;
  final bool isPreSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.onTap,
    this.isPreSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? kCardSelected : Colors.white,
          border: Border.all(
            color: isSelected
                ? kYellow
                : isPreSelected
                    ? kYellow.withOpacity(0.5)
                    : const Color(0xFFDEEDE0),
            width: isSelected
                ? 1.8
                : isPreSelected
                    ? 1.5
                    : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? kPrimaryLight
                    : const Color(0xFFF0F7F0),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(service.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: kTextDark,
                        ),
                      ),
                      if (isPreSelected && isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Your pick',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.description,
                    style:
                        const TextStyle(fontSize: 12, color: kTextLight),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ?kYellow : Colors.transparent,
                border: Border.all(
                  color: isSelected ? kYellow : kBorderColor,
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
class _BottomBar extends StatelessWidget {
  final bool enabled;
  final int bookingCount;
  final VoidCallback onBookDemo;
  final VoidCallback onEnquire;

  const _BottomBar({
    required this.enabled,
    required this.bookingCount,
    required this.onBookDemo,
    required this.onEnquire,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kPrimaryLight,
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(bookingCount > 0 ? '✅' : '✨',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookingCount > 0
                            ? '$bookingCount Session${bookingCount > 1 ? 's' : ''} Booked!'
                            : 'Demo ₹99/session  •  Enquiry FREE',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kTextDark),
                      ),
                      Text(
                        bookingCount > 0
                            ? 'You can book or enquire again'
                            : 'Pick your services & preferred slot',
                        style:
                            const TextStyle(fontSize: 11, color:kYellow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: enabled ? onEnquire : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: enabled ?kYellow : const Color(0xFFCCCCCC),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enquire',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: enabled
                                ? kYellow
                                : const Color(0xFFAAAAAA)),
                      ),
                      Text(
                        'FREE',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: enabled
                                ? kYellow
                                : const Color(0xFFAAAAAA)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: enabled ? onBookDemo : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:kYellow,
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Book Demo',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('₹99/session',
                            style: TextStyle(
                                color: Color(0xFF2C1A00),
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _ConfirmSheet extends StatefulWidget {
  final List<YogaService> services;
  final String serviceMode;
  final DateTime sessionDate;
  final String sessionTime;
  final String bookingType;
  final void Function(Map<String, dynamic> data) onConfirm;

  const _ConfirmSheet({
    required this.services,
    required this.serviceMode,
    required this.sessionDate,
    required this.sessionTime,
    required this.bookingType,
    required this.onConfirm,
  });

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  int _sessionCount = 1;
  final _sessionCountController = TextEditingController(text: '1');
  final _nameController         = TextEditingController();
  final _phoneController        = TextEditingController();
  final _addressController      = TextEditingController();
  final _emailController        = TextEditingController();
  final _stateController        = TextEditingController();
  final _districtController     = TextEditingController();
  final _areaController         = TextEditingController();
  final _pincodeController      = TextEditingController();

  String? _selectedGender;
  String? _selectedSource;
  DateTime? _startPlanDate;
  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final Set<String> _selectedDays = {};

  bool _phoneVerified = false;
  bool _otpSent       = false;
  final _otpController = TextEditingController();
  String _otpError     = '';
  final String _fakeOtp = '1234';

  @override
  void initState() {
    super.initState();
    _sessionCountController.addListener(() {
      final val = int.tryParse(_sessionCountController.text);
      if (val != null && val >= 1) setState(() => _sessionCount = val);
    });
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await ApiService.getUserProfile();
    if (profile != null) {
      setState(() {
        if (profile['name'] != null && profile['name'] != 'Coach Client') {
          _nameController.text = profile['name'];
        }
        if (profile['email'] != null && profile['email'] != '...@gmail.com') {
          _emailController.text = profile['email'];
        }
        if (profile['phoneNumber'] != null && profile['phoneNumber'].toString().isNotEmpty) {
          _phoneController.text = profile['phoneNumber'];
          _phoneVerified = true;
        }
        if (profile['gender'] != null) {
          _selectedGender = profile['gender'];
        }
        if (profile['state'] != null) {
          _stateController.text = profile['state'];
        }
        if (profile['district'] != null) {
          _districtController.text = profile['district'];
        }
        if (profile['area'] != null) {
          _areaController.text = profile['area'];
        }
        if (profile['pincode'] != null) {
          _pincodeController.text = profile['pincode'];
        }
        if (profile['address'] != null) {
          _addressController.text = profile['address'];
        }
      });
    } else {
      final cached = await ApiService.getCachedProfile();
      setState(() {
        if (cached['name'] != 'Enter your name') {
          _nameController.text = cached['name'] ?? '';
        }
        if (cached['email'] != '...@gmail.com') {
          _emailController.text = cached['email'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _sessionCountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _sendOtp() {
    if (_phoneController.text.length < 10) return;
    setState(() { _otpSent = true; _otpError = ''; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP sent! (use 1234 for demo)'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _verifyOtp() {
    if (_otpController.text == _fakeOtp) {
      setState(() { _phoneVerified = true; _otpError = ''; });
    } else {
      setState(() => _otpError = 'Incorrect OTP. Try again.');
    }
  }

  bool get _isQuestionnaireComplete {
    final email = _emailController.text.trim();
    final isEmailValid = email.contains('@') && email.contains('.');
    final isPincodeValid = _pincodeController.text.trim().length == 6;
    final isAddressValid = widget.serviceMode == 'online' || _addressController.text.trim().isNotEmpty;
    
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().length >= 10 &&
        isEmailValid &&
        _selectedGender != null &&
        _stateController.text.trim().isNotEmpty &&
        _districtController.text.trim().isNotEmpty &&
        _areaController.text.trim().isNotEmpty &&
        isPincodeValid &&
        _startPlanDate != null &&
        _selectedDays.isNotEmpty &&
        _selectedSource != null &&
        isAddressValid;
  }

  bool get _canProceed {
    if (widget.bookingType == 'enquiry') {
      return _isQuestionnaireComplete;
    } else {
      return _phoneVerified && _isQuestionnaireComplete;
    }
  }

  String _getValidationMessage() {
    if (_nameController.text.trim().isEmpty) return 'Please enter your name';
    if (_phoneController.text.trim().length < 10) return 'Please enter a valid phone number';
    if (widget.bookingType != 'enquiry' && !_phoneVerified) return 'Please verify your phone number';
    
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) return 'Please enter a valid email address';
    if (_selectedGender == null) return 'Please select your gender';
    if (_stateController.text.trim().isEmpty) return 'Please enter your state';
    if (_districtController.text.trim().isEmpty) return 'Please enter your district';
    if (_areaController.text.trim().isEmpty) return 'Please enter your area';
    if (_pincodeController.text.trim().length != 6) return 'Please enter a 6-digit pincode';
    if (_startPlanDate == null) return 'Please select when you want to start';
    if (_selectedDays.isEmpty) return 'Please select at least one available day';
    if (_selectedSource == null) return 'Please select how you heard about us';
    if (widget.serviceMode != 'online' && _addressController.text.trim().isEmpty) return 'Please enter your home address';
    return '';
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.words,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF5F5F5),
        border: Border.all(color: kBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        enabled: enabled,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          color: enabled ? kTextDark : Colors.grey[600],
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
          prefixIcon: Icon(icon, color: kYellow, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnquiry   = widget.bookingType == 'enquiry';
    final isOnline    = widget.serviceMode == 'online';
    final totalAmount = 99 * _sessionCount;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 18, color: kTextDark),
            ),
            Text(
              isEnquiry
                  ? 'Confirm Enquiry (FREE)'
                  : 'Confirm Demo Booking',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextDark),
            ),
            const SizedBox(height: 6),
            Text(
              isEnquiry
                  ? "We'll reach out to you soon — completely free!"
                  : 'Review your session details below:',
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 16),

            // Session details
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                border: Border.all(color: kBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: isOnline
                        ? Icons.videocam_rounded
                        : Icons.home_rounded,
                    label: 'Mode',
                    value: isOnline
                        ? '🖥️  Online Session'
                        : '🏠  Home Visit',
                  ),
                  const Divider(color: Color(0xFFCDE8CE), height: 16),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: _formatDate(widget.sessionDate),
                  ),
                  const Divider(color: Color(0xFFCDE8CE), height: 16),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: widget.sessionTime,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                border: Border.all(color: const Color(0xFFEEEEEE)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SELECTED SERVICES',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFAAAAAA),
                          letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  ...widget.services.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text(s.emoji,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Text(s.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: kTextDark,
                                    fontWeight: FontWeight.w500,
                                    height: 1.8)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Section 1: Contact Information
            const Text('CONTACT DETAILS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 1.0)),
            const SizedBox(height: 10),

            _buildTextField(
              _nameController,
              'Your full name',
              Icons.person_outline_rounded,
            ),
            const SizedBox(height: 10),

            _buildTextField(
              _emailController,
              'Your email address',
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 10),

            // Phone Field
            _buildTextField(
              _phoneController,
              'Mobile number',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              enabled: !_phoneVerified,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffixIcon: _phoneVerified
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: Color(0xFF4CAF50), size: 18),
                          SizedBox(width: 4),
                          Text('Verified',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  : _phoneController.text.length >= 10 && !_otpSent
                      ? GestureDetector(
                          onTap: _sendOtp,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kYellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Send OTP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        )
                      : null,
            ),

            if (_otpSent && !_phoneVerified) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F9F3),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() => _otpError = ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8),
                      decoration: const InputDecoration(
                        hintText: '• • • •',
                        hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 20),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                    if (_otpError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_otpError,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _sendOtp,
                    child: const Text('Resend OTP',
                        style: TextStyle(
                            fontSize: 12,
                            color: kYellow,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline)),
                  ),
                  ElevatedButton(
                    onPressed: _otpController.text.length >= 4
                        ? _verifyOtp
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kYellow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Verify',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Section 2: Personal Details
            const Text('PERSONAL DETAILS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 1.0)),
            const SizedBox(height: 10),
            
            const Text('Gender', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 6),
            Row(
              children: ['Male', 'Female', 'Other'].map((g) {
                final isSelected = _selectedGender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = g),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kYellow : Colors.white,
                        border: Border.all(color: isSelected ? kYellow : kBorderColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        g,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kTextDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Section 3: Location Details
            const Text('LOCATION DETAILS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 1.0)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildTextField(_stateController, 'State', Icons.map_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_districtController, 'District', Icons.location_city_outlined)),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildTextField(_areaController, 'Area / Locality', Icons.near_me_outlined)),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _pincodeController,
                    'Pincode',
                    Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 4: Training Details & Preferences
            const Text('TRAINING DETAILS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 1.0)),
            const SizedBox(height: 10),

            const Text('When do you want to start plan?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: kPrimary,
                          onPrimary: Colors.white,
                          onSurface: kTextDark,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _startPlanDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range_rounded, color: kYellow, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _startPlanDate == null
                          ? 'Select Start Plan Date'
                          : 'Starts: ${_startPlanDate!.day}/${_startPlanDate!.month}/${_startPlanDate!.year}',
                      style: TextStyle(
                        color: _startPlanDate == null ? const Color(0xFFBBBBBB) : kTextDark,
                        fontSize: 14,
                        fontWeight: _startPlanDate == null ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_month, color: kYellow, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            const Text('Available Days for Practice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 8,
              children: _daysOfWeek.map((day) {
                final isSelected = _selectedDays.contains(day);
                final shortName = day.substring(0, 3);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kYellow : Colors.white,
                      border: Border.all(color: isSelected ? kYellow : kBorderColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      shortName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kTextDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            const Text('How did you hear about us?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedSource,
                  hint: const Text('Select Referral Source', style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13)),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: kYellow, size: 20),
                    border: InputBorder.none,
                  ),
                  items: ['Instagram', 'Facebook', 'Google Search', 'Friend Reference', 'Flyer/Poster', 'Other']
                      .map((src) => DropdownMenuItem(value: src, child: Text(src, style: const TextStyle(fontSize: 14, color: kTextDark))))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSource = val),
                ),
              ),
            ),

            if (widget.serviceMode != 'online') ...[
              const SizedBox(height: 14),
              const Text('Home Visit Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _addressController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Full address (house no, street, city, landmark)',
                    hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.location_on_outlined, color: kYellow, size: 20),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEnquiry ? 'Enquiry charge' : 'Demo session total',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF666666)),
                  ),
                  Text(
                    isEnquiry ? 'FREE' : '₹$totalAmount',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color:
                            isEnquiry ? kPrimary : kTextDark),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _canProceed ? 1.0 : 0.5,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed
                      ? () {
                          final data = {
                            'sessionCount': widget.bookingType == 'enquiry' ? 1 : _sessionCount,
                            'name': _nameController.text.trim(),
                            'phone': _phoneController.text.trim(),
                            'email': _emailController.text.trim(),
                            'gender': _selectedGender,
                            'state': _stateController.text.trim(),
                            'district': _districtController.text.trim(),
                            'area': _areaController.text.trim(),
                            'pincode': _pincodeController.text.trim(),
                            'startPlan': _startPlanDate != null
                                ? '${_startPlanDate!.year}-${_startPlanDate!.month.toString().padLeft(2, '0')}-${_startPlanDate!.day.toString().padLeft(2, '0')}'
                                : null,
                            'availableDays': _selectedDays.toList(),
                            'sourceWebsite': _selectedSource,
                            'address': widget.serviceMode == 'online'
                                ? 'Online Session'
                                : _addressController.text.trim(),
                          };
                          widget.onConfirm(data);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isEnquiry ? kPrimary : kAccent,
                    disabledBackgroundColor:
                        const Color(0xFFDDDDDD),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: isEnquiry
                      ? const Text(
                          'Send Enquiry — FREE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C1A00)
                                    .withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: const Text('Online',
                                  style: TextStyle(
                                      color: Color(0xFF2C1A00),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 8),
                            Text('Confirm & Pay — ₹$totalAmount',
                                style: const TextStyle(
                                    color: Color(0xFF2C1A00),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ),
            if (!_canProceed) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getValidationMessage(),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFAAAAAA)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(
                      color: Color(0xFFE0E0E0), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF666666))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: kPrimary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, color: kTextLight)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark)),
      ],
    );
  }
}
class _SuccessDialog extends StatelessWidget {
  final List<YogaService> services;
  final String bookingType;
  final int sessionCount;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.services,
    required this.bookingType,
    required this.sessionCount,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isEnquiry = bookingType == 'enquiry';

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isEnquiry
                      ? [
                          const Color(0xFF1565C0),
                          const Color(0xFF42A5F5)
                        ]
                      : [
                          const Color(0xFF2E7D32),
                          const Color(0xFF66BB6A)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                isEnquiry ? '📩' : '✅',
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEnquiry ? 'Enquiry Sent!' : 'Booking Confirmed!',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextDark),
            ),
            const SizedBox(height: 6),
            Text(
              isEnquiry
                  ? 'Our team will contact you shortly'
                  : '₹${99 * sessionCount} — Pay in Cash at session',
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                border: Border.all(color: kBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: services
                    .map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text(s.emoji,
                                  style:
                                      const TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Text(s.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: kTextDark,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),

            // 🎁 Scratch card teaser
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD966),
                    Color(0xFFF9C413),
                    Color(0xFFE0AC00)
                  ],
                ),
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
                        Text(
                            'Scratch & win cashback, discounts & more!',
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
            const SizedBox(height: 8),
            Text(
              isEnquiry
                  ? "Check 'My Bookings' for your enquiry status"
                  : "Check 'My Bookings' tab to view your session",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: kTextLight),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Scratch Your Reward 🎉',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceModeSection extends StatelessWidget {
  final String serviceMode;
  final void Function(String) onModeChanged;

  const _ServiceModeSection({
    required this.serviceMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'SERVICE MODE'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorderColor),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              _ModeToggle(
                label: '🖥️  Online',
                subLabel: 'Live virtual session',
                selected: serviceMode == 'online',
                onTap: () => onModeChanged('online'),
              ),
              const SizedBox(width: 5),
              _ModeToggle(
                label: '🏠  Home Visit',
                subLabel: 'Trainer comes to you',
                selected: serviceMode == 'home',
                onTap: () => onModeChanged('home'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}