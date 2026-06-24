import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mrcoach/events/events_screen.dart';
import 'package:mrcoach/home%20screens/home2_screen.dart'
    hide kYellowNav, kGreyText, kPrimary, kSubText, kWhite;
import 'package:mrcoach/home%20screens/yoga_service_screen.dart' hide kPrimary;
import 'package:mrcoach/profile_settings_pages/profile_screen.dart'
    hide kPrimary, kPrimaryDeep;
import 'package:mrcoach/webview_screen.dart';
import 'package:mrcoach/services/api_service.dart';

Future<void> _launchEventsUrl() async {
  final Uri url = Uri.parse('https://www.mrcoach.in/events');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

// ── Colours ───────────────────────────────────────────────────────────────────
const Color kYellow      = Color(0xFFFFD60A);
const Color kYellowNav   = Color(0xFFF9C413);
const Color kGreyText    = Color(0xFF888888);
const Color kBlack       = Color(0xFF1A1A1A);
const Color kWhite       = Color(0xFFFFFFFF);
const Color kPrimary     = Color(0xFFF9C413);
const Color kPrimaryDeep = Color(0xFFE6A800);
const Color kSubText     = Color(0xFF888888);
const Color kDarkText    = Color(0xFF1A1A1A);

// ── Navigation helper ─────────────────────────────────────────────────────────
PageRoute _route(Widget page) =>
    MaterialPageRoute(builder: (_) => page);

// ── Models ────────────────────────────────────────────────────────────────────
class ServiceItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final int durationMinutes;
  final List<String> highlights;
  final List<String> includes;

  const ServiceItem(
    this.title,
    this.description,
    this.imageUrl, {
    this.id = '',
    this.price = 0.0,
    this.durationMinutes = 60,
    this.highlights = const [
      'Expert-guided personalized sessions',
      'Suitable for all fitness levels',
      'Results-driven approach',
      'Monitored progress tracking',
    ],
    this.includes = const [
      'Initial assessment & goal setting',
      'Customized plan designed for you',
      'One-on-one expert guidance',
      'Follow-up & progress review',
    ],
  });
}

class ServiceCategory {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentDark;
  final List<ServiceItem> items;

  const ServiceCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accentDark,
    required this.items,
  });
}

// ── Data ──────────────────────────────────────────────────────────────────────
final List<ServiceCategory> categories = [
  ServiceCategory(
    name: 'Fitness',
    subtitle:
        'Customized workout plans to build strength, improve endurance & achieve your goals.',
    icon: Icons.fitness_center,
    iconColor: kYellowNav,
    iconBg: const Color(0xFFFFF8E1),
    accentDark: kYellowNav,
    items: [
      ServiceItem(
        'Strength Training',
        'Build muscle, increase strength & power with progressive overload programs.',
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
        highlights: [
          'Progressive overload techniques',
          'Compound & isolation training',
          'Recovery & rest protocol',
          'Strength benchmarking',
        ],
        includes: [
          'Strength baseline test',
          'Periodized training plan',
          'Form & technique coaching',
          'Monthly strength review',
        ],
      ),
      ServiceItem(
        'Weight Loss',
        'Lose weight, burn fat & improve overall fitness with science-backed techniques.',
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
        highlights: [
          'Personalized fat-loss strategy',
          'BMI & body composition tracking',
          'Nutrition guidance included',
          'Weekly progress assessments',
        ],
        includes: [
          'Full body assessment',
          'Custom workout plan',
          'Diet recommendations',
          'Progress tracking sessions',
        ],
      ),
      ServiceItem(
        'Body Toning',
        'Sculpt and tone your body with targeted exercises and smart training techniques.',
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
        highlights: [
          'Progressive overload techniques',
          'Compound & isolation training',
          'Recovery & rest protocol',
          'Strength benchmarking',
        ],
        includes: [
          'Strength baseline test',
          'Periodized training plan',
          'Form & technique coaching',
          'Monthly strength review',
        ],
      ),
      ServiceItem(
        'Kids Fitness',
        'Fun, safe and age-appropriate fitness programs designed for growing children.',
        'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=400',
      ),
      ServiceItem(
        'Posture Correction',
        'Correct postural imbalances and improve alignment through targeted therapy.',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      ),
      ServiceItem(
        'Senior Fitness',
        'Gentle, effective fitness programs for older adults to improve strength and mobility.',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      ),
      ServiceItem(
        'Muscle Gain',
        'Build lean muscle mass with structured hypertrophy programs and expert guidance.',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      ),
      ServiceItem(
        'Personal Trainer',
        'One-on-one training sessions with certified personal trainers for maximum results.',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      ),
    ],
  ),
  ServiceCategory(
    name: 'Physiotherapy',
    subtitle: 'Expert care for pain relief, injury recovery & improved mobility.',
    icon: Icons.self_improvement,
    iconColor: kYellowNav,
    iconBg: const Color(0xFFFFF8E1),
    accentDark: kYellowNav,
    items: [
      ServiceItem(
        'Back / Neck / Knee Pain',
        'Relieve pain and improve movement with expert physiotherapy care.',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        highlights: [
          'Root-cause pain diagnosis',
          'Manual therapy techniques',
          'Electrotherapy options available',
          'Home exercise programs',
        ],
        includes: [
          'Comprehensive pain assessment',
          'Personalized treatment plan',
          'In-clinic therapy sessions',
          'Home care guidelines',
        ],
      ),
      ServiceItem(
        'Elderly Care',
        'Personalized support to help seniors stay active and independent.',
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400',
      ),
      ServiceItem(
        'Home Physiotherapy',
        'Professional physiotherapy treatment at the comfort of your home.',
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
      ),
      ServiceItem(
        'Mobility Training',
        'Improve balance, flexibility, and daily movement with guided training.',
        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
      ),
      ServiceItem(
        'Post Surgery Recovery',
        'Speed up recovery and regain strength after surgery safely.',
        '',
      ),
      ServiceItem(
        'Sports Injury Rehab',
        'Recover from sports injuries and return to peak performance faster.',
        '',
      ),
      ServiceItem(
        'Stroke Rehab',
        'Specialized rehabilitation to improve strength and daily functioning after stroke.',
        '',
      ),
    ],
  ),
  ServiceCategory(
    name: 'Sports',
    subtitle:
        'Professional sports training programs to improve performance, strength, speed & endurance.',
    icon: Icons.sports_soccer,
    iconColor: kYellowNav,
    iconBg: const Color(0xFFFFF8E1),
    accentDark: kYellowNav,
    items: [
      ServiceItem(
        'Athletics',
        'Improve speed, stamina, agility, and overall athletic performance.',
        'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=400',
        highlights: [
          'Sprint & endurance training',
          'Strength and conditioning',
          'Agility improvement drills',
          'Performance tracking',
        ],
        includes: [
          'Fitness assessment',
          'Customized training plan',
          'Weekly performance review',
          'Professional coaching',
        ],
      ),
      ServiceItem(
        'Badminton',
        'Enhance reflexes, footwork, and game strategy with expert badminton coaching.',
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=400',
      ),
      ServiceItem(
        'Boxing / Kickboxing',
        'Build strength, endurance, and self-defense skills with combat training.',
        'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?w=400',
      ),
      ServiceItem(
        'Cricket',
        'Professional cricket coaching focused on batting, bowling, and fielding skills.',
        'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400',
      ),
      ServiceItem(
        'Football',
        'Develop teamwork, stamina, ball control, and match performance.',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400',
      ),
      ServiceItem(
        'Karate',
        'Learn discipline, self-defense, flexibility, and martial arts techniques.',
        'https://images.unsplash.com/photo-1517438476312-10d79c077509?w=400',
      ),
      ServiceItem(
        'Kids Sports Training',
        'Fun and engaging sports activities designed specially for kids.',
        'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=400',
      ),
      ServiceItem(
        'Running / Marathon',
        'Structured running programs to improve endurance and marathon preparation.',
        'https://images.unsplash.com/photo-1486218119243-13883505764c?w=400',
      ),
      ServiceItem(
        'Skating',
        'Learn balance, coordination, and skating techniques from trained professionals.',
        'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400',
      ),
      ServiceItem(
        'Swimming',
        'Professional swimming sessions for fitness, technique, and water confidence.',
        'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=400',
      ),
    ],
  ),
  ServiceCategory(
    name: 'Yoga',
    subtitle:
        'Yoga sessions for flexibility, stress relief, better well-being & mind-body balance.',
    icon: Icons.spa,
    iconColor: kYellowNav,
    iconBg: const Color(0xFFFFF8E1),
    accentDark: kYellowNav,
    items: [
      ServiceItem(
        'Meditation',
        'Practice mindfulness & guided meditation techniques to improve mental clarity, focus & inner peace.',
        'https://images.unsplash.com/photo-1508672019048-805c876b67e2?w=400',
        highlights: [
          'Mindfulness practices',
          'Breathing techniques',
          'Stress reduction methods',
          'Improves emotional balance',
        ],
        includes: [
          'Guided meditation sessions',
          'Relaxation exercises',
          'Daily mindfulness tips',
          'Personal wellness tracking',
        ],
      ),
      ServiceItem(
        'Power Yoga',
        'High-energy yoga sessions focused on strength, endurance, flexibility & full-body fitness.',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
        highlights: [
          'Strength-building poses',
          'Dynamic yoga flow',
          'Improves stamina',
          'Full-body workout',
        ],
        includes: [
          'Warm-up & mobility drills',
          'Advanced yoga sequences',
          'Core strengthening exercises',
          'Fitness progress guidance',
        ],
      ),
      ServiceItem(
        'Pre / Post Pregnancy Yoga',
        'Gentle yoga practices designed to support mothers during pregnancy & postpartum recovery.',
        'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?w=400',
        highlights: [
          'Safe pregnancy exercises',
          'Improves flexibility & posture',
          'Supports recovery after delivery',
          'Breathing & relaxation focus',
        ],
        includes: [
          'Trimester-based yoga routines',
          'Postnatal recovery sessions',
          'Pelvic floor strengthening',
          'Guided relaxation techniques',
        ],
      ),
      ServiceItem(
        'Stress Relief',
        'Relaxing yoga & breathing exercises to reduce stress, anxiety & mental fatigue naturally.',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400',
        highlights: [
          'Deep relaxation techniques',
          'Breath-focused sessions',
          'Calms the nervous system',
          'Improves sleep quality',
        ],
        includes: [
          'Restorative yoga practices',
          'Meditation guidance',
          'Stress management support',
          'Relaxation music sessions',
        ],
      ),
      ServiceItem(
        'Therapeutic Yoga',
        'Healing-focused yoga practices designed to support pain relief, recovery & overall wellness.',
        'https://images.unsplash.com/photo-1518611012118-fbdf8dcb0fd4?w=400',
        highlights: [
          'Pain management support',
          'Improves mobility & posture',
          'Gentle therapeutic movements',
          'Customized healing sessions',
        ],
        includes: [
          'Personalized therapy assessment',
          'Therapeutic yoga routines',
          'Breathing & recovery techniques',
          'Lifestyle wellness guidance',
        ],
      ),
    ],
  ),
  ServiceCategory(
    name: 'Therapy',
    subtitle:
        'Natural healing therapies focused on pain relief, relaxation, recovery & overall wellness.',
    icon: Icons.healing,
    iconColor: kYellowNav,
    iconBg: const Color(0xFFFFF8E1),
    accentDark: kYellowNav,
    items: [
      ServiceItem(
        'Acupressure',
        'Stimulate pressure points to reduce pain, improve circulation, and promote natural healing.',
        'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?w=400',
        highlights: [
          'Natural pain relief therapy',
          'Stress and tension reduction',
          'Improves blood circulation',
          'Boosts energy flow',
        ],
        includes: [
          'Pressure point assessment',
          'Personalized therapy session',
          'Relaxation techniques',
          'Wellness guidance',
        ],
      ),
      ServiceItem(
        'Acupuncture',
        'Traditional therapy using fine needles to restore balance and relieve pain.',
        'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=400',
      ),
      ServiceItem(
        'Cupping Therapy',
        'Improve blood flow, reduce muscle tension, and support recovery through cupping therapy.',
        'https://images.unsplash.com/photo-1518611012118-fb8f2f7db0b7?w=400',
      ),
      ServiceItem(
        'Detox Therapy',
        'Cleanse and refresh your body with therapies designed to remove toxins naturally.',
        'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400',
      ),
      ServiceItem(
        'Naturopathy',
        'Holistic natural treatments focused on healing through lifestyle and natural remedies.',
        'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400',
      ),
      ServiceItem(
        'Touch Healing',
        'Gentle healing techniques that promote relaxation, balance, and emotional wellness.',
        'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=400',
      ),
    ],
  ),
  ServiceCategory(
    name: 'Nutrition',
    subtitle:
        'Personalized nutrition plans to support healthy living, fitness goals & overall wellness.',
    icon: Icons.restaurant_menu,
    iconColor: kYellowNav,
    iconBg: const Color(0xFFFFF8E1),
    accentDark: kYellowNav,
    items: [
      ServiceItem(
        'Diabetic Diet',
        'Balanced meal plans designed to help manage blood sugar levels and improve overall health.',
        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
        highlights: [
          'Blood sugar friendly meals',
          'Balanced nutrition planning',
          'Healthy lifestyle support',
          'Improved energy management',
        ],
        includes: [
          'Diet consultation',
          'Customized meal plan',
          'Nutrition tracking guidance',
          'Lifestyle recommendations',
        ],
      ),
      ServiceItem(
        'Kids Diet',
        'Healthy and nutritious meal plans specially designed for growing children.',
        'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=400',
        highlights: [
          'Growth-focused nutrition',
          'Healthy eating habits',
          'Balanced meal planning',
          'Immunity support',
        ],
        includes: [
          'Child nutrition assessment',
          'Personalized diet chart',
          'Healthy snack ideas',
          'Parent guidance support',
        ],
      ),
      ServiceItem(
        'Muscle Gain Diet',
        'Protein-rich nutrition plans to support muscle growth, strength, and recovery.',
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
        highlights: [
          'High-protein meal plans',
          'Muscle recovery support',
          'Strength-focused nutrition',
          'Calorie surplus guidance',
        ],
        includes: [
          'Body assessment',
          'Customized muscle gain plan',
          'Supplement guidance',
          'Progress monitoring',
        ],
      ),
      ServiceItem(
        'Online Diet Consultation',
        'Get professional nutrition guidance and diet planning from anywhere online.',
        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400',
        highlights: [
          'Virtual diet consultation',
          'Flexible online sessions',
          'Personalized nutrition advice',
          'Convenient follow-up support',
        ],
        includes: [
          'Online assessment session',
          'Customized meal plan',
          'Progress review',
          'Nutrition guidance',
        ],
      ),
      ServiceItem(
        'PCOS Diet',
        'Specialized nutrition plans to support hormone balance and manage PCOS symptoms.',
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        highlights: [
          'Hormone-friendly meals',
          'Weight management support',
          'Improved energy levels',
          'Healthy lifestyle planning',
        ],
        includes: [
          'PCOS nutrition assessment',
          'Customized diet chart',
          'Lifestyle recommendations',
          'Progress tracking',
        ],
      ),
      ServiceItem(
        'Sports Nutrition',
        'Performance-focused nutrition plans for athletes and active individuals.',
        'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        highlights: [
          'Energy boosting meal plans',
          'Workout recovery support',
          'Performance nutrition',
          'Hydration guidance',
        ],
        includes: [
          'Fitness nutrition assessment',
          'Customized sports diet plan',
          'Recovery meal guidance',
          'Performance tracking',
        ],
      ),
      ServiceItem(
        'Weight Loss Diet',
        'Healthy and sustainable meal plans designed for effective weight loss.',
        'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400',
        highlights: [
          'Calorie-controlled meals',
          'Healthy fat loss support',
          'Balanced nutrition',
          'Sustainable eating habits',
        ],
        includes: [
          'Weight assessment',
          'Personalized meal plan',
          'Progress monitoring',
          'Lifestyle guidance',
        ],
      ),
    ],
  ),
];

// ── ServiceScreen ─────────────────────────────────────────────────────────────
class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});
  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  int _navIndex = 0;
  int _selectedChip = 0;
  bool _isLoading = ApiService.cachedServices == null;
  List<ServiceCategory> _liveCategories = [];
  String _heroImageUrl = ApiService.cachedServicesHeroImage ?? '';
  final ScrollController _mainScrollController = ScrollController();
  final List<GlobalKey> _categoryKeys =
      List.generate(6, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    if (ApiService.cachedServices != null) {
      _liveCategories = _parseServicesSync(ApiService.cachedServices!);
      _isLoading = false;
    }
    _fetchServices();
  }

  List<ServiceCategory> _parseServicesSync(List<dynamic> dbServices) {
    // Create empty categories based on the original templates
    List<ServiceCategory> dynamicCategories = categories.map((c) => ServiceCategory(
      name: c.name,
      subtitle: c.subtitle,
      icon: c.icon,
      iconColor: c.iconColor,
      iconBg: c.iconBg,
      accentDark: c.accentDark,
      items: List<ServiceItem>.from([]), // Make it modifiable
    )).toList();

    // Fill them with live MongoDB data
    for (var s in dbServices) {
      final categoryName = s['category'] ?? 'Other';
      if (categoryName == 'CategoryBanner') {
        continue;
      }
      final item = ServiceItem(
        s['title'] ?? 'Unknown',
        s['description'] ?? '',
        s['imageUrl'] ?? '',
        id: s['_id'] ?? '',
        price: (s['price'] ?? 0).toDouble(),
        durationMinutes: s['durationMinutes'] ?? 60,
      );

      try {
        var cat = dynamicCategories.firstWhere((c) {
          final cName = c.name.toLowerCase();
          final sCat = categoryName.toLowerCase();
          return cName == sCat || 
                 (cName == 'physiotherapy' && sCat == 'physio') ||
                 (cName == 'physio' && sCat == 'physiotherapy');
        });
        cat.items.add(item);
      } catch (e) {
        dynamicCategories.first.items.add(item);
      }
    }
    return dynamicCategories;
  }

  void _fetchServices() async {
    try {
      final results = await Future.wait([
        ApiService.getServicesHeroImage().catchError((_) => ''),
        ApiService.getServices().catchError((_) => []),
      ]);

      final liveHeroUrl = results[0] as String;
      final dbServices = results[1] as List<dynamic>;

      ApiService.cachedServices = dbServices;
      ApiService.cachedServicesHeroImage = liveHeroUrl;

      final parsed = _parseServicesSync(dbServices);

      if (mounted) {
        setState(() {
          _liveCategories = parsed;
          _heroImageUrl = liveHeroUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load services: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToCategory(int index) {
    setState(() => _selectedChip = index);
    final ctx = _categoryKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: RefreshIndicator(
        color: const Color(0xFFFFD700), // kYellow color value (gold/yellow)
        backgroundColor: const Color(0xFF1C1C1E), // Dark card/accent bg
        onRefresh: () async {
          _fetchServices();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _mainScrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(),
              _buildCategoryChips(),
              const SizedBox(height: 12),
              _buildCategoryList(),
              _buildCTABanner(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _heroImageUrl.isNotEmpty
              ? Image.network(
                  ApiService.getMediaUrl(_heroImageUrl, width: 800),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/fitness.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: kBlack,
                      child: const Icon(Icons.fitness_center, color: kYellow, size: 80),
                    ),
                  ),
                )
              : Image.asset(
                  'assets/images/fitness.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: kBlack,
                    child: const Icon(Icons.fitness_center, color: kYellow, size: 80),
                  ),
                ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x00000000),
                  Color(0xEE1A1A1A),
                ],
                stops: [0.0, 0.3, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          const Positioned(
            bottom: 22,
            left: 20,
            right: 20,
            child: Text(
              'Transform Your\nBody & Mind',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    final chips = [
      'Fitness',
      'Physio',
      'Sports',
      'Yoga',
      'Therapy',
      'Nutrition',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(chips.length, (i) {
            final isSelected = _selectedChip == i;
            return GestureDetector(
              onTap: () => _scrollToCategory(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? kYellowNav : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: kYellowNav.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ]
                      : [],
                ),
                child: Text(
                  chips[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? kBlack : kGreyText,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Category list ──────────────────────────────────────────────────────────
  Widget _buildCategoryList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: kYellowNav),
        ),
      );
    }
    return Column(
      children: List.generate(_liveCategories.length, (i) {
        return Container(
          key: _categoryKeys[i],
          child: _buildCategorySection(_liveCategories[i]),
        );
      }),
    );
  }

  Widget _buildCategorySection(ServiceCategory cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: kYellowNav,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: kYellowNav.withOpacity(0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Icon(cat.icon, color: kBlack, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            cat.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: kBlack,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: kYellowNav.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${cat.items.length} services',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: kYellowNav,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  kYellowNav,
                  kYellowNav.withOpacity(0.15),
                  Colors.transparent
                ],
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cat.items.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(
                    right: i < cat.items.length - 1 ? 12 : 0),
                child: SizedBox(
                  width: 152,
                  child: _buildServiceCard(cat.items[i], cat),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  // ── Service card ───────────────────────────────────────────────────────────
  Widget _buildServiceCard(ServiceItem item, ServiceCategory cat) {
    return GestureDetector(
      onTap: () => _showServiceDetailSheet(
        context,
        item: item,
        accentColor: cat.iconColor,
        accentBg: cat.iconBg,
        accentDark: cat.accentDark,
        categoryName: cat.name,
        categoryIcon: cat.icon,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 108,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.imageUrl.isNotEmpty
                        ? Image.network(
                            ApiService.getMediaUrl(item.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFFFF8E1),
                              child: Icon(cat.icon,
                                  color: kYellowNav, size: 40),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFFFF8E1),
                            child:
                                Icon(cat.icon, color: kYellowNav, size: 40),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.35)
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: kYellowNav,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: kYellowNav.withOpacity(0.5),
                                blurRadius: 8)
                          ],
                        ),
                        child: Icon(cat.icon, size: 10, color: kBlack),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: kBlack,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF999999),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: kYellowNav,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: kYellowNav.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Learn More',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: kBlack,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 11, color: kBlack),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CTA banner ─────────────────────────────────────────────────────────────
  Widget _buildCTABanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: kBlack,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600'),
          fit: BoxFit.cover,
          opacity: 0.18,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: const BoxDecoration(
                color: kYellow,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 16, 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: kYellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('START TODAY',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: kBlack,
                                letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ready to Start Your\nWellness Journey?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Expert coaches. Proven methods. Real results.',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: kYellow.withOpacity(0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.bolt_rounded, color: kBlack, size: 24),
                      SizedBox(height: 5),
                      Text('Book\nNow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: kBlack,
                              height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final items = [
      {
        'icon': Icons.design_services_outlined,
        'label': 'Services',
        'onTap': () =>
            Navigator.push(context, _route(const ServiceScreen())),
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Events',
        'onTap': () =>
            Navigator.push(context, _route(const EventsScreen())),
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'Shop',
        'onTap': () =>
            Navigator.push(context, _route(const Shop1Screen())),
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'onTap': () =>
            Navigator.push(context, _route(ProfilePage())),
      },
    ];

    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: kWhite,
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.12),
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 62 + bottomSafe,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomSafe),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (slot) {
              // slot 2 is the FAB notch gap
              if (slot == 2) return const SizedBox(width: 64);
              final idx = slot < 2 ? slot : slot - 1;
              final isActive = _navIndex == idx;
              final item = items[idx];
              return GestureDetector(
                onTap: () {
                  setState(() => _navIndex = idx);
                  (item['onTap'] as VoidCallback)();
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 65,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? kPrimary.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item['icon'] as IconData,
                            size: 22,
                            color: isActive ? kPrimary : kSubText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isActive ? kPrimaryDeep : kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────
  Widget _buildFab() => GestureDetector(
        onTap: () =>
            Navigator.push(context, _route(const Home2Screen())),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: kPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: kPrimary.withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Icon(Icons.home_rounded, color: kDarkText, size: 28),
        ),
      );
}

// ── Stat pill (kept for potential use) ───────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String sub;
  const _StatPill(this.label, this.sub);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kYellow)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Service detail sheet ──────────────────────────────────────────────────────
void _showServiceDetailSheet(
  BuildContext context, {
  required ServiceItem item,
  required Color accentColor,
  required Color accentBg,
  required Color accentDark,
  required String categoryName,
  required IconData categoryIcon,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => _ServiceDetailSheet(
      item: item,
      accentColor: accentColor,
      accentBg: accentBg,
      accentDark: accentDark,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
    ),
  );
}

class _ServiceDetailSheet extends StatelessWidget {
  final ServiceItem item;
  final Color accentColor;
  final Color accentBg;
  final Color accentDark;
  final String categoryName;
  final IconData categoryIcon;

  const _ServiceDetailSheet({
    required this.item,
    required this.accentColor,
    required this.accentBg,
    required this.accentDark,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        height: screenHeight * 0.92,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 2),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image header ─────────────────────────────────────
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                          child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: item.imageUrl.isNotEmpty
                                ? Image.network(
                                    ApiService.getMediaUrl(item.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: accentBg,
                                      child: Icon(categoryIcon,
                                          color: accentColor, size: 60),
                                    ),
                                  )
                                : Container(
                                    color: accentBg,
                                    child: Icon(categoryIcon,
                                        color: accentColor, size: 60),
                                  ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28)),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x22000000),
                                    Color(0x00000000),
                                    Color(0xCC000000),
                                  ],
                                  stops: [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                                color: kYellowNav,
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(categoryIcon,
                                    size: 11, color: kBlack),
                                const SizedBox(width: 5),
                                Text(
                                  categoryName.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: kBlack,
                                      letterSpacing: 1.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 18,
                          left: 16,
                          right: 16,
                          child: Text(
                            item.title,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                height: 1.2),
                          ),
                        ),
                      ],
                    ),

                    // ── Description ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                      child: Text(
                        item.description,
                        style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A4A4A),
                            height: 1.65),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Info pills ───────────────────────────────────────
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18),
                      child: Wrap(spacing: 8, runSpacing: 8, children: [
                        _InfoPill(
                            icon: Icons.verified_rounded,
                            label: 'Certified Experts',
                            color: kYellowNav),
                        _InfoPill(
                            icon: Icons.calendar_month_rounded,
                            label: 'Flexible Scheduling',
                            color: kYellowNav),
                        _InfoPill(
                            icon: Icons.trending_up_rounded,
                            label: 'Track Progress',
                            color: kYellowNav),
                      ]),
                    ),

                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 20),
                        height: 1,
                        color: const Color(0xFFF0F0F0)),

                    // ── Highlights ───────────────────────────────────────
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                  color: kYellow,
                                  borderRadius:
                                      BorderRadius.circular(8)),
                              child: const Icon(Icons.star_rounded,
                                  size: 16, color: kBlack),
                            ),
                            const SizedBox(width: 10),
                            const Text('HIGHLIGHTS',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: kBlack,
                                    letterSpacing: 1.3)),
                          ]),
                          const SizedBox(height: 14),
                          ...item.highlights.map((h) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 2),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: kYellowNav
                                              .withOpacity(0.15),
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                          Icons.check_rounded,
                                          size: 12,
                                          color: kYellowNav),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Text(h,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color:
                                                    Color(0xFF333333),
                                                height: 1.45))),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── What's included ──────────────────────────────────
                    Container(
                      margin: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: kYellowNav.withOpacity(0.3),
                            width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 14, color: kYellowNav),
                            const SizedBox(width: 7),
                            const Text("WHAT'S INCLUDED",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: kBlack,
                                    letterSpacing: 1.2)),
                          ]),
                          const SizedBox(height: 14),
                          ...item.includes.map((inc) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                        Icons.arrow_right_alt_rounded,
                                        size: 18,
                                        color: kYellowNav),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(inc,
                                            style: const TextStyle(
                                                fontSize: 12.5,
                                                color:
                                                    Color(0xFF333333),
                                                height: 1.45))),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar ──────────────────────────────────────
            Container(
              padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -6))
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFE8E8E8)),
                      ),
                      child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 17,
                          color: kBlack),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => YogaServiceScreen(
                              preSelectedServiceName: item.title,
                              categoryName: categoryName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: kYellow,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: kYellow.withOpacity(0.5),
                                blurRadius: 14,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded,
                                size: 22, color: kBlack),
                            SizedBox(width: 8),
                            Text('Book a Session',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: kBlack,
                                    letterSpacing: 0.3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info pill ─────────────────────────────────────────────────────────────────
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: kYellowNav.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kYellowNav.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: kYellowNav),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kBlack)),
        ],
      ),
    );
  }
}