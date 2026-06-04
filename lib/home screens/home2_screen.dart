import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:mrcoach/events/events_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mrcoach/home%20screens/fitness_screen.dart' hide kYellow, kDark;
import 'package:mrcoach/home%20screens/services_page.dart' hide kBlack, kYellow;
import 'package:mrcoach/home%20screens/med_screen.dart' hide kYellow, kDark, kGreen;
import 'package:mrcoach/online_screen.dart';
import 'package:mrcoach/physio_select_screen.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:mrcoach/profile_settings_pages/profile_screen.dart';
import 'package:mrcoach/home%20screens/sports_screen.dart' hide kDark, kYellow, kGreen;
import 'package:mrcoach/webview_screen.dart';
import 'package:mrcoach/home%20screens/yoga_screen.dart';
import 'package:mrcoach/home%20screens/notifications_inbox_page.dart';
import 'package:mrcoach/my_bookings_page.dart';
import 'package:mrcoach/services/location_service.dart';

Future<void> _launchEventsUrl() async {
  final Uri url = Uri.parse('https://www.mrcoach.in/events');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

const Color kPrimary      =Color(0xFFF5C518); 
const Color kPrimaryDeep  = Color(0xFFF5C518); 
const Color kDark         = Color(0xFF111118); 
const Color kDarkText     = Color(0xFF1A1A2E); 
const Color kBgPage       = Color(0xFFF5F6FA); 
const Color kCardBg       = Color(0xFFFFFFFF);
const Color kSubText      = Color(0xFF7B8194);
const Color kBorderLine   = Color(0xFFEAEBF0);
const Color kWhite        = Color(0xFFFFFFFF);
const Color kGreenBadge   = Color(0xFF22C55E);
const Color kSliderDark   = Color(0xFF111118);

const Color kOrange       = Color(0xFFFF6B35);
const Color kBlackNav     = Color(0xFF1A1A2E);
const Color kGreen        = Color(0xFF22C55E);
const Color kGreyText     = Color(0xFF7B8194);
const Color kYellowNav    = Color(0xFFFFEF00);

const Color kIconBgYellow = Color(0xFFFFF8DC);
const Color kIconBgGreen  = Color(0xFFDCF5E7);
const Color kIconBgBlue   = Color(0xFFDCEEFF);
const Color kIconBgPurple = Color(0xFFF3E8FF);
const Color kIconBgRed    = Color(0xFFFFE4E6);
const Color kIconBgOrange = Color(0xFFFFEEDC);

TextStyle _syne(double size, FontWeight w, Color color, {double? letterSpacing, double? height}) =>
    TextStyle(fontSize: size, fontWeight: w, color: color,
        letterSpacing: letterSpacing, height: height);

TextStyle _dm(double size, FontWeight w, Color color, {double? letterSpacing}) =>
    TextStyle(fontSize: size, fontWeight: w, color: color,
        letterSpacing: letterSpacing);

class SliderItem {
  final String line1, line2, line3, sub, ctaLabel;
  final String? imagePath;
  final IconData icon;
  final Widget Function(BuildContext)? dest;
  const SliderItem({
    required this.line1, required this.line2, this.line3 = '',
    required this.sub, required this.ctaLabel,
    this.imagePath, required this.icon, this.dest,
  });
}

class ServiceTile {
  final IconData icon;
   final Color iconBg;
final Color iconColor;
  final String title, subtitle;
  final String? imagePath;
  String? networkImageUrl; // Added for dynamic images from Admin Dashboard
  final VoidCallback onTap;
  ServiceTile({
    required this.icon,
    required this.iconBg, 
    required this.iconColor,
    required this.title, required this.subtitle,
    this.imagePath, this.networkImageUrl, required this.onTap,
  });
}

class SavedAddress {
  final String label, address;
  final IconData icon;
  const SavedAddress({required this.label, required this.address, required this.icon});
}

class EventItem {
  final String? imagePath;
  final String title, date, time, location;
  final bool isActive;
  final Widget detailPage;
  const EventItem({
    this.imagePath, required this.title, required this.date,
    required this.time, required this.location,
    this.isActive = true, required this.detailPage,
  });
}

class ShopItem {
  final String? imagePath;
  final String title, date, time, location;
  final bool isActive;
  final Widget detailPage;
  const ShopItem({
    this.imagePath, required this.title, required this.date,
    required this.time, required this.location,
    this.isActive = true, required this.detailPage,
  });
}

class Home2Screen extends StatefulWidget {
  const Home2Screen({super.key});
  @override
  State<Home2Screen> createState() => _Home2ScreenState();
}

class _Home2ScreenState extends State<Home2Screen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _navIndex = -1;
  int _currentSlide = 0;
  late PageController _sliderCtrl;
  late Timer _sliderTimer;
  int _currentEvent = 0;
  late PageController _eventCtrl;
  late Timer _eventTimer;
  int _currentShop = 0;
  late PageController _shopCtrl;
  late Timer _shopTimer;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  String _selLabel   = 'Select Your Location';
  String _selAddress = '';
  bool _loadingLocation = false;

  Future<void> _initLocation() async {
    // 1. Try to load cached location first
    final cached = await LocationService.getCachedLocation();
    if (cached != null) {
      if (mounted) {
        setState(() {
          _selLabel = cached.formattedAddress;
          _selAddress = cached.area.isNotEmpty
              ? '${cached.area}, ${cached.district}, ${cached.state} - ${cached.pincode}'
              : cached.formattedAddress;
        });
      }
      // Sync it with backend silently if user is logged in
      final token = await ApiService.getToken();
      if (token != null) {
        LocationService.syncLocationWithBackend(cached);
      }
      return;
    }

    // 2. No cached location: automatically detect live location
    await _detectLiveLocation(silent: true);
  }

  Future<void> _detectLiveLocation({bool silent = false}) async {
    if (!silent) {
      setState(() => _loadingLocation = true);
    }
    
    // Request permission
    final hasPermission = await LocationService.requestPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _selLabel = 'Select Your Location';
        });
      }
      return;
    }

    // Fetch GPS coordinates
    final position = await LocationService.getCurrentPosition();
    if (position == null) {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _selLabel = 'Location unavailable';
        });
      }
      return;
    }

    // Reverse geocode
    final details = await LocationService.reverseGeocode(position.latitude, position.longitude);
    if (details != null) {
      if (mounted) {
        setState(() {
          _selLabel = details.formattedAddress;
          _selAddress = details.area.isNotEmpty 
              ? '${details.area}, ${details.district}, ${details.state} - ${details.pincode}'
              : details.formattedAddress;
          _loadingLocation = false;
        });
      }
      // Cache locally
      await LocationService.cacheLocation(details);
      
      // Sync with backend
      final token = await ApiService.getToken();
      if (token != null) {
        await LocationService.syncLocationWithBackend(details);
      }
    } else {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _selLabel = 'Location unavailable';
        });
      }
    }
  }

  final List<SavedAddress> _addresses = const [
    SavedAddress(label: 'Home', address: '28, 2nd Block, Mogappair West, Chennai - 600037', icon: Icons.home_rounded),
    SavedAddress(label: 'Work', address: '14, Anna Nagar East, Chennai - 600102',            icon: Icons.work_rounded),
    SavedAddress(label: 'Gym',  address: '5, Ambattur Industrial Estate, Chennai - 600058',  icon: Icons.fitness_center_rounded),
  ];

  List<SliderItem> get _slides => [
    SliderItem(line1: 'STRONGER', line2: 'EVERY DAY', line3: 'BETTER YOU', sub: 'Expert trainers at home', ctaLabel: 'BOOK NOW', imagePath: 'assets/images/slider1.jpeg', icon: Icons.fitness_center, dest: (_) => const FitnessScreen()),
    SliderItem(line1: 'HEAL &',   line2: 'RECOVER',   sub: 'Expert physio at home',      ctaLabel: 'BOOK NOW', imagePath: 'assets/images/slider1.jpeg', icon: Icons.monitor_heart,    dest: (_) => PhysioScreen()),
    SliderItem(line1: 'PLAY &',   line2: 'PERFORM',   sub: 'Train like a champion',      ctaLabel: 'BOOK NOW', imagePath: 'assets/images/slider1.jpeg', icon: Icons.sports_soccer,    dest: (_) => SportsScreen()),
    SliderItem(line1: 'MIND &',   line2: 'BODY',      sub: 'Find your inner balance',    ctaLabel: 'BOOK NOW', imagePath: 'assets/images/slider1.jpeg', icon: Icons.self_improvement, dest: (_) => YogaBooking1Screen()),
    SliderItem(line1: 'REFER &',  line2: 'EARN',      sub: 'Get ₹100 for every friend', ctaLabel: 'INVITE NOW', imagePath: 'assets/images/slider1.jpeg', icon: Icons.card_giftcard_rounded, dest: (_) => ReferralPage()),
  ];

  Map<String, String> _dynamicImageMap = {};
  Map<String, String> _dynamicInnerBannerMap = {};

  List<ServiceTile> _tiles(BuildContext ctx) => [
    ServiceTile(icon: Icons.fitness_center,          
     iconBg: kIconBgYellow,iconColor: const Color.fromARGB(255, 0, 0, 0), title: 'Fitness',       subtitle: 'Train & Build',   imagePath: 'assets/images/slider.jpeg', networkImageUrl: _dynamicImageMap['Fitness'],      onTap: () => Navigator.push(ctx, _route(FitnessScreen(categoryImageUrl: _dynamicInnerBannerMap['Fitness'])))),
    ServiceTile(icon: Icons.monitor_heart,            
    iconBg: kIconBgGreen,  iconColor: const Color.fromARGB(255, 0, 0, 0), title: 'Physio',        subtitle: 'Heal & Recover',  imagePath: 'assets/images/phy2.jpeg', networkImageUrl: _dynamicImageMap['Physio'],        onTap: () => Navigator.push(ctx, _route(PhysioScreen(categoryImageUrl: _dynamicInnerBannerMap['Physio'])))),
    ServiceTile(icon: Icons.sports_soccer,          
    iconBg: kIconBgBlue,   iconColor: const Color.fromARGB(255, 0, 0, 0),  title: 'Sports',        subtitle: 'Play & Perform',  imagePath: 'assets/images/spt2.jpeg', networkImageUrl: _dynamicImageMap['Sports'],        onTap: () => Navigator.push(ctx, _route(SportsScreen(categoryImageUrl: _dynamicInnerBannerMap['Sports'])))),
    ServiceTile(icon: Icons.self_improvement_outlined,
    iconBg: kIconBgPurple,iconColor:  const Color.fromARGB(255, 0, 0, 0),title: 'Yoga',          subtitle: 'Mind & Body',     imagePath: 'assets/images/yoga.jpeg', networkImageUrl: _dynamicImageMap['Yoga'],        onTap: () => Navigator.push(ctx, _route(YogaBooking1Screen(categoryImageUrl: _dynamicInnerBannerMap['Yoga'])))),
    ServiceTile(icon: Icons.monitor,                  
     iconBg: kIconBgRed,    iconColor:  const Color.fromARGB(255, 0, 0, 0), title: 'Therapy',       subtitle: 'Care & Support',  imagePath: 'assets/images/online1.jpeg', networkImageUrl: _dynamicImageMap['Therapy'],     onTap: () => Navigator.push(ctx, _route(TherapyScreen(categoryImageUrl: _dynamicInnerBannerMap['Therapy'])))),
    ServiceTile(icon: Icons.restaurant,              
      iconBg: kIconBgOrange, iconColor: const Color.fromARGB(255, 0, 0, 0), title: 'Nutrition',     subtitle: 'Eat & Live Well', imagePath: 'assets/images/yellowtheme.jpeg', networkImageUrl: _dynamicImageMap['Nutrition'], onTap: () => Navigator.push(ctx, _route(DietBooking1Screen(categoryImageUrl: _dynamicInnerBannerMap['Nutrition'])))),
  ];

  List<EventItem> get _events => [
    EventItem(imagePath: 'assets/images/bessy.jpeg',        title: 'NAMMA BESSY MILE RUN 2026',          date: '09 Aug 2026', time: '06:00 AM', location: 'Olcott Memorial School, Chennai',   isActive: true,  detailPage: const EventWebViewScreen(title: 'NAMMA BESSY MILE RUN 2026', url: 'https://mrcoach.in/events/15')),
    EventItem(imagePath: 'assets/images/kidathon.jpeg',     title: 'CHENNAI KIDATHON 2026',              date: '02 Aug 2026', time: '05:30 AM', location: 'Nehru Park, Chennai',               isActive: true,  detailPage: const EventWebViewScreen(title: 'CHENNAI KIDATHON 2026', url: 'https://mrcoach.in/events/14')),
    EventItem(imagePath: 'assets/images/junior.jpeg',       title: 'KIDS & JUNIOR ATHLETICS MEET 2026', date: '04 Jul 2026', time: '07:00 AM', location: 'Jawaharlal Nehru Stadium, Chennai', isActive: false, detailPage: const EventWebViewScreen(title: 'KIDS & JUNIOR ATHLETICS MEET 2026', url: 'https://mrcoach.in/events/13')),
    EventItem(imagePath: 'assets/images/chennaievent.jpeg', title: 'CHENNAI RISE UP RUN MARATHON',      date: '24 May 2026', time: '08:00 AM', location: 'Decathlon - Mogappair, Chennai',    isActive: true,  detailPage: const EventWebViewScreen(title: 'CHENNAI RISE UP RUN MARATHON', url: 'https://mrcoach.in/events/12')),
  ];

  List<ShopItem> get _shopItems => [
    ShopItem(imagePath: 'assets/images/yogamat.jpeg',     title: 'PREMIUM YOGA MAT',        date: 'In Stock', time: 'Free Delivery', location: 'Ships from Chennai', detailPage: Shop1Screen()),
    ShopItem(imagePath: 'assets/images/herbal.jpeg',      title: 'HERBAL PROTEIN POWDER',   date: 'Limited',  time: 'Same Day',      location: 'Ships from Chennai', detailPage: Shop1Screen()),
    ShopItem(imagePath: 'assets/images/supplements.jpeg', title: 'PROTEIN SUPPLEMENT PACK', date: 'In Stock', time: 'Next Day',       location: 'Ships from Chennai', detailPage: Shop1Screen()),
    ShopItem(imagePath: 'assets/images/epq.jpg',          title: 'GYM EQUIPMENT PACK',      date: 'In Stock', time: 'Next Day',       location: 'Ships from Chennai', detailPage: Shop1Screen()),
  ];

  List<dynamic> _dynamicBanners = [];
  bool _loadingBanners = true;

  int _unreadCount = 0;
  Timer? _notifTimer;

  MaterialPageRoute _route(Widget w) => MaterialPageRoute(builder: (_) => w);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _sliderCtrl = PageController();
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_sliderCtrl.hasClients) {
        final count = _dynamicBanners.isNotEmpty ? _dynamicBanners.length : _slides.length;
        if (count > 0) {
          _sliderCtrl.animateToPage((_currentSlide + 1) % count,
              duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        }
      }
    });
    _fetchDynamicBanners();
    _eventCtrl = PageController();
    _eventTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_eventCtrl.hasClients && _events.isNotEmpty) {
        _eventCtrl.animateToPage((_currentEvent + 1) % _events.length,
            duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
    _shopCtrl = PageController();
    _shopTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_shopCtrl.hasClients && _shopItems.isNotEmpty) {
        _shopCtrl.animateToPage((_currentShop + 1) % _shopItems.length,
            duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });

    _fetchDynamicImages();

    _fetchUnreadCount();
    _notifTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _unreadCount = 0; // reset/refetch
      _fetchUnreadCount();
    });
    _initLocation();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final notifs = await ApiService.getUserNotifications();
      int count = 0;
      for (var n in notifs) {
        if (n['status'] == 'unread') {
          count++;
        }
      }
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch unread notifications count: $e');
    }
  }

  Future<void> _fetchDynamicImages() async {
    try {
      final services = await ApiService.getServices();
      final Map<String, String> tileMap = {};
      final Map<String, String> innerMap = {};
      
      for (var s in services) {
        if (s['title'] != null && s['imageUrl'] != null && s['imageUrl'].toString().isNotEmpty) {
          if (s['category'] == 'CategoryBanner') {
            tileMap[s['title']] = s['imageUrl'];
          } else if (s['category'] == 'CategoryInnerBanner') {
            innerMap[s['title']] = s['imageUrl'];
          }
        }
      }

      if (mounted) {
        setState(() {
          _dynamicImageMap = tileMap;
          _dynamicInnerBannerMap = innerMap;
        });
      }
    } catch (e) {
      debugPrint('Failed to load dynamic images: $e');
    }
  }

  Future<void> _fetchDynamicBanners() async {
    try {
      final banners = await ApiService.getActiveBanners();
      if (mounted) {
        setState(() {
          _dynamicBanners = banners;
          _loadingBanners = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load active banners: $e');
      if (mounted) {
        setState(() {
          _loadingBanners = false;
        });
      }
    }
  }

  void _handleBannerTap(BuildContext context, dynamic banner) {
    final String redUrl = (banner['redirectionUrl'] ?? '').toString().trim();
    final String title = banner['title'] ?? 'Mr Coach';

    if (redUrl.isNotEmpty) {
      final String lowerUrl = redUrl.toLowerCase();
      if (lowerUrl.contains('/events/')) {
        Navigator.push(context, _route(EventWebViewScreen(
          title: title.isNotEmpty ? title : 'Event Info',
          url: redUrl,
        )));
      } else if (lowerUrl.contains('/services/')) {
        String serviceTarget = '';
        try {
          final uri = Uri.parse(redUrl);
          final segments = uri.pathSegments;
          int sIdx = segments.indexOf('services');
          if (sIdx != -1 && sIdx + 1 < segments.length) {
            serviceTarget = segments[sIdx + 1].toLowerCase();
          } else if (segments.isNotEmpty) {
            serviceTarget = segments.last.toLowerCase();
          }
        } catch (e) {
          debugPrint('Error parsing service redirection URL: $e');
        }

        if (serviceTarget == 'fitness') {
          Navigator.push(context, _route(const FitnessScreen()));
        } else if (serviceTarget == 'physio') {
          Navigator.push(context, _route(const PhysioScreen()));
        } else if (serviceTarget == 'sports') {
          Navigator.push(context, _route(const SportsScreen()));
        } else if (serviceTarget == 'yoga') {
          Navigator.push(context, _route(const YogaBooking1Screen()));
        } else if (serviceTarget == 'therapy') {
          Navigator.push(context, _route(const TherapyScreen()));
        } else if (serviceTarget == 'nutrition' || serviceTarget == 'diet') {
          Navigator.push(context, _route(const DietBooking1Screen()));
        } else {
          Navigator.push(context, _route(const ServiceScreen()));
        }
      } else {
        // Website URL, Training URL, etc. -> Open inside App WebView
        Navigator.push(context, _route(EventWebViewScreen(
          title: title.isNotEmpty ? title : 'Info',
          url: redUrl,
          allowAnyDomain: true,
        )));
      }
      return;
    }

    final String type = banner['redirectType'] ?? 'none';
    final String target = banner['redirectId'] ?? '';

    if (type == 'service') {
      final String lowerTarget = target.toLowerCase();
      if (lowerTarget == 'fitness') {
        Navigator.push(context, _route(const FitnessScreen()));
      } else if (lowerTarget == 'physio') {
        Navigator.push(context, _route(const PhysioScreen()));
      } else if (lowerTarget == 'sports') {
        Navigator.push(context, _route(const SportsScreen()));
      } else if (lowerTarget == 'yoga') {
        Navigator.push(context, _route(const YogaBooking1Screen()));
      } else if (lowerTarget == 'therapy') {
        Navigator.push(context, _route(const TherapyScreen()));
      } else if (lowerTarget == 'nutrition') {
        Navigator.push(context, _route(const DietBooking1Screen()));
      } else {
        Navigator.push(context, _route(const ServiceScreen()));
      }
    } else if (type == 'event') {
      Navigator.push(context, _route(EventWebViewScreen(
        title: title.isNotEmpty ? title : 'Event Info',
        url: target.startsWith('http') ? target : 'https://mrcoach.in/events/$target',
      )));
    } else if (type == 'rewards') {
      Navigator.push(context, _route(ReferralPage()));
    } else if (type == 'booking') {
      Navigator.push(context, _route(const AllMyBookingsScreen()));
    } else if (type == 'product') {
      Navigator.push(context, _route(const Shop1Screen()));
    } else if (type == 'web') {
      if (target.isNotEmpty) {
        Navigator.push(context, _route(EventWebViewScreen(title: title.isNotEmpty ? title : 'Info', url: target)));
      }
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _sliderCtrl.dispose(); _sliderTimer.cancel();
    _eventCtrl.dispose();  _eventTimer.cancel();
    _shopCtrl.dispose();   _shopTimer.cancel();
    _notifTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double statusH    = mq.padding.top;
    final double bottomSafe = mq.padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: kBgPage,
        extendBody: false,
        //drawer: _buildDrawer(),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _TopBar(
                statusH: statusH,
                label: _selLabel,
                unreadCount: _unreadCount,
                isLoading: _loadingLocation,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                onLocationTap: _showLocSheet,
                onProfileTap: () => Navigator.push(context, _route(ProfilePage())),
                onNotificationTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsInboxPage()));
                  _fetchUnreadCount();
                },
              )),
              SliverToBoxAdapter(child: _buildSlider()),
              SliverToBoxAdapter(child: _buildServicesSection()),
              SliverToBoxAdapter(child: _SectionHeader(
                title: 'Top Trending Events',
                onSeeAll: () => Navigator.push(context, _route(const EventsScreen())),
              )),
              SliverToBoxAdapter(child: _buildEventsCarousel()),
              SliverToBoxAdapter(child: _SectionHeader(
                title: 'Top Trending Products',
                onSeeAll: () => Navigator.push(context, _route(const Shop1Screen())),
              )),
              SliverToBoxAdapter(child: _buildShopCarousel()),
              SliverToBoxAdapter(child: SizedBox(height: 80 + bottomSafe)),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(bottomSafe),
        floatingActionButton: _buildFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
       // bottomNavigationBar: _buildBottomNav(0),
      ),
    );
  }
  Widget _buildBadgeStrip() {
    final badges = [
      ('✦ BOOK NOW', true),
      ('FITNESS', false),
      ('PHYSIO', false),
      ('SPORTS', false),
      ('YOGA', false),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isAccent = badges[i].$2;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isAccent ? Color(0xFFF5C518) : kDarkText,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badges[i].$1,
              style: _syne(9, FontWeight.w800,
                isAccent ? kDarkText : kPrimary,
                letterSpacing: 0.8)),
          );
        },
      ),
    );
  }
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: kWhite,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                color: kDarkText,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: kPrimary, shape: BoxShape.circle,
                      border: Border.all(color: kPrimary, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, color: kDarkText, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text('Welcome!\nJohn Doe',
                    style: _syne(20, FontWeight.w800, kWhite)),
                  const SizedBox(height: 4),
                  Container(width: 32, height: 3,
                    decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 6),
                  Text(_selLabel,
                    style: _dm(12, FontWeight.w500, Colors.white54),
                    overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  _DrawerItem(icon: Icons.home_rounded,             label: 'Home',             onTap: () { Navigator.pop(context); }),
                  _DrawerItem(icon: Icons.design_services_outlined,  label: 'Services',         onTap: () { Navigator.pop(context); Navigator.push(context, _route(ServiceScreen())); }),
                  _DrawerItem(icon: Icons.calendar_today_outlined,   label: 'Events',           onTap: () { Navigator.pop(context); Navigator.push(context, _route(const EventsScreen())); }),
                  _DrawerItem(icon: Icons.shopping_bag_outlined,     label: 'Shop',             onTap: () { Navigator.pop(context); Navigator.push(context, _route(const Shop1Screen())); }),
                  _DrawerItem(icon: Icons.fitness_center,            label: 'Fitness',          onTap: () { Navigator.pop(context); Navigator.push(context, _route(const FitnessScreen())); }),
                  _DrawerItem(icon: Icons.monitor_heart,             label: 'Physiotherapy',    onTap: () { Navigator.pop(context); Navigator.push(context, _route(const PhysioScreen())); }),
                  _DrawerItem(icon: Icons.sports_soccer,             label: 'Sports',           onTap: () { Navigator.pop(context); Navigator.push(context, _route(SportsScreen())); }),
                  _DrawerItem(icon: Icons.self_improvement_outlined, label: 'Yoga',             onTap: () { Navigator.pop(context); Navigator.push(context, _route(YogaBooking1Screen())); }),
                  _DrawerItem(icon: Icons.person_outline_rounded,    label: 'Profile',          onTap: () { Navigator.pop(context); Navigator.push(context, _route(ProfilePage())); }),
                  const Divider(height: 20, color: kBorderLine),
                  _DrawerItem(icon: Icons.card_giftcard_rounded,     label: 'Refer & Earn',     onTap: () { Navigator.pop(context); Navigator.push(context, _route(ReferralPage())); }),
                  _DrawerItem(icon: Icons.location_on_rounded,       label: 'Change Location',  onTap: () { Navigator.pop(context); _showLocSheet(); }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: kBorderLine)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: kSubText),
                const SizedBox(width: 6),
                Text('MrCoach v1.0.0',
                  style: _dm(11, FontWeight.w500, kSubText)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSlider() {
    final hasDynamic = _dynamicBanners.isNotEmpty;
    final count = hasDynamic ? _dynamicBanners.length : _slides.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 220,
          child: Stack(children: [
            PageView.builder(
              controller: _sliderCtrl,
              itemCount: count,
              onPageChanged: (i) => setState(() => _currentSlide = i),
              itemBuilder: (ctx, i) {
                if (hasDynamic) {
                  final b = _dynamicBanners[i];
                  return _DynamicSlideCard(
                    banner: b,
                    onTap: () => _handleBannerTap(ctx, b),
                  );
                } else {
                  return _SlideCard(
                    slide: _slides[i],
                    onTap: _slides[i].dest != null
                        ? () => Navigator.push(ctx, _route(_slides[i].dest!(ctx)))
                        : null,
                  );
                }
              },
            ),
            Positioned(
              bottom: 14, right: 16,
              child: Row(
                children: List.generate(count, (i) {
                  final active = _currentSlide == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 5),
                    width: active ? 20 : 6, height: 6,
                    decoration: BoxDecoration(
                      color: active ? kPrimary : Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ]),
        ),
      ),
    );
  }
  Widget _buildServicesSection() {
    return LayoutBuilder(builder: (ctx, box) {
      final tiles = _tiles(ctx);
      const double hPad = 16;
      const double gap  = 10;
      final double cardW = (box.maxWidth - hPad * 2 - gap * 2) / 3;
      final double imgH  = cardW;
      const double labelH = 44.0; 

      Widget card(ServiceTile t) => _ServiceTileCard(
        tile: t, cardWidth: cardW, imageHeight: imgH, labelHeight: labelH,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Explore Our Services',
                style: _syne(16, FontWeight.w800, kDarkText)),
              GestureDetector(
                onTap: () => Navigator.push(ctx, _route(ServiceScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('View All >',
                    style: _syne(10, FontWeight.w800, kPrimary)),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: hPad),
            child: Row(children: [
              card(tiles[0]), const SizedBox(width: gap),
              card(tiles[1]), const SizedBox(width: gap),
              card(tiles[2]),
            ]),
          ),
          const SizedBox(height: gap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: hPad),
            child: Row(children: [
              card(tiles[3]), const SizedBox(width: gap),
              card(tiles[4]), const SizedBox(width: gap),
              card(tiles[5]),
            ]),
          ),
        ],
      );
    });
  }
  Widget _buildEventsCarousel() {
    return Column(children: [
      SizedBox(
        height: 152,
        child: PageView.builder(
          controller: _eventCtrl,
          itemCount: _events.length,
          onPageChanged: (i) => setState(() => _currentEvent = i),
          itemBuilder: (ctx, i) {
            final ev = _events[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HorizontalCard(
                imagePath: ev.imagePath, title: ev.title,
                date: ev.date, time: ev.time, location: ev.location,
                isActive: ev.isActive,
                onTap: () => Navigator.push(ctx, _route(ev.detailPage)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      _Dots(current: _currentEvent, total: _events.length),
    ]);
  }
Widget _buildShopCarousel() {
    return Column(children: [
      SizedBox(
        height: 152,
        child: PageView.builder(
          controller: _shopCtrl,
          itemCount: _shopItems.length,
          onPageChanged: (i) => setState(() => _currentShop = i),
          itemBuilder: (ctx, i) {
            final it = _shopItems[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HorizontalCard(
                imagePath: it.imagePath, title: it.title,
                date: it.date, time: it.time, location: it.location,
                isActive: it.isActive,
                onTap: () => Navigator.push(ctx, _route(it.detailPage)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      _Dots(current: _currentShop, total: _shopItems.length),
    ]);
  }

  // Widget _buildBottomNav(double bottomSafe) {
  //   final items = [
  //     {'icon': Icons.design_services_outlined, 'label': 'Services', 'onTap': () => Navigator.push(context, _route(ServiceScreen()))},
  //     {'icon': Icons.calendar_today_outlined,   'label': 'Events',   'onTap': () => Navigator.push(context, _route(const EventsScreen()))},
  //     {'icon': Icons.shopping_bag_outlined,     'label': 'Shop',     'onTap': () => Navigator.push(context, _route(Shop1Screen()))},
  //     {'icon': Icons.person_outline_rounded,    'label': 'Profile',  'onTap': () => Navigator.push(context, _route(ProfilePage()))},
  //   ];
  //   return BottomAppBar(
  //     padding: EdgeInsets.zero,
  //     color: kWhite,
  //     elevation: 16,
  //     shadowColor: Colors.black.withOpacity(0.12),
  //     notchMargin: 8,
  //     shape: const CircularNotchedRectangle(),
  //     child: SizedBox(
  //       height: 62 + bottomSafe,
  //       child: Padding(
  //         padding: EdgeInsets.only(bottom: bottomSafe),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: List.generate(5, (slot) {
  //             if (slot == 2) return const SizedBox(width: 64);
  //             final idx = slot < 2 ? slot : slot - 1;
  //             final isActive = _navIndex == idx;
  //             final item = items[idx];
  //             return GestureDetector(
  //               onTap: () { setState(() => _navIndex = idx); (item['onTap'] as VoidCallback)(); },
  //               behavior: HitTestBehavior.opaque,
  //               child: SizedBox(
  //                 width: 65,
  //                 child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  //                   AnimatedContainer(
  //                     duration: const Duration(milliseconds: 200),
  //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: isActive ? kPrimary.withOpacity(0.15) : Colors.transparent,
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Icon(item['icon'] as IconData, size: 22,
  //                         color: isActive ? kPrimaryDeep : kSubText),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(item['label'] as String,
  //                     style: _dm(10, FontWeight.w700,
  //                         isActive ? kPrimaryDeep : kSubText)),
  //                 ]),
  //               ),
  //             );
  //           }),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildFab() => GestureDetector(
  //   onTap: () => Navigator.push(context, _route(const Home2Screen())),
  //   child: Container(
  //     width: 62, height: 62,
  //     decoration: BoxDecoration(
  //       color: kPrimary, shape: BoxShape.circle,
  //       boxShadow: [
  //         BoxShadow(color: kPrimary.withOpacity(0.55), blurRadius: 20, offset: const Offset(0, 4)),
  //         BoxShadow(color: kPrimary.withOpacity(0.2),  blurRadius: 40, offset: const Offset(0, 8)),
  //       ],
  //     ),
  //     child: const Icon(Icons.home_rounded, color: Color.fromARGB(255, 249, 249, 255), size: 28),
  //   ),
  // );
  Widget _buildBottomNav(double bottomSafe) {
    final items = [
      {'icon': Icons.design_services_outlined, 'label': 'Services', 'onTap': () => Navigator.push(context, _route(ServiceScreen()))},
      {'icon': Icons.calendar_today_outlined,   'label': 'Events',   'onTap': () => Navigator.push(context, _route(const EventsScreen()))},
      {'icon': Icons.shopping_bag_outlined,     'label': 'Shop',     'onTap': () => Navigator.push(context, _route(const Shop1Screen()))},
      {'icon': Icons.person_outline_rounded,    'label': 'Profile',  'onTap': () => Navigator.push(context, _route(ProfilePage()))},
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
              if (slot == 2) return const SizedBox(width: 64);
              final idx = slot < 2 ? slot : slot - 1;
              final isActive = _navIndex == idx;
              final item = items[idx];
              return GestureDetector(
                onTap: () { setState(() => _navIndex = idx); (item['onTap'] as VoidCallback)(); },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 65,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? kPrimary.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'] as IconData, size: 22,
                          color: isActive ? kPrimary : kSubText),
                    ),
                    const SizedBox(height: 2),
                    Text(item['label'] as String,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: isActive ? kPrimaryDeep : kSubText)),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() => GestureDetector(
    onTap: () => Navigator.push(context, _route(const Home2Screen())),
    child: Container(
      width: 62, height: 62,
      decoration: BoxDecoration(
        color: kPrimary, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.45), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: const Icon(Icons.home_rounded, color: kDarkText, size: 28),
    ),
  );


  void _showLocSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _LocationSheet(
        addresses: _addresses, selected: _selAddress,
        onSelect: (lbl, addr) {
          setState(() { _selLabel = lbl; _selAddress = addr; });
          Navigator.pop(context);
        },
      ),
    );
  }
}
class _TopBar extends StatelessWidget {
  final double statusH;
  final String label;
  final int unreadCount;
  final bool isLoading;
  final VoidCallback onMenuTap, onLocationTap, onProfileTap, onNotificationTap;
  const _TopBar({
    required this.statusH, required this.label, required this.unreadCount,
    required this.isLoading,
    required this.onMenuTap, required this.onLocationTap, required this.onProfileTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCardBg,
      padding: EdgeInsets.fromLTRB(16, statusH + 10, 16, 12),
      child: Row(children: [
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onLocationTap,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on_rounded, color: kPrimary, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: isLoading
                    ? Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: kDarkText.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const SizedBox.shrink(), // Placeholder for loading shimmer
                      )
                    : Text(label,
                        style: _dm(13, FontWeight.w700, kDarkText),
                        overflow: TextOverflow.ellipsis),
              ),
              if (!isLoading) ...[
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded, color: kDarkText, size: 18),
              ],
            ]),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: kCardBg, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorderLine),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: const Icon(Icons.notifications_outlined, size: 20, color: kDarkText),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD600), // Premium yellow theme highlight
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Color(0xFF111118),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: kBgPage, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: kDarkText),
      ),
      title: Text(label,
        style: _dm(14, FontWeight.w700, kDarkText)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kSubText),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
class _SlideCard extends StatelessWidget {
  final SliderItem slide;
  final VoidCallback? onTap;
  const _SlideCard({required this.slide, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: kSliderDark,
        child: Stack(fit: StackFit.expand, children: [
          if (slide.imagePath != null)
            Positioned(right: 0, top: 0, bottom: 0, width: 200,
              child: Image.asset(slide.imagePath!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())),
          Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: [kSliderDark, kSliderDark.withOpacity(0.88), Colors.transparent],
              stops: const [0.0, 0.48, 0.78],
            ),
          )))),
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, height: 80,
            child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.transparent]),
            )))),
          Positioned(left: 20, bottom: 36, top: 20,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(slide.line1, style: _syne(27, FontWeight.w800, Colors.white,
                    letterSpacing: -0.5, height: 1.05)),
                Text(slide.line2, style: _syne(27, FontWeight.w800, kPrimary,
                    letterSpacing: -0.5, height: 1.05)),
                if (slide.line3.isNotEmpty)
                  Text(slide.line3, style: _syne(15, FontWeight.w700, Colors.white, height: 1.2)),
                const SizedBox(height: 5),
                Text(slide.sub, style: _dm(11, FontWeight.w500, Colors.white.withOpacity(0.75))),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    decoration: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 4))],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(slide.ctaLabel, style: _syne(11, FontWeight.w800, kDarkText, letterSpacing: 0.5)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: kDarkText),
                    ]),
                  ),
                ),
              ],
            )),
        ]),
      ),
    );
  }
}

class _ServiceTileCard extends StatefulWidget {
  final ServiceTile tile;
  final double cardWidth, imageHeight, labelHeight;
  const _ServiceTileCard({
    required this.tile, required this.cardWidth,
    required this.imageHeight, required this.labelHeight,
  });
  @override
  State<_ServiceTileCard> createState() => _ServiceTileCardState();
}

class _ServiceTileCardState extends State<_ServiceTileCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double totalH = widget.imageHeight + widget.labelHeight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) { setState(() => _pressed = false); widget.tile.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: widget.cardWidth,
          height: totalH,
          child: Container(
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorderLine, width: 0.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: widget.cardWidth,
                    height: widget.imageHeight,
                    child: Stack(fit: StackFit.expand, children: [
                      Container(color: kSliderDark),
                      if (widget.tile.networkImageUrl != null && widget.tile.networkImageUrl!.isNotEmpty)
                        Image.network(
                          ApiService.getMediaUrl(widget.tile.networkImageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => widget.tile.imagePath != null
                              ? Image.asset(widget.tile.imagePath!, fit: BoxFit.cover)
                              : const SizedBox.shrink(),
                        )
                      else if (widget.tile.imagePath != null)
                        Image.asset(widget.tile.imagePath!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                      if (widget.tile.imagePath != null || widget.tile.networkImageUrl != null)
                        Container(color: kSliderDark.withOpacity(0.35)),
                    //  Center(child: Icon(widget.tile.icon, size: 36,
                    //      color: widget.tile.iconColor.withOpacity(0.25))),
                      Positioned(
                        top: 7, right: 7,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                           // color: widget.tile.iconColor.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.tile.icon, size: 14, color: widget.tile.iconColor),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: kCardBg,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.tile.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: _syne(10, FontWeight.w800, kDarkText)),
                            const SizedBox(height: 2),
                            Text(widget.tile.subtitle,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: _dm(8, FontWeight.w500, kSubText)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  final String? imagePath;
  final String title, date, time, location;
  final bool isActive;
  final VoidCallback? onTap;
  const _HorizontalCard({
    this.imagePath, required this.title, required this.date,
    required this.time, required this.location,
    this.isActive = true, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderLine, width: 0.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 96,
              child: Stack(fit: StackFit.expand, children: [
                imagePath != null
                    ? Image.asset(imagePath!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgFallback())
                    : _imgFallback(),
                Positioned(left: 0, top: 0, bottom: 0, width: 4,
                  child: Container(color: kPrimary)),
              ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: _syne(11, FontWeight.w800, kDarkText, height: 1.3)),
                  Row(children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: kSubText),
                    const SizedBox(width: 3),
                    Flexible(child: Text('$date  •  $time',
                      style: _dm(10, FontWeight.w600, kDarkText),
                      overflow: TextOverflow.ellipsis)),
                  ]),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 11, color: kSubText),
                    const SizedBox(width: 3),
                    Expanded(child: Text(location,
                      style: _dm(10, FontWeight.w400, kSubText),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: kDarkText,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('View Details',
                      style: _syne(10, FontWeight.w800, kPrimary)),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _imgFallback() => Container(
    color: kSliderDark,
    child: const Center(child: Icon(Icons.image_not_supported_outlined, color: kSubText)),
  );
}
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 4, height: 18,
            decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: _syne(15, FontWeight.w800, kDarkText)),
        ]),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('See All >', style: _syne(10, FontWeight.w800, kPrimary,)),
            ),
          ),
      ]),
    );
  }
}
class _Dots extends StatelessWidget {
  final int current, total;
  const _Dots({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = current == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6, height: 6,
          decoration: BoxDecoration(
            color: active ? kPrimary : kSubText.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
class UpcomingEventCard extends StatelessWidget {
  final String? imagePath;
  final String title, date, time, location;
  final bool isActive;
  final VoidCallback? onViewEvent, onCardTap, onShare;
  const UpcomingEventCard({
    super.key, this.imagePath, required this.title, required this.date,
    required this.time, required this.location, this.isActive = true,
    this.onViewEvent, this.onCardTap, this.onShare,
  });
  @override
  Widget build(BuildContext context) => _HorizontalCard(
    imagePath: imagePath, title: title, date: date,
    time: time, location: location, isActive: isActive,
    onTap: onViewEvent ?? onCardTap,
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(children: [
        Container(width: 4, height: 18,
          decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: _syne(18, FontWeight.w800, kDarkText)),
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ]),
    );
  }
}

class _LocationSheet extends StatefulWidget {
  final List<SavedAddress> addresses;
  final String selected;
  final void Function(String label, String address) onSelect;
  const _LocationSheet({required this.addresses, required this.selected, required this.onSelect});
  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  bool _fetching = false;
  bool _searching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<LocationDetails> _suggestions = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _gps() async {
    setState(() => _fetching = true);
    
    final hasPermission = await LocationService.requestPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() => _fetching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
      }
      return;
    }

    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      if (mounted) {
        setState(() => _fetching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not obtain GPS position.')),
        );
      }
      return;
    }

    final details = await LocationService.reverseGeocode(pos.latitude, pos.longitude);
    if (mounted) {
      setState(() => _fetching = false);
      if (details != null) {
        await LocationService.cacheLocation(details);
        final token = await ApiService.getToken();
        if (token != null) {
          await LocationService.syncLocationWithBackend(details);
        }
        widget.onSelect(details.formattedAddress, '${details.area}, ${details.district}, ${details.state} - ${details.pincode}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geocoding failed. Try manual search.')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    final results = await LocationService.searchLocation(query);
    if (mounted) {
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bi = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: kWhite, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: bi + 24, top: 16, left: 20, right: 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 38, height: 4,
          decoration: BoxDecoration(color: kBorderLine, borderRadius: BorderRadius.circular(3)))),
        const SizedBox(height: 20),
        Text('Select Location', style: _syne(20, FontWeight.w800, kDarkText)),
        const SizedBox(height: 16),
        
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorderLine),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: _dm(14, FontWeight.w500, kDarkText),
            decoration: InputDecoration(
              hintText: 'Search city, area or street...',
              hintStyle: _dm(14, FontWeight.w400, kSubText),
              prefixIcon: const Icon(Icons.search_rounded, color: kSubText, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        _performSearch('');
                      },
                      child: const Icon(Icons.close_rounded, color: kSubText, size: 20),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_searching) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: kPrimary),
            ),
          ),
        ] else if (_suggestions.isNotEmpty) ...[
          Text('SEARCH RESULTS',
            style: _dm(11, FontWeight.w800, kSubText, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, idx) {
                final item = _suggestions[idx];
                return GestureDetector(
                  onTap: () async {
                    await LocationService.cacheLocation(item);
                    final token = await ApiService.getToken();
                    if (token != null) {
                      await LocationService.syncLocationWithBackend(item);
                    }
                    widget.onSelect(item.formattedAddress, item.area.isNotEmpty ? '${item.area}, ${item.district}, ${item.state} - ${item.pincode}' : item.formattedAddress);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorderLine),
                    ),
                    child: Row(children: [
                      Container(width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.location_on_rounded, size: 18, color: kPrimary)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.formattedAddress, style: _syne(12, FontWeight.w700, kDarkText)),
                        const SizedBox(height: 2),
                        Text(
                          item.area.isNotEmpty ? '${item.area}, ${item.district}, ${item.state} ${item.pincode}' : item.formattedAddress,
                          style: _dm(11, FontWeight.w400, kSubText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ])),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ] else ...[
          GestureDetector(
            onTap: _fetching ? null : _gps,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kPrimary.withOpacity(0.4))),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: const BoxDecoration(color: kDarkText, shape: BoxShape.circle),
                  child: _fetching
                      ? const Padding(padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary))
                      : const Icon(Icons.my_location_rounded, color: kPrimary, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Use Current Location',
                    style: _syne(13, FontWeight.w700, kDarkText)),
                  Text(_fetching ? 'Fetching GPS...' : 'Tap to enable GPS',
                    style: _dm(11, FontWeight.w400, kSubText)),
                ])),
                if (!_fetching)
                  const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: kDarkText),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Text('SAVED ADDRESSES',
            style: _dm(11, FontWeight.w800, kSubText, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ...widget.addresses.map((addr) {
            final sel = widget.selected == addr.address;
            return GestureDetector(
              onTap: () => widget.onSelect(addr.label, addr.address),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: sel ? kPrimary.withOpacity(0.07) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? kPrimary : kBorderLine, width: sel ? 1.5 : 1)),
                child: Row(children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: sel ? kPrimary : kDarkText.withOpacity(0.07), shape: BoxShape.circle),
                    child: Icon(addr.icon, size: 18, color: sel ? kDarkText : kSubText)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(addr.label, style: _syne(12, FontWeight.w700,
                      sel ? kDarkText : kDarkText)),
                    const SizedBox(height: 2),
                    Text(addr.address,
                      style: _dm(11, FontWeight.w400, kSubText),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ])),
                  if (sel)
                    Container(width: 22, height: 22,
                      decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, color: kDarkText, size: 13)),
                ]),
              ),
            );
          }),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kPrimary.withOpacity(0.5)),
                color: kPrimary.withOpacity(0.06)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 20, height: 20,
                  decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, size: 13, color: kDarkText)),
                const SizedBox(width: 8),
                Text('Add New Address',
                  style: _syne(12, FontWeight.w700, kDarkText)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

class _DynamicSlideCard extends StatelessWidget {
  final Map<String, dynamic> banner;
  final VoidCallback? onTap;
  const _DynamicSlideCard({required this.banner, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = banner['imageUrl'] ?? '';
    final String title = banner['title'] ?? '';
    final String subtitle = banner['subtitle'] ?? '';
    final String ctaText = banner['ctaText'] ?? 'Explore Now';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: kSliderDark,
        child: Stack(fit: StackFit.expand, children: [
          if (imageUrl.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: kSliderDark,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: kPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),

          Positioned(
            left: 20, bottom: 24, top: 20, right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _syne(22, FontWeight.w800, Colors.white,
                        letterSpacing: -0.5, height: 1.05),
                  ),
                const SizedBox(height: 4),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _dm(11, FontWeight.w500, Colors.white.withOpacity(0.75)),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ctaText.toUpperCase(),
                        style: _syne(9, FontWeight.w800, kDarkText, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 12, color: kDarkText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}