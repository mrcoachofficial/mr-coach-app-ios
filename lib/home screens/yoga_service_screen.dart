import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:mrcoach/utils/razorpay_payment_helper.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';
import 'package:mrcoach/home%20screens/home2_screen.dart';
import 'package:mrcoach/home%20screens/scratch_card_screen.dart';
import 'package:mrcoach/home%20screens/med_screen.dart';
import 'package:mrcoach/profile_settings_pages/booking_store.dart';

class YogaService {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final ServiceCategory category;

  const YogaService({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
  });
}
enum ServiceFilterCategory {
  fitness,
  physio,
  sports,
  yoga,
  therapy,
  nutrition,
}

extension ServiceFilterCategoryExt on ServiceFilterCategory {
  String get label {
    switch (this) {
      case ServiceFilterCategory.fitness:   return 'Fitness';
      case ServiceFilterCategory.physio:    return 'Physio';
      case ServiceFilterCategory.sports:    return 'Sports';
      case ServiceFilterCategory.yoga:      return 'Yoga';
      case ServiceFilterCategory.therapy:   return 'Therapy';
      case ServiceFilterCategory.nutrition: return 'Nutrition';
    }
  }

  String get emoji {
    switch (this) {
      case ServiceFilterCategory.fitness:   return '🏋️';
      case ServiceFilterCategory.yoga:      return '🧘';
      case ServiceFilterCategory.physio:    return '🩺';
      case ServiceFilterCategory.sports:    return '⚽';
      case ServiceFilterCategory.therapy:   return '🌿';
      case ServiceFilterCategory.nutrition: return '🥗';
    }
  }
}

// ─── Services list with category tags ────────────────────────────
const List<YogaService> kYogaServices = [
  // ── YOGA ──
  YogaService(id: '0',  name: 'Meditation',                description: 'Mindfulness & breathing techniques',           emoji: '🧘', category: ServiceCategory.yoga),
  YogaService(id: '1',  name: 'Online Yoga',               description: 'Live sessions from home',                      emoji: '🖥️', category: ServiceCategory.yoga),
  YogaService(id: '2',  name: 'Power Yoga',                description: 'High-energy strength & flexibility',           emoji: '💪', category: ServiceCategory.yoga),
  YogaService(id: '3',  name: 'Pre / Post Pregnancy Yoga', description: 'Safe yoga for all stages',                     emoji: '🤰', category: ServiceCategory.yoga),
  YogaService(id: '4',  name: 'Stress Relief',             description: 'Calming asanas & relaxation',                  emoji: '🌿', category: ServiceCategory.yoga),
  YogaService(id: '5',  name: 'Therapeutic Yoga',          description: 'Healing & rehabilitation focused',             emoji: '🩺', category: ServiceCategory.yoga),
  YogaService(id: '6',  name: 'Yoga at Home',              description: 'Personalised in-home sessions',                emoji: '🏠', category: ServiceCategory.yoga),
  // ── FITNESS ──
  YogaService(id: '7',  name: 'Strength Training',         description: 'Build muscle & power with expert guidance',    emoji: '🏋️', category: ServiceCategory.fitness),
  YogaService(id: '8',  name: 'Weight Loss',               description: 'Fat-loss programs tailored to your body',      emoji: '⚖️', category: ServiceCategory.fitness),
  YogaService(id: '9',  name: 'Body Toning',               description: 'Sculpt & tone with targeted exercises',        emoji: '🎯', category: ServiceCategory.fitness),
  YogaService(id: '10', name: 'Kids Fitness',              description: 'Fun, age-appropriate fitness programs',        emoji: '🧒', category: ServiceCategory.fitness),
  YogaService(id: '11', name: 'Posture Correction',        description: 'Correct imbalances & improve alignment',       emoji: '🧍', category: ServiceCategory.fitness),
  YogaService(id: '12', name: 'Senior Fitness',            description: 'Gentle fitness for older adults',              emoji: '🧓', category: ServiceCategory.fitness),
  YogaService(id: '13', name: 'Muscle Gain',               description: 'Structured hypertrophy programs',              emoji: '💪', category: ServiceCategory.fitness),
  YogaService(id: '14', name: 'Personal Trainer',          description: 'One-on-one certified trainer sessions',        emoji: '🏅', category: ServiceCategory.fitness),
  // ── PHYSIO ──
  YogaService(id: '15', name: 'Back / Neck / Knee Pain',   description: 'Relieve pain and improve movement.',           emoji: '🩻', category: ServiceCategory.physio),
  YogaService(id: '16', name: 'Elderly Care',              description: 'Help seniors stay active and independent.',    emoji: '👴', category: ServiceCategory.physio),
  YogaService(id: '17', name: 'Home Physiotherapy',        description: 'Professional physiotherapy at home.',          emoji: '🏠', category: ServiceCategory.physio),
  YogaService(id: '18', name: 'Mobility Training',         description: 'Improve balance, flexibility, movement.',      emoji: '🚶', category: ServiceCategory.physio),
  YogaService(id: '19', name: 'Physiotherapist (Home/Online)', description: 'Expert physiotherapy at home or online.',  emoji: '💻', category: ServiceCategory.physio),
  YogaService(id: '20', name: 'Post Surgery Recovery',     description: 'Regain strength after surgery safely.',        emoji: '🏥', category: ServiceCategory.physio),
  YogaService(id: '21', name: 'Posture Correction (Physio)', description: 'Correct body posture with expert guidance.', emoji: '🧍', category: ServiceCategory.physio),
  YogaService(id: '22', name: 'Sports Injury Rehab',       description: 'Recover from sports injuries faster.',         emoji: '⚽', category: ServiceCategory.physio),
  YogaService(id: '23', name: 'Stroke Rehab',              description: 'Specialized rehabilitation after stroke.',     emoji: '🧠', category: ServiceCategory.physio),
  // ── THERAPY ──
  YogaService(id: '24', name: 'Acupressure',               description: 'Stimulate pressure points to reduce pain.',   emoji: '🖐️', category: ServiceCategory.therapy),
  YogaService(id: '25', name: 'Acupuncture',               description: 'Traditional needle therapy for pain relief.', emoji: '🪡', category: ServiceCategory.therapy),
  YogaService(id: '26', name: 'Cupping Therapy',           description: 'Improve blood flow and reduce muscle tension.',emoji: '🥣', category: ServiceCategory.therapy),
  YogaService(id: '27', name: 'Detox Therapy',             description: 'Cleanse your body with natural detox therapies.', emoji: '🌿', category: ServiceCategory.therapy),
  YogaService(id: '28', name: 'Naturopathy',               description: 'Natural healing focused on overall wellness.', emoji: '🍃', category: ServiceCategory.therapy),
  YogaService(id: '29', name: 'Touch Healing',             description: 'Gentle healing for relaxation and balance.',   emoji: '✨', category: ServiceCategory.therapy),
  // ── SPORTS ──
  YogaService(id: '30', name: 'Athletics',                 description: 'Improve speed, stamina, agility.',             emoji: '🏃', category: ServiceCategory.sports),
  YogaService(id: '31', name: 'Badminton',                 description: 'Enhance reflexes, footwork, and strategy.',   emoji: '🏸', category: ServiceCategory.sports),
  YogaService(id: '32', name: 'Boxing / Kickboxing',       description: 'Build strength and self-defense skills.',      emoji: '🥊', category: ServiceCategory.sports),
  YogaService(id: '33', name: 'Cricket',                   description: 'Coaching for batting, bowling, fielding.',     emoji: '🏏', category: ServiceCategory.sports),
  YogaService(id: '34', name: 'Football',                  description: 'Develop teamwork, stamina, ball control.',     emoji: '⚽', category: ServiceCategory.sports),
  YogaService(id: '35', name: 'Karate',                    description: 'Discipline, flexibility, self-defense.',       emoji: '🥋', category: ServiceCategory.sports),
  YogaService(id: '36', name: 'Kids Sports Training',      description: 'Fun sports activities for kids.',              emoji: '🧒', category: ServiceCategory.sports),
  YogaService(id: '37', name: 'Running / Marathon',        description: 'Programs for endurance and marathon prep.',    emoji: '🏃‍♂️', category: ServiceCategory.sports),
  YogaService(id: '38', name: 'Skating',                   description: 'Balance, coordination, and skating techniques.', emoji: '🛼', category: ServiceCategory.sports),
  YogaService(id: '39', name: 'Swimming',                  description: 'Professional swimming sessions.',              emoji: '🏊', category: ServiceCategory.sports),
  // ── NUTRITION ──
  YogaService(id: '40', name: 'Diabetic Diet',             description: 'Balanced meal plans to manage blood sugar.',   emoji: '🩺', category: ServiceCategory.nutrition),
  YogaService(id: '41', name: 'Kids Diet',                 description: 'Nutritious diet plans for growing kids.',      emoji: '🧒', category: ServiceCategory.nutrition),
  YogaService(id: '42', name: 'Muscle Gain Diet',          description: 'High-protein plans for muscle growth.',        emoji: '💪', category: ServiceCategory.nutrition),
  YogaService(id: '43', name: 'Online Diet Consultation',  description: 'Expert nutrition guidance online.',            emoji: '💻', category: ServiceCategory.nutrition),
  YogaService(id: '44', name: 'PCOS Diet',                 description: 'Hormone-friendly meal plans for PCOS.',        emoji: '🌸', category: ServiceCategory.nutrition),
  YogaService(id: '45', name: 'Sports Nutrition',          description: 'Performance nutrition for athletes.',          emoji: '🏋️', category: ServiceCategory.nutrition),
  YogaService(id: '46', name: 'Weight Loss Diet',          description: 'Safe and sustainable weight loss diet.',       emoji: '⚖️', category: ServiceCategory.nutrition),
];

// Helper: map ServiceFilterCategory → ServiceCategory (booking_store enum)
ServiceFilterCategory? _inferFilterCategory(String? serviceName) {
  if (serviceName == null) return null;
  final lower = serviceName.toLowerCase().trim();
  for (final s in kYogaServices) {
    if (s.name.toLowerCase().trim() == lower) {
      switch (s.category) {
        case ServiceCategory.yoga:      return ServiceFilterCategory.yoga;
        case ServiceCategory.fitness:   return ServiceFilterCategory.fitness;
        case ServiceCategory.physio:    return ServiceFilterCategory.physio;
        case ServiceCategory.sports:    return ServiceFilterCategory.sports;
        case ServiceCategory.therapy:   return ServiceFilterCategory.therapy;
        case ServiceCategory.nutrition: return ServiceFilterCategory.nutrition;
        default:                        return null;
      }
    }
  }
  return null;
}

List<YogaService> _filteredServices(ServiceFilterCategory? cat) {
  if (cat == null) return kYogaServices;
  switch (cat) {
    case ServiceFilterCategory.fitness:
      return kYogaServices.where((s) => s.category == ServiceCategory.fitness).toList();
    case ServiceFilterCategory.yoga:
      return kYogaServices.where((s) => s.category == ServiceCategory.yoga).toList();
    case ServiceFilterCategory.physio:
      return kYogaServices.where((s) => s.category == ServiceCategory.physio).toList();
    case ServiceFilterCategory.sports:
      return kYogaServices.where((s) => s.category == ServiceCategory.sports).toList();
    case ServiceFilterCategory.therapy:
      return kYogaServices.where((s) => s.category == ServiceCategory.therapy).toList();
    case ServiceFilterCategory.nutrition:
      return kYogaServices.where((s) => s.category == ServiceCategory.nutrition).toList();
  }
}

const List<String> kYogaTimeSlots = [
  '12:00 AM', '1:00 AM', '2:00 AM', '3:00 AM', '4:00 AM', '5:00 AM', '6:00 AM',
  '7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
  '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM',
  '7:00 PM', '8:00 PM', '9:00 PM', '10:00 PM', '11:00 PM',
];

const Color kPrimary      =Color(0xFFFFD800);
const Color kPrimaryDark  = Color(0xFFFFC107);
const Color kPrimaryLight = Color(0xFFE8F5E9);
const Color kPrimaryBg    = Color(0xFFF1F8F1);
const Color kAccent       = Color(0xFFFFC107);
const Color kTextDark     = Color(0xFF1A2E1A);
const Color kTextMid      = Color(0xFFFFC107);
const Color kTextLight    = Color(0xFFFFC107);
const Color kBorderColor  = Color.fromARGB(255, 230, 227, 200);
const Color kCardSelected = Color(0xFFE8F5E9);

// ─── Main Screen ─────────────────────────────────────────────────
class YogaServiceScreen extends StatefulWidget {
  final String? preSelectedServiceName;
  final String? preSelectedCategory;
  final String? categoryName;

  /// If set to 'demo' or 'enquiry', the confirm sheet for that booking type
  /// opens automatically as soon as the screen loads (skipping the manual
  /// "tap a service in the list" step) — used when arriving here from a
  /// "Book Demo" / "Enquire" button elsewhere with a service already chosen.
  final String? autoBookingType;

  const YogaServiceScreen({
    super.key,
    this.preSelectedServiceName,
    this.preSelectedCategory,
    this.categoryName,
    this.autoBookingType,
  });

  @override
  State<YogaServiceScreen> createState() => _YogaServiceScreenState();
}

class _YogaServiceScreenState extends State<YogaServiceScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, int> _selectedQty = {};
  List<dynamic> _allSlots = [];
  bool _loadingSlots = true;
  late Razorpay _razorpay;
  Map<String, dynamic>? _pendingBookingData;

  String _serviceMode = 'online';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = kYogaTimeSlots[0];

  late TabController _tabController;
  final List<Booking> _sessionBookings = [];

  // Active category filter
  ServiceFilterCategory? _activeCategory;

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
    _fetchSlots();

    // Determine active category from preSelectedCategory/categoryName string OR infer from service name
    final initialCat = widget.preSelectedCategory ?? widget.categoryName;
    if (initialCat != null) {
      final cat = initialCat.toLowerCase().trim();
      _activeCategory = ServiceFilterCategory.values.firstWhere(
        (c) => c.name == cat,
        orElse: () => ServiceFilterCategory.yoga,
      );
    } else if (widget.preSelectedServiceName != null) {
      _activeCategory = _inferFilterCategory(widget.preSelectedServiceName);
    }

    // Pre-select service if name provided
    if (widget.preSelectedServiceName != null) {
      final incomingName = widget.preSelectedServiceName!.toLowerCase().trim();
      for (final service in kYogaServices) {
        if (service.name.toLowerCase().trim() == incomingName) {
          _selectedQty[service.id] = 1;
          break;
        }
      }
    }

    // Auto-open the confirm sheet (Demo or Enquiry) right away if requested
    // and a service is already selected — skips the "tap from list" step.
    if (widget.autoBookingType != null && _selectedQty.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openConfirmSheet(bookingType: widget.autoBookingType!);
      });
    }
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
      if (_selectedQty.containsKey(id)) {
        _selectedQty.remove(id);
      } else {
        _selectedQty[id] = 1;
      }
    });
  }

  void _increment(String id) {
    setState(() {
      _selectedQty[id] = (_selectedQty[id] ?? 0) + 1;
    });
  }

  void _decrement(String id) {
    setState(() {
      final current = _selectedQty[id] ?? 0;
      if (current <= 1) {
        _selectedQty.remove(id);
      } else {
        _selectedQty[id] = current - 1;
      }
    });
  }

  void _remove(String id) {
    setState(() {
      _selectedQty.remove(id);
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
        kYogaServices.where((s) => _selectedQty.containsKey(s.id)).toList();
    final totalQty = _selectedQty.values.fold<int>(0, (a, b) => a + b);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        services: selectedServices,
        serviceQty: _selectedQty,
        serviceMode: _serviceMode,
        sessionDate: _selectedDate,
        sessionTime: _selectedTime,
        bookingType: bookingType,
        initialSessionCount: totalQty,
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
    final discount = (data['discountAmount'] as num?)?.toDouble() ?? 0.0;
    final basePrice = isDemo ? (99.0 * sessionCount) : 0.0;
    final price = math.max(0.0, basePrice - discount);

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
      // Free Enquiry Flow or fully discounted voucher flow
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
    final discount = (data['discountAmount'] as num?)?.toDouble() ?? 0.0;
    final appliedVoucherCode = data['appliedVoucherCode'] as String?;

    final serviceNameString = services.map((s) {
      final qty = _selectedQty[s.id] ?? 1;
      return qty > 1 ? '${s.name} (x$qty)' : s.name;
    }).join(', ');

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
      'price': isDemo ? math.max(0.0, (99.0 * sessionCount) - discount) : 0,
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
      'priceRange': data['priceRange'],
    });

    if (!result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
      return; // Stop if the backend rejected it (e.g., not logged in)
    }

    // Mark voucher as used if successful
    if (appliedVoucherCode != null) {
      await ApiService.useVoucher(appliedVoucherCode);
    }
    // -----------------------

    GlobalScratchCard? rewardCard;
    if (result['reward'] != null) {
      rewardCard = GlobalScratchCard.fromJson(result['reward']);
      ScratchCardStore().addCard(rewardCard);
    }
    
    final primaryService = services.first;
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
      totalAmount: isDemo ? math.max(0.0, (99.0 * sessionCount) - discount).toInt() : 0,
      bookedAt: DateTime.now(),
    );
    BookingStore.instance.addBooking(globalBooking);

    setState(() {
      _sessionBookings.add(globalBooking);
      _selectedQty.clear();
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
      setState(() => _selectedDate = picked);
      _updateSelectedTimeForDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedServices =
        kYogaServices.where((s) => _selectedQty.containsKey(s.id)).toList();

    return Scaffold(
      backgroundColor: kPrimaryBg,
      body: Column(
        children: [
          // ── Top Bar with back button ──
          _TopBar(activeCategory: _activeCategory),

          // ── Category Filter Chips ──
          _CategoryFilterBar(
            activeCategory: _activeCategory,
            onCategoryChanged: (cat) {
              setState(() {
                _activeCategory = cat;
                // Clear selections that don't belong to new category
                if (cat != null) {
                  final visibleIds = _filteredServices(cat).map((s) => s.id).toSet();
                  _selectedQty.removeWhere((id, _) => !visibleIds.contains(id));
                }
              });
            },
          ),

          if (selectedServices.isNotEmpty)
            _SelectedServicesBar(
              services: selectedServices,
              qtyOf: (id) => _selectedQty[id] ?? 1,
              onRemove: (id) => _remove(id),
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
                  selectedQty: _selectedQty,
                  onToggle: _toggle,
                  onIncrement: _increment,
                  onDecrement: _decrement,
                  serviceMode: _serviceMode,
                  onModeChanged: (m) => setState(() => _serviceMode = m),
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onPickDate: _pickDate,
                  onTimeChanged: (t) => setState(() => _selectedTime = t),
                  preSelectedServiceName: widget.preSelectedServiceName,
                  activeCategory: _activeCategory,
                  availableTimeSlots: _availableTimeSlotsForSelectedDate,
                ),
                _MyBookingsTab(bookings: _sessionBookings),
              ],
            ),
          ),

          _BottomBar(
            enabled: _selectedQty.isNotEmpty,
            bookingCount: _sessionBookings.length,
            onBookDemo: () => _openConfirmSheet(bookingType: 'demo'),
            onEnquire: () => _openConfirmSheet(bookingType: 'enquiry'),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar with Back Button ────────────────────────────────────
class _TopBar extends StatelessWidget {
  final ServiceFilterCategory? activeCategory;
  const _TopBar({this.activeCategory});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final title = activeCategory != null
        ? '${activeCategory!.emoji}  ${activeCategory!.label}'
        : '✨  Services';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(8, topPad + 8, 16, 10),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderColor),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: kYellow,
                size: 16,
              ),
            ),
          ),
          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
          ),
          // Price badges
          
          
        ],
      ),
    );
  }
}

// ─── Category Filter Bar ─────────────────────────────────────────
class _CategoryFilterBar extends StatelessWidget {
  final ServiceFilterCategory? activeCategory;
  final void Function(ServiceFilterCategory?) onCategoryChanged;

  const _CategoryFilterBar({
    required this.activeCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     // color: Colors.white,
      //padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      // child: SizedBox(
      //   height: 40,
      //   child: ListView(
      //     scrollDirection: Axis.horizontal,
      //     children: [
            // "All" chip
            // _CategoryChip(
            //   label: 'All',
            //   emoji: '🔎',
            //   isActive: activeCategory == null,
            //   onTap: () => onCategoryChanged(null),
            // ),
            // const SizedBox(width: 8),
            // ...ServiceFilterCategory.values.map((cat) => Padding(
            //       padding: const EdgeInsets.only(right: 8),
            //       child: _CategoryChip(
            //         label: cat.label,
            //         emoji: cat.emoji,
            //         isActive: activeCategory == cat,
            //         onTap: () => onCategoryChanged(
            //             activeCategory == cat ? null : cat),
            //       ),
               // )
              //  ),
      //     ],
      //   ),
      // ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kYellow : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? kYellow : kBorderColor,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: kYellow.withOpacity(0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Selected Services Bar ────────────────────────────────────────
class _SelectedServicesBar extends StatelessWidget {
  final List<YogaService> services;
  final int Function(String id) qtyOf;
  final void Function(String id) onRemove;

  const _SelectedServicesBar({
    required this.services,
    required this.qtyOf,
    required this.onRemove,
  });

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
                final qty = qtyOf(s.id);
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
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      if (qty > 1) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '×$qty',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ],
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

// ─── Services Tab ─────────────────────────────────────────────────
// ─── Services Tab ─────────────────────────────────────────────────
class _ServicesTab extends StatelessWidget {
  final Map<String, int> selectedQty;
  final void Function(String) onToggle;
  final void Function(String) onIncrement;
  final void Function(String) onDecrement;
  final String serviceMode;
  final void Function(String) onModeChanged;
  final DateTime selectedDate;
  final String selectedTime;
  final VoidCallback onPickDate;
  final void Function(String) onTimeChanged;
  final String? preSelectedServiceName;
  final ServiceFilterCategory? activeCategory;
  final List<String> availableTimeSlots;

  const _ServicesTab({
    required this.selectedQty,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.serviceMode,
    required this.onModeChanged,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onTimeChanged,
    required this.availableTimeSlots,
    this.preSelectedServiceName,
    this.activeCategory,
  });

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final visibleServices = _filteredServices(activeCategory);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      children: [
        // Pre-selected info banner
        if (preSelectedServiceName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

        _SectionLabel(label: 'SERVICE MODE'),
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

        const SizedBox(height: 20),

        _SectionLabel(label: 'SELECT DATE & TIME'),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: onPickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          style: TextStyle(fontSize: 11, color: kYellow)),
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
                      color: isSelected ? const Color.fromARGB(255, 4, 3, 3) : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 22),

        // Section label with count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(
              label: activeCategory != null
                  ? '${activeCategory!.label.toUpperCase()} SERVICES'
                  : 'AVAILABLE SERVICES',
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorderColor),
              ),
              child: Text(
                '${visibleServices.length} services',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kTextDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Row(
          children: [
            Icon(Icons.touch_app_rounded, size: 13, color: kYellow),
            SizedBox(width: 5),
            Text('Tap to select, then use +/- to add more of the same service',
                style: TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 14),

        ...visibleServices.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ServiceCard(
                service: s,
                qty: selectedQty[s.id] ?? 0,
                isPreSelected: preSelectedServiceName != null &&
                    s.name.toLowerCase().trim() ==
                        preSelectedServiceName!.toLowerCase().trim(),
                onTap: () => onToggle(s.id),
                onIncrement: () => onIncrement(s.id),
                onDecrement: () => onDecrement(s.id),
              ),
            )),

        const SizedBox(height: 14),
        if (selectedQty.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total quantity selected',
                    style: TextStyle(
                        fontSize: 13,
                        color: kYellow,
                        fontWeight: FontWeight.w500)),
                Text(
                  '${selectedQty.values.fold<int>(0, (a, b) => a + b)}',
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

// ─── Section Label ────────────────────────────────────────────────
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

// ─── Mode Toggle ──────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? kYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8) : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── My Bookings Tab ──────────────────────────────────────────────
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
              style: TextStyle(fontSize: 13, color: kYellow, height: 1.5),
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

// ─── Booking Card ─────────────────────────────────────────────────
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
                  const Color(0xFF66BB6A),
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
                    isEnquiry ? 'Enquiry #$index' : 'Demo Session #$index',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              style: const TextStyle(fontSize: 11, color: Color(0xFFE8F5E9))),

          if (!isEnquiry && (booking.customerName ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.person_rounded, size: 13, color: Colors.white70),
              const SizedBox(width: 4),
              Text(booking.customerName!,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              if ((booking.customerPhone ?? '').isNotEmpty) ...[
                const SizedBox(width: 10),
                const Icon(Icons.phone_rounded, size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Text(booking.customerPhone!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ]),
          ],

          if (isEnquiry && (booking.enquirerName ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.person_rounded, size: 13, color: Colors.white70),
              const SizedBox(width: 4),
              Text(booking.enquirerName!,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              if ((booking.enquirerPhone ?? '').isNotEmpty) ...[
                const SizedBox(width: 10),
                const Icon(Icons.phone_rounded, size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Text(booking.enquirerPhone!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ]),
          ],

          if (!isEnquiry && (booking.address ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 13, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(booking.address!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ],

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(
                icon: isOnline ? Icons.videocam_rounded : Icons.home_rounded,
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
              // const Text('Yoga & Wellness',
              //     style: TextStyle(
              //         fontSize: 13,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white)),
              Text(
                isEnquiry ? 'Enquiry — FREE' : '₹${booking.totalAmount} — Cash',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────
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

// ─── Service Card (now with a quantity "multiply" stepper) ───────
class _ServiceCard extends StatelessWidget {
  final YogaService service;
  final int qty; // 0 = not selected
  final bool isPreSelected;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ServiceCard({
    required this.service,
    required this.qty,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
    this.isPreSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = qty > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? kCardSelected : Colors.white,
          border: Border.all(
            color: isSelected
                ? kYellow
                : isPreSelected
                    ? kYellow.withOpacity(0.5)
                    : const Color(0xFFDEEDE0),
            width: isSelected ? 1.8 : isPreSelected ? 1.5 : 1,
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
                color: isSelected ? kPrimaryLight : const Color(0xFFF0F7F0),
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
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: kTextDark,
                          ),
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
                    style: const TextStyle(fontSize: 12, color: kTextLight),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // ── Quantity "multiply" stepper (shown once selected) ──
            isSelected
                ? Container(
                    decoration: BoxDecoration(
                      color: kYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onDecrement,
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(Icons.remove_rounded,
                                size: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onIncrement,
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(Icons.add_rounded,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: kBorderColor, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 0, 0, 0)),
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
                      color: enabled ? kYellow : const Color(0xFFCCCCCC),
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
                            color: enabled ? const Color.fromARGB(255, 0, 0, 0) : const Color(0xFFAAAAAA)),
                      ),
                      Text(
                        'FREE',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: enabled ? const Color.fromARGB(255, 0, 0, 0) : const Color(0xFFAAAAAA)),
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
                    backgroundColor: kYellow,
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
                            color: Color.fromARGB(255, 0, 0, 0)),
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

// ─── Confirm Sheet ────────────────────────────────────────────────
class _ConfirmSheet extends StatefulWidget {
  final List<YogaService> services;
  final Map<String, int> serviceQty;
  final String serviceMode;
  final DateTime sessionDate;
  final String sessionTime;
  final String bookingType;
  final int initialSessionCount;
  final void Function(Map<String, dynamic> data) onConfirm;

  const _ConfirmSheet({
    required this.services,
    required this.serviceQty,
    required this.serviceMode,
    required this.sessionDate,
    required this.sessionTime,
    required this.bookingType,
    required this.initialSessionCount,
    required this.onConfirm,
  });

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  int _sessionCount = 1;
  late final TextEditingController _sessionCountController;
  final _nameController         = TextEditingController();
  final _phoneController        = TextEditingController();
  final _addressController      = TextEditingController();
  final _emailController        = TextEditingController();
  final _stateController        = TextEditingController();
  final _districtController     = TextEditingController();
  final _areaController         = TextEditingController();
  final _pincodeController      = TextEditingController();
  int _selectedPriceIndex = 0;
  List<dynamic> _priceTiers = [];
  bool _loadingTiers = true;

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

  String? _appliedVoucherCode;
  int _discountAmount = 0;
  final _voucherController = TextEditingController();
  bool _applyingVoucher = false;
  String? _voucherError;
  String? _voucherSuccess;

  @override
  void initState() {
    super.initState();
    _sessionCount = widget.initialSessionCount < 1 ? 1 : widget.initialSessionCount;
    _sessionCountController = TextEditingController(text: '$_sessionCount');
    _sessionCountController.addListener(() {
      final val = int.tryParse(_sessionCountController.text);
      if (val != null && val >= 1) setState(() => _sessionCount = val);
    });
    _loadUserProfile();
    _fetchPriceTiers();
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
    _voucherController.dispose();
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

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _applyingVoucher = true;
      _voucherError = null;
      _voucherSuccess = null;
    });

    final res = await ApiService.applyVoucher(code);
    setState(() => _applyingVoucher = false);

    if (res['success'] == true) {
      final amt = (res['voucher']?['amount'] as num?)?.toInt() ?? 0;
      setState(() {
        _appliedVoucherCode = code;
        _discountAmount = amt;
        _voucherSuccess = 'Voucher applied! ₹$amt discount.';
      });
    } else {
      setState(() {
        _voucherError = res['message'] ?? 'Invalid or expired voucher code';
        _appliedVoucherCode = null;
        _discountAmount = 0;
      });
    }
  }

  bool get _isQuestionnaireComplete {
    final email = _emailController.text.trim();
    final isEmailValid = email.isEmpty || (email.contains('@') && email.contains('.'));
    final pincode = _pincodeController.text.trim();
    final isPincodeValid = pincode.isEmpty || pincode.length == 6;
    final isAddressValid = widget.serviceMode == 'online' || _addressController.text.trim().isNotEmpty;
    
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().length == 10 &&
        isEmailValid &&
        isPincodeValid &&
        isAddressValid;
  }

  bool get _canProceed {
    return _isQuestionnaireComplete;
  }

  String _getValidationMessage() {
    if (_nameController.text.trim().isEmpty) return 'Please enter your name';
    if (_phoneController.text.trim().length != 10) return 'Please enter a valid 10-digit phone number';
    
    final email = _emailController.text.trim();
    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      return 'Please enter a valid email address';
    }
    final pincode = _pincodeController.text.trim();
    if (pincode.isNotEmpty && pincode.length != 6) {
      return 'Please enter a 6-digit pincode';
    }
    if (widget.serviceMode != 'online' && _addressController.text.trim().isEmpty) {
      return 'Please enter your home address';
    }
    return '';
  }

  Future<void> _fetchPriceTiers() async {
    try {
      final tiers = await ApiService.getCoachPriceTiers();
      if (mounted) {
        setState(() {
          _priceTiers = tiers.isNotEmpty ? tiers : _defaultPriceTiers;
          _loadingTiers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _priceTiers = _defaultPriceTiers;
          _loadingTiers = false;
        });
      }
    }
  }

  static const List<Map<String, dynamic>> _defaultPriceTiers = [
    { 'min': 0, 'max': 700, 'label': 'Entry Level Coaches', 'icon': 'person', 'color': '#2196F3' },
    { 'min': 700, 'max': 1000, 'label': 'Entry to Mid Level', 'icon': 'person', 'color': '#FFFF9800' },
    { 'min': 1000, 'max': 1200, 'label': 'Medium Level Coaches', 'icon': 'headset_mic', 'color': '#E91E63' },
    { 'min': 1200, 'max': 3000, 'label': 'Premium Level Coaches', 'icon': 'workspace_premium', 'color': '#FBC02D', 'isPlus': true }
  ];

  String _getPriceRangeString(int index) {
    if (index < 0 || index >= _priceTiers.length) return '₹0 - ₹700';
    final tier = _priceTiers[index];
    final min = tier['min'];
    final max = tier['max'];
    final isLast = index == _priceTiers.length - 1;
    return isLast ? '₹$min - ₹$max+' : '₹$min - ₹$max';
  }

  Widget _buildPriceCard({
    required int index,
    required String range,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPriceIndex = index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSelected ? 1.0 : 0.4,
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            border: Border.all(
              color: isSelected ? color : kBorderColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                range,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : kTextDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                  ...widget.services.map((s) {
                    final qty = widget.serviceQty[s.id] ?? 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text(s.emoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            qty > 1 ? '${s.name} (x$qty)' : s.name,
                            style: const TextStyle(
                                fontSize: 13,
                                color: kTextDark,
                                fontWeight: FontWeight.w500,
                                height: 1.8),
                          ),
                        ],
                      ),
                    );
                  }),
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
              'Your email address (Optional)',
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
              enabled: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 16),

            // Section 2: Personal Details
            const Text('PERSONAL DETAILS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 1.0)),
            const SizedBox(height: 10),
            
            const Text('Gender (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
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
                Expanded(child: _buildTextField(_stateController, 'State (Optional)', Icons.map_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_districtController, 'District (Optional)', Icons.location_city_outlined)),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildTextField(_areaController, 'Area / Locality (Optional)', Icons.near_me_outlined)),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _pincodeController,
                    'Pincode (Optional)',
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

            const Text('When do you want to start plan? (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
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
                          ? 'Select Start Plan Date (Optional)'
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

            const Text('Available Days for Practice (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
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

            const Text('How did you hear about us? (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
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
                  hint: const Text('Select Referral Source (Optional)', style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13)),
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

            const SizedBox(height: 16),
            const Text('PRICE PREFERENCE',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 1.0)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Please provide the pricing range for coaching services.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark)),
                const SizedBox(width: 4),
                Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16),

            // Custom Slider
            if (_loadingTiers)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(color: kYellow),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _PriceRangeSlider(
                  selectedIndex: _selectedPriceIndex,
                  steps: () {
                    final steps = <String>[];
                    if (_priceTiers.isNotEmpty) {
                      steps.add(_priceTiers[0]['min'].toString());
                      for (var i = 0; i < _priceTiers.length; i++) {
                        final isLast = i == _priceTiers.length - 1;
                        final maxVal = _priceTiers[i]['max'];
                        steps.add(isLast ? '$maxVal+' : '$maxVal');
                      }
                    }
                    return steps;
                  }(),
                  onChanged: (idx) => setState(() => _selectedPriceIndex = idx),
                ),
              ),

              const SizedBox(height: 16),

              // Cards Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_priceTiers.length, (idx) {
                    final tier = _priceTiers[idx];
                    final min = tier['min'];
                    final max = tier['max'];
                    final isLast = idx == _priceTiers.length - 1;
                    final rangeText = isLast ? '₹$min - ₹$max+' : '₹$min - ₹$max';
                    
                    Color cardColor = const Color(0xFF2196F3);
                    if (tier['color'] != null) {
                      final hexStr = tier['color'].toString().replaceAll('#', '');
                      if (hexStr.length == 6) {
                        cardColor = Color(int.parse('FF$hexStr', radix: 16));
                      } else if (hexStr.length == 8) {
                        cardColor = Color(int.parse(hexStr, radix: 16));
                      }
                    }
                    
                    IconData cardIcon = Icons.person;
                    if (tier['icon'] == 'headset_mic') {
                      cardIcon = Icons.headset_mic;
                    } else if (tier['icon'] == 'workspace_premium') {
                      cardIcon = Icons.workspace_premium;
                    }

                    return Padding(
                      padding: EdgeInsets.only(right: idx == _priceTiers.length - 1 ? 0.0 : 8.0),
                      child: _buildPriceCard(
                        index: idx,
                        range: rangeText,
                        label: tier['label'] ?? '',
                        icon: cardIcon,
                        color: cardColor,
                        isSelected: _selectedPriceIndex == idx,
                      ),
                    );
                  }),
                ),
              ),
            ],

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
            if (!isEnquiry) ...[
              const Text('VOUCHER / PROMO CODE (OPTIONAL)',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFAAAAAA),
                      letterSpacing: 1.0)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _voucherController,
                      'Enter voucher code (Optional)',
                      Icons.card_giftcard_rounded,
                      textCapitalization: TextCapitalization.characters,
                      enabled: !_applyingVoucher,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _applyingVoucher ? null : _applyVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kYellow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _applyingVoucher
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Apply',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              if (_voucherError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _voucherError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              if (_voucherSuccess != null) ...[
                const SizedBox(height: 6),
                Text(
                  _voucherSuccess!,
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
            ],

            const Divider(color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEnquiry ? 'Enquiry charge' : 'Demo session subtotal',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF666666)),
                      ),
                      Text(
                        isEnquiry ? 'FREE' : '₹$totalAmount',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isEnquiry ? kPrimary : kTextDark),
                      ),
                    ],
                  ),
                  if (!isEnquiry && _discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Voucher Discount',
                          style: TextStyle(
                              fontSize: 14, color: Colors.green),
                        ),
                        Text(
                          '-₹$_discountAmount',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  if (!isEnquiry) ...[
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: kTextDark),
                        ),
                        Text(
                          '₹${math.max(0, totalAmount - _discountAmount)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: kTextDark),
                        ),
                      ],
                    ),
                  ],
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
                            'appliedVoucherCode': _appliedVoucherCode,
                            'discountAmount': _discountAmount,
                            'priceRange': _getPriceRangeString(_selectedPriceIndex),
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
                            Text('Confirm & Pay — ₹${math.max(0, totalAmount - _discountAmount)}',
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
                        color: Colors.black,
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

class _PriceRangeSlider extends StatelessWidget {
  final int selectedIndex;
  final List<String> steps;
  final ValueChanged<int> onChanged;

  const _PriceRangeSlider({
    required this.selectedIndex,
    required this.steps,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final numSteps = steps.length;
    final maxStepsIndex = numSteps > 1 ? numSteps - 1 : 1;
    
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final stepWidth = width / maxStepsIndex;
            
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background track
                Container(
                  height: 4,
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Highlighted track (yellow)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  width: stepWidth * (selectedIndex + 1),
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Step nodes (dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(numSteps, (index) {
                    final activeDotIndex = selectedIndex + 1;
                    final isReached = index <= activeDotIndex;
                    return GestureDetector(
                      onTap: () {
                        if (index == 0 || index == 1) {
                          onChanged(0);
                        } else {
                          onChanged(index - 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.transparent,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isReached ? kYellow : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isReached ? kYellow : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        // Step Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((step) => Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          )).toList(),
        ),
      ],
    );
  }
}