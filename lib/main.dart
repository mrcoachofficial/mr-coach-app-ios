
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:mrcoach/home%20screens/home2_screen.dart';
import 'package:mrcoach/profile_settings_pages/daily_task_screen.dart';
import 'package:mrcoach/profile_settings_pages/profile_screen.dart';
import 'package:mrcoach/profile_settings_pages/login_screen.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:mrcoach/theme_notifier.dart';
import 'package:mrcoach/utils/localization.dart';
import 'package:mrcoach/my_bookings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrcoach/profile_settings_pages/intro_video_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void initOneSignalNotifications() {
  // Initialize OneSignal
  OneSignal.initialize("4eb38845-7c1d-400f-b4dd-a7358920c77e");
  OneSignal.Notifications.requestPermission(true);

  // Click handler to redirect user on click
  OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
    final Map<String, dynamic>? additionalData = event.notification.additionalData;
    if (additionalData != null && additionalData.containsKey('redirectUrl')) {
      final String redirectUrl = additionalData['redirectUrl'];
      if (redirectUrl == '/bookings') {
        navigatorKey.currentState?.pushNamed('/bookings');
      }
    }
  });
}

bool isLoggedIn = false;
bool hasSeenIntro = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalizations.loadLanguage();
  await ApiService.loadCachedHomeResources();
  final token = await ApiService.getToken();
  isLoggedIn = token != null;
  
  // Check if they have seen the intro video
  final prefs = await SharedPreferences.getInstance();
  hasSeenIntro = prefs.getBool('seen_intro') ?? false;
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
    initOneSignalNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),

      home: !hasSeenIntro
          ? IntroVideoScreen(isLoggedIn: isLoggedIn)
          : (isLoggedIn ? const Home2Screen() : const LoginScreen()),

      routes: {
        '/home': (context) => const Home2Screen(),
        '/bookings': (context) => const AllMyBookingsScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}


const kYellow = Color(0xFFFFD600);
const kBlack = Color(0xFF111111);
const kGrey = Color(0xFF666666);
const kLightGrey = Color(0xFFF5F5F5);
const Color kGreen      = Color(0xFF4CAF50);
const Color kOrange     = Color(0xFFFF9800);
const Color kBlackNav   = Color(0xFF1A1A1A);
const Color kGreyText   = Color(0xFF888888);
const Color kBgGrey     = Color(0xFFF5F5F5);
const Color kEventBg    = Color(0xFFFFF8E7);


 
