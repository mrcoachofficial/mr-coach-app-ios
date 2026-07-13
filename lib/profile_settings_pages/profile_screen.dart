import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrcoach/home%20screens/fitness_screen.dart';
import 'package:mrcoach/home%20screens/scratch_card_screen.dart';
import 'package:mrcoach/my_bookings_page.dart';
import 'package:mrcoach/profile_settings_pages/daily_task_screen.dart';
import 'package:mrcoach/profile_settings_pages/login_screen.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:mrcoach/utils/localization.dart';
import 'package:scratcher/scratcher.dart';
import 'package:mrcoach/webview_screen.dart';
import 'package:mrcoach/profile_settings_pages/legal_screens.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

const Color kPrimary      = Color(0xFFF9C413);
const Color kPrimaryDark  = Color(0xFFE0AC00);
const Color kPrimaryDeep  = Color(0xFFB88A00);
const Color kPrimaryPale  = Color(0xFFFFFBE6);
const Color kPrimaryLight = Color(0xFFFFF3B0);
const Color kBg           = Color(0xFFFAF9F5);
const Color kCard         = Color(0xFFFFFFFF);
const Color kDark         = Color(0xFF1C1B1A);
const Color kMid          = Color(0xFF888880);
const Color kBorder       = Color(0xFFEEEDEA);
const Color kGreen        = Color(0xFF2E9E6B);
const Color kGreenPale    = Color(0xFFEAF7F1);
const Color kBlue         = Color(0xFFF9C413);
const Color kBluePale     = Color(0xFFEBF1FD);
const Color kOrange       = Color(0xFFFF7A2F);
const Color kOrangePale   = Color(0xFFFFF0E8);
const Color kRed          = Color(0xFFE03131);
const Color kRedPale      = Color(0xFFFDECEC);


enum OrderStatus { pending, confirmed, inProgress, completed, cancelled }

extension OrdExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.inProgress: return 'In Progress';
      case OrderStatus.completed:  return 'Completed';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }
  Color get color {
    switch (this) {
      case OrderStatus.pending:    return kOrange;
      case OrderStatus.confirmed:  return kBlue;
      case OrderStatus.inProgress: return kPrimaryDark;
      case OrderStatus.completed:  return kGreen;
      case OrderStatus.cancelled:  return kRed;
    }
  }
  Color get pale {
    switch (this) {
      case OrderStatus.pending:    return kOrangePale;
      case OrderStatus.confirmed:  return kBluePale;
      case OrderStatus.inProgress: return kPrimaryPale;
      case OrderStatus.completed:  return kGreenPale;
      case OrderStatus.cancelled:  return kRedPale;
    }
  }
  IconData get icon {
    switch (this) {
      case OrderStatus.pending:    return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:  return Icons.check_circle_outline_rounded;
      case OrderStatus.inProgress: return Icons.directions_run_rounded;
      case OrderStatus.completed:  return Icons.verified_rounded;
      case OrderStatus.cancelled:  return Icons.cancel_outlined;
    }
  }
}

class CoachingOrder {
  final String id, title, coach, coachInitials, date, time, venue, category;
  final double amount;
  final OrderStatus status;
  final String? note;
  const CoachingOrder({
    required this.id, required this.title, required this.coach,
    required this.coachInitials, required this.date, required this.time,
    required this.venue, required this.amount, required this.status,
    required this.category, this.note,
  });
}

final List<CoachingOrder> kOrders = [];


final List<_ShopOrder> kShopOrders = [];



enum ScratchTheme { gold, blue, green, purple, red, light }

extension ScratchThemeExt on ScratchTheme {
  Color get foilColor {
    switch (this) {
      case ScratchTheme.gold:   return const Color(0xFFE0AC00);
      case ScratchTheme.blue:   return const Color(0xFFE0AC00);
      case ScratchTheme.green:  return const Color(0xFF7C4DFF);
      case ScratchTheme.purple: return const Color(0xFFE0AC00);
      case ScratchTheme.red:    return const Color(0xFFE03131);
      case ScratchTheme.light:  return const Color(0xFFE0AC00);
    }
  }

  List<Color> get gradient {
    switch (this) {
      case ScratchTheme.gold:
        return [const Color(0xFFFFD966), const Color(0xFFF9C413), const Color(0xFFE0AC00)];
      case ScratchTheme.blue:
        return [const Color(0xFFFFD966), const Color(0xFFF9C413), const Color(0xFFE0AC00)];
      case ScratchTheme.green:
        return [const Color(0xFFB388FF), const Color(0xFF7C4DFF), const Color(0xFF5E35B1)];
      case ScratchTheme.purple:
        return [const Color(0xFFFFD966), const Color(0xFFF9C413), const Color(0xFFE0AC00)];
      case ScratchTheme.red:
        return [const Color(0xFFFF7070), const Color(0xFFE03131), const Color(0xFFC00000)];
      case ScratchTheme.light:
        return [const Color(0xFFFFD966), const Color(0xFFF9C413), const Color(0xFFE0AC00)];
    }
  }

  Color get accent {
    switch (this) {
      case ScratchTheme.gold:   return kPrimaryDeep;
      case ScratchTheme.blue:   return kBlue;
      case ScratchTheme.green:  return const Color(0xFF5E35B1);
      case ScratchTheme.purple: return kBlue;
      case ScratchTheme.red:    return kRed;
      case ScratchTheme.light:  return kPrimaryDeep;
    }
  }
}

class ScratchCardModel {
  final String id, reward, subReward, condition, earnedFrom, expiry;
  final ScratchTheme theme;
  final bool expired;
  bool scratched;
  bool claimed;
  ScratchCardModel({
    required this.id, required this.reward, required this.subReward,
    required this.condition, required this.earnedFrom, required this.expiry,
    required this.theme, this.expired = false,
    this.scratched = false, this.claimed = false,
  });
}

final List<ScratchCardModel> kScratchCards = [
  ScratchCardModel(id: 'SC001', reward: '₹100', subReward: 'Cashback',
      condition: 'On next booking', earnedFrom: '7-Day Streak',
      expiry: 'Expires Jul 20', theme: ScratchTheme.gold),
  ScratchCardModel(id: 'SC002', reward: '20%', subReward: 'Discount',
      condition: 'On Yoga sessions', earnedFrom: 'Challenge Reward',
      expiry: 'Expires Jul 25', theme: ScratchTheme.blue,
      scratched: true, claimed: true),
  ScratchCardModel(id: 'SC003', reward: '₹500', subReward: 'Free Session',
      condition: 'Any category', earnedFrom: 'Referral Bonus',
      expiry: 'Expires Aug 5', theme: ScratchTheme.green),
  ScratchCardModel(id: 'SC004', reward: '₹50', subReward: 'Cashback',
      condition: 'Min booking ₹299', earnedFrom: '5-Star Review',
      expiry: 'Expires Aug 2', theme: ScratchTheme.purple,
      scratched: true),
  ScratchCardModel(id: 'SC005', reward: '₹150', subReward: 'Wallet Bonus',
      condition: 'Auto-credited', earnedFrom: 'Fitness Explorer',
      expiry: 'Expires Aug 10', theme: ScratchTheme.gold),
  ScratchCardModel(id: 'SC006', reward: '₹75', subReward: 'Cashback',
      condition: 'On equipment', earnedFrom: 'First Purchase',
      expiry: 'Expired Jun 30', theme: ScratchTheme.red, expired: true),
];



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  String _name  = 'Enter your name';
  String _email = '...@gmail.com';
  String _phone = '+91 98765 43210';
  File?  _avatar;
  String? _pickedWebPath;

  String _gender = '';
  int? _age;
  String _dateOfBirth = '';
  String _area = '';
  String _pincode = '';
  String _district = '';
  String _stateField = '';
  String _serviceType = '';
  String _preferredLanguage = 'English';
  String _alternatePhone = '';
  String _address = '';
  String? _profileImageUrl;
  String _emergencyContact = '';
  String _fitnessGoal = '';

  bool _notifBookings  = true;
  bool _notifOffers    = true;
  bool _notifReminders = true;
  bool _notifMarketing = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final cached = await ApiService.getCachedProfile();
    if (mounted) {
      setState(() {
        _name = cached['name']!;
        _email = cached['email']!;
      });
    }
    final fresh = await ApiService.getUserProfile();
    if (fresh != null && mounted) {
      setState(() {
        if (fresh['name'] != null) _name = fresh['name'];
        if (fresh['email'] != null) _email = fresh['email'];
        if (fresh['gender'] != null) _gender = fresh['gender'];
        if (fresh['age'] != null) _age = fresh['age'] is int ? fresh['age'] : int.tryParse(fresh['age'].toString());
        if (fresh['dateOfBirth'] != null) _dateOfBirth = fresh['dateOfBirth'];
        if (fresh['area'] != null) _area = fresh['area'];
        if (fresh['pincode'] != null) _pincode = fresh['pincode'];
        if (fresh['district'] != null) _district = fresh['district'];
        if (fresh['state'] != null) _stateField = fresh['state'];
        if (fresh['serviceType'] != null) _serviceType = fresh['serviceType'];
        if (fresh['preferredLanguage'] != null) _preferredLanguage = fresh['preferredLanguage'];
        if (fresh['alternatePhone'] != null) _alternatePhone = fresh['alternatePhone'];
        if (fresh['address'] != null) _address = fresh['address'];
        if (fresh['profileImage'] != null) _profileImageUrl = fresh['profileImage'];
        if (fresh['emergencyContact'] != null) _emergencyContact = fresh['emergencyContact'];
        if (fresh['fitnessGoal'] != null) _fitnessGoal = fresh['fitnessGoal'];
      });
    }
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _pickAvatar() async {
    final src = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AvatarSheet(onRemove: () async {
        Navigator.pop(context);
        setState(() {
          _avatar = null;
          _pickedWebPath = null;
        });
        final res = await ApiService.removeProfileImage();
        if (res['success'] == true) {
          setState(() {
            _profileImageUrl = null;
          });
          _snack(AppLocalizations.translate('profile_image_removed'));
        } else {
          _snack(res['message'] ?? 'Failed to remove image', err: true);
        }
      }),
    );
    if (src == null) return;
    if (src is ImageSource) {
      final p = await ImagePicker()
          .pickImage(source: src, maxWidth: 512, maxHeight: 512, imageQuality: 85);
      if (p != null) {
        setState(() {
          if (kIsWeb) {
            _pickedWebPath = p.path;
            _avatar = null;
          } else {
            _avatar = File(p.path);
            _pickedWebPath = null;
          }
        });
        final res = await ApiService.uploadProfileImage(p);
        if (res['success'] == true) {
          setState(() {
            _profileImageUrl = res['profileImage'];
          });
          _snack(AppLocalizations.translate('profile_image_updated'));
        } else {
          _snack(res['message'] ?? 'Upload failed', err: true);
        }
      }
    }
  }

  void _openEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _EditSheet(
        name: _name,
        email: _email,
        alternatePhone: _alternatePhone,
        address: _address,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        serviceType: _serviceType,
        preferredLanguage: _preferredLanguage,
        area: _area,
        pincode: _pincode,
        district: _district,
        stateField: _stateField,
        emergencyContact: _emergencyContact,
        fitnessGoal: _fitnessGoal,
        age: _age,
        onSave: (updatedData) async {
          Navigator.pop(ctx);
          setState(() {
            _name = updatedData['name'];
            _email = updatedData['email'];
            _alternatePhone = updatedData['alternatePhone'];
            _address = updatedData['address'];
            _gender = updatedData['gender'];
            _dateOfBirth = updatedData['dateOfBirth'];
            _serviceType = updatedData['serviceType'];
            _preferredLanguage = updatedData['preferredLanguage'];
            _area = updatedData['area'];
            _pincode = updatedData['pincode'];
            _district = updatedData['district'];
            _stateField = updatedData['state'];
            _emergencyContact = updatedData['emergencyContact'];
            _fitnessGoal = updatedData['fitnessGoal'];
            _age = updatedData['age'];
          });
          
          final res = await ApiService.updateProfile(updatedData);
          if (res['success'] == true) {
            _snack(AppLocalizations.translate('profile_updated'));
            _loadUserProfile();
          } else {
            _snack(res['message'] ?? AppLocalizations.translate('failed_to_update'), err: true);
          }
        },
      ),
    );
  }

  void _openChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: _Handle()),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: kPrimaryPale,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: kPrimaryDark,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppLocalizations.translate('change_password'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.translate('change_password_info'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kDark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        AppLocalizations.translate('cancel'),
                        style: const TextStyle(color: kMid, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await ApiService.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.translate('logout'),
                        style: const TextStyle(color: kDark, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
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

  void _openLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Handle(),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.translate('choose_language'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDark),
              ),
              const SizedBox(height: 16),
              _SheetTile(
                icon: Icons.language_rounded,
                label: 'English (EN)',
                onTap: () async {
                  await AppLocalizations.saveLanguage('EN');
                  Navigator.pop(ctx);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.language_rounded,
                label: 'தமிழ் (TA)',
                onTap: () async {
                  await AppLocalizations.saveLanguage('TA');
                  Navigator.pop(ctx);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.language_rounded,
                label: 'हिन्दी (HI)',
                onTap: () async {
                  await AppLocalizations.saveLanguage('HI');
                  Navigator.pop(ctx);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700, color: kDark)),
      backgroundColor: err ? kRed : kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _confirm({
    required String title, required String msg,
    required String btnLabel, required Color btnColor, required Color btnText,
    required IconData icon, required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: title, msg: msg, btnLabel: btnLabel,
        btnColor: btnColor, btnText: btnText, icon: icon, onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(children: [
                  const SizedBox(height: 20),

                  
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AnimatedQuickCard(
                          icon: Icons.receipt_long_rounded,
                          animIcons: const [
                            Icons.receipt_long_rounded,
                            Icons.calendar_month_rounded,
                            Icons.check_circle_rounded,
                          ],
                          label: '  My Bookings  ',
                          color: kPrimaryDark,
                          pale: kPrimaryPale,
                          badgeCount: kOrders.length,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AllMyBookingsScreen())),
                        ),
                        const SizedBox(width: 5), // ← was 10, now 5
                        _AnimatedQuickCard(
                          icon: Icons.emoji_events_rounded,
                          animIcons: const [
                            Icons.emoji_events_rounded,
                            Icons.local_fire_department_rounded,
                            Icons.star_rounded,
                          ],
                          label: '   Challenges   ',
                          color: const Color(0xFF4B8EF1),
                          pale: kBluePale,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const TasksHomeScreen())),
                        ),
                        const SizedBox(width: 5), // ← was 10, now 5
                        _AnimatedQuickCard(
                          icon: Icons.card_giftcard_rounded,
                          animIcons: const [
                            Icons.card_giftcard_rounded,
                            Icons.redeem_rounded,
                            Icons.celebration_rounded,
                          ],
                          label: 'Scratch Rewards',
                          color: kGreen,
                          pale: kGreenPale,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ScratchRewardsPage())),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _ReferralBanner(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ReferralPage())),
                  ),

                  const SizedBox(height: 16),
                  _MyBookingsBanner(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AllMyBookingsScreen())),
                  ),

                  const SizedBox(height: 24),
                  _Section(title: AppLocalizations.translate('account'), icon: Icons.manage_accounts_outlined, tiles: [
                    _Tile(icon: Icons.person_outline_rounded, label: AppLocalizations.translate('edit_profile'),
                        sub: _name, onTap: _openEdit,
                        trail: const Icon(Icons.chevron_right_rounded, color: kMid, size: 20)),
                    _Tile(icon: Icons.lock_outline_rounded, label: AppLocalizations.translate('change_password'),
                        onTap: _openChangePassword,
                        trail: const Icon(Icons.chevron_right_rounded, color: kMid, size: 20)),
                    _Tile(icon: Icons.language_rounded, label: AppLocalizations.translate('language'), sub: _preferredLanguage,
                        onTap: _openLanguageSelector,
                        trail: Row(mainAxisSize: MainAxisSize.min, children: [
                          _Chip(label: AppLocalizations.currentLanguage),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, color: kMid, size: 20),
                        ])),
                  ]),
                  
                  const SizedBox(height: 18),
                  _Section(title: AppLocalizations.translate('profile_title').toUpperCase(), icon: Icons.badge_outlined, tiles: [
                    _Tile(
                      icon: Icons.wc_rounded,
                      label: AppLocalizations.translate('gender'),
                      sub: _gender.isNotEmpty ? _gender : 'Not set',
                    ),
                    _Tile(
                      icon: Icons.cake_outlined,
                      label: AppLocalizations.translate('date_of_birth'),
                      sub: _dateOfBirth.isNotEmpty ? '$_dateOfBirth${_age != null ? ' ($_age yrs)' : ''}' : 'Not set',
                    ),
                    _Tile(
                      icon: Icons.fitness_center_rounded,
                      label: AppLocalizations.translate('fitness_goal'),
                      sub: _fitnessGoal.isNotEmpty ? _fitnessGoal : 'Not set',
                    ),
                    _Tile(
                      icon: Icons.handshake_outlined,
                      label: AppLocalizations.translate('service_type'),
                      sub: _serviceType.isNotEmpty ? _serviceType : 'Not set',
                    ),
                    _Tile(
                      icon: Icons.contact_phone_outlined,
                      label: AppLocalizations.translate('alternate_phone'),
                      sub: _alternatePhone.isNotEmpty ? _alternatePhone : 'Not set',
                    ),
                    _Tile(
                      icon: Icons.emergency_outlined,
                      label: AppLocalizations.translate('emergency_contact'),
                      sub: _emergencyContact.isNotEmpty ? _emergencyContact : 'Not set',
                    ),
                    _Tile(
                      icon: Icons.location_on_outlined,
                      label: AppLocalizations.translate('address'),
                      sub: _address.isNotEmpty ? _address : (_area.isNotEmpty ? '$_area, $_district, $_stateField' : 'Not set'),
                    ),
                  ]),

                  const SizedBox(height: 18),
                  _Section(title: AppLocalizations.translate('notifications'), icon: Icons.notifications_outlined, tiles: [
                    _Toggle(icon: Icons.calendar_today_rounded, label: 'Booking Updates',
                        sub: 'Session confirmations & changes',
                        value: _notifBookings,
                        onChanged: (v) => setState(() => _notifBookings = v)),
                    _Toggle(icon: Icons.access_time_rounded, label: 'Session Reminders',
                        sub: '30 mins before your session',
                        value: _notifReminders,
                        onChanged: (v) => setState(() => _notifReminders = v)),
                    _Toggle(icon: Icons.local_offer_outlined, label: 'Offers & Deals',
                        sub: 'Exclusive discounts for you',
                        value: _notifOffers,
                        onChanged: (v) => setState(() => _notifOffers = v)),
                  ]),

                  const SizedBox(height: 18),
                  _Section(title: AppLocalizations.translate('app_info'), icon: Icons.info_outline_rounded, tiles: [
                    _Tile(icon: Icons.shield_outlined, label: 'Privacy Policy',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ));
                        },
                        trail: const Icon(Icons.chevron_right_rounded, color: kMid, size: 20)),
                    _Tile(icon: Icons.description_outlined, label: 'Terms of Service',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const TermsOfServiceScreen(),
                          ));
                        },
                        trail: const Icon(Icons.chevron_right_rounded, color: kMid, size: 20)),
                    _Tile(icon: Icons.star_outline_rounded, label: 'Rate MrCoach',
                        sub: 'Love the app? Tell others!', onTap: () {},
                        trail: Row(mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (_) =>
                                const Icon(Icons.star_rounded, size: 12, color: kPrimary)))),
                    _Tile(icon: Icons.help_outline_rounded, label: 'Help & Support',
                        onTap: () async {
                          final whatsappUri = Uri.parse("https://wa.me/917448421134?text=Hello%20MrCoach%20Support,%20I%20need%20help!");
                          if (await canLaunchUrl(whatsappUri)) {
                            await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                          } else {
                            _snack('Could not launch WhatsApp. Support: +91 74484 21134', err: true);
                          }
                        },
                        trail: const Icon(Icons.chevron_right_rounded, color: kMid, size: 20)),
                    _Tile(icon: Icons.info_outline_rounded, label: 'App Version',
                        sub: 'MrCoach v1.0.0', onTap: () {},
                        trail: _Chip(label: 'v1.0.0')),
                  ]),

                  const SizedBox(height: 18),
                  _Section(title: AppLocalizations.translate('actions'), icon: Icons.warning_amber_rounded,
                      titleColor: kRed, tiles: [
                    _Tile(
                      icon: Icons.login_rounded, iconColor: kGreen,
                      label: AppLocalizations.translate('login'), labelColor: kDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      trail: const Icon(Icons.chevron_right_rounded, color: kMid, size: 20),
                    ),
                    _Tile(
                      icon: Icons.logout_rounded, iconColor: kPrimaryDark,
                      label: AppLocalizations.translate('logout'), labelColor: kDark,
                      onTap: () => _confirm(
                        title: AppLocalizations.translate('logout'),
                        msg: 'Are you sure you want to log out of MrCoach?',
                        btnLabel: AppLocalizations.translate('logout'), btnColor: kPrimary, btnText: kDark,
                        icon: Icons.logout_rounded,
                        onConfirm: () async { 
                          Navigator.pop(context); 
                          await ApiService.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                      trail: const Icon(Icons.chevron_right_rounded, color: kMid, size: 20),
                    ),
                    _Tile(
                      icon: Icons.delete_forever_rounded, iconColor: kRed,
                      label: AppLocalizations.translate('delete_account'), labelColor: kRed,
                      sub: 'Permanently remove all data',
                      onTap: () => _confirm(
                        title: AppLocalizations.translate('delete_account'),
                        msg: 'This permanently deletes your account. Cannot be undone.',
                        btnLabel: 'Delete', btnColor: kRed, btnText: Colors.white,
                        icon: Icons.warning_amber_rounded,
                        onConfirm: () async {
                          Navigator.pop(context);
                          _snack('Deleting account...');
                          final res = await ApiService.deleteAccount();
                          if (res['success'] == true) {
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res['message'] ?? 'Account deleted successfully'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: kRed,
                                ),
                              );
                            }
                          } else {
                            _snack(res['message'] ?? 'Account deletion failed', err: true);
                          }
                        },
                      ),
                      trail: const Icon(Icons.chevron_right_rounded, color: kRed, size: 20),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  const _Footer(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 32,
      ),
      child: Column(children: [
        Row(children: [
          _HeaderBtn(icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context)),
          const Spacer(),
          Text(AppLocalizations.translate('profile_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kDark)),
          const Spacer(),
          _HeaderBtn(icon: Icons.edit_rounded, onTap: _openEdit),
        ]),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _pickAvatar,
          child: Stack(children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [BoxShadow(
                    color: kPrimaryDark.withOpacity(0.3),
                    blurRadius: 20, spreadRadius: 2)],
              ),
              child: ClipOval(
                child: kIsWeb
                    ? (_pickedWebPath != null
                        ? Image.network(_pickedWebPath!, fit: BoxFit.cover)
                        : _profileImageUrl != null
                            ? Image.network(
                                ApiService.getMediaUrl(_profileImageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _name.isNotEmpty ? _name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: kPrimaryDark),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                alignment: Alignment.center,
                                child: Text(
                                  _name.isNotEmpty ? _name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: kPrimaryDark),
                                ),
                              ))
                    : (!kIsWeb && _avatar != null
                        ? Image.file(_avatar!, fit: BoxFit.cover)
                        : _profileImageUrl != null
                            ? Image.network(
                                ApiService.getMediaUrl(_profileImageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _name.isNotEmpty ? _name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: kPrimaryDark),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                alignment: Alignment.center,
                                child: Text(
                                  _name.isNotEmpty ? _name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: kPrimaryDark),
                                ),
                              )),
              ),
            ),
            Positioned(bottom: 0, right: 0,
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                    color: kDark, shape: BoxShape.circle,
                    border: Border.all(color: kPrimary, width: 2)),
                child: const Icon(Icons.camera_alt_rounded, size: 14, color: kPrimary),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Text(_name, style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w900, color: kDark, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(_email, style: TextStyle(fontSize: 12, color: kDark.withOpacity(0.6))),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(
                color: kPrimaryDark.withOpacity(0.2),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.verified_rounded, size: 15, color: kPrimaryDark),
            const SizedBox(width: 7),
            Text(AppLocalizations.translate('member'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kDark)),
          ]),
        ),
      ]),
    );
  }
}
class _AnimatedQuickCard extends StatefulWidget {
  final IconData icon;
  final List<IconData> animIcons;
  final String label;
  final Color color, pale;
  final VoidCallback onTap;
  final int badgeCount;

  const _AnimatedQuickCard({
    required this.icon,
    required this.animIcons,
    required this.label,
    required this.color,
    required this.pale,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_AnimatedQuickCard> createState() => _AnimatedQuickCardState();
}

class _AnimatedQuickCardState extends State<_AnimatedQuickCard>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _iconCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _bounceAnim;
  late Animation<double> _iconScaleAnim;
  late Animation<double> _iconOpacityAnim;
  late Animation<double> _glowAnim;

  int _iconIndex = 0;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconScaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut));
    _iconOpacityAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 50),
    ]).animate(_iconCtrl);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    final stagger = widget.label.length * 300;
    Future.delayed(Duration(milliseconds: stagger), _cycleIcons);
  }

  void _cycleIcons() {
    if (!mounted) return;
    _iconCtrl.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _iconIndex = (_iconIndex + 1) % widget.animIcons.length;
      });
      Future.delayed(const Duration(milliseconds: 2000), _cycleIcons);
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _iconCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedBuilder(
          animation: Listenable.merge([_bounceAnim, _glowAnim, _iconScaleAnim]),
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, _bounceAnim.value),
              child: AnimatedScale(
                scale: _pressed ? 0.93 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: widget.color.withOpacity(0.15 + _glowAnim.value * 0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.12 + _glowAnim.value * 0.1),
                            blurRadius: 12 + _glowAnim.value * 8,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: widget.pale,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.2 + _glowAnim.value * 0.15),
                                  blurRadius: 8 + _glowAnim.value * 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _iconCtrl,
                                builder: (_, __) => Opacity(
                                  opacity: _iconOpacityAnim.value.clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: _iconScaleAnim.value.clamp(0.0, 1.5),
                                    child: Icon(
                                      widget.animIcons[_iconIndex],
                                      color: widget.color,
                                      size: 21,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (widget.badgeCount > 0)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: widget.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.badgeCount}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class _ReferralBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ReferralBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
            color: kPrimary.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.people_alt_rounded, color: kDark, size: 26),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Refer & Earn ₹200',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: kDark)),
          SizedBox(height: 3),
          Text('Invite friends & earn\nrewards together!',
              style: TextStyle(fontSize: 11, color: kDark, height: 1.4)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: kDark, borderRadius: BorderRadius.circular(14)),
          child: const Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Invite', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kPrimary)),
            Text('Now →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kPrimary)),
          ]),
        ),
      ]),
    ),
  );
}
class _MyBookingsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _MyBookingsBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = kOrders.where((o) =>
        o.status == OrderStatus.inProgress ||
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.pending).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 14, 12),
            child: Row(children: [
              Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: kPrimaryPale, borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.receipt_long_rounded, color: kPrimaryDark, size: 22)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('My Bookings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kDark)),
                SizedBox(height: 2),
                Text('Your coaching sessions', style: TextStyle(fontSize: 11, color: kMid)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${kOrders.length} Sessions',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kDark)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: kDark),
                ]),
              ),
            ]),
          ),
          Container(height: 1, color: kBorder, margin: const EdgeInsets.symmetric(horizontal: 18)),
          const SizedBox(height: 12),
          if (active.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 18, bottom: 8),
              child: Text('Active Sessions (${active.length})',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kMid, letterSpacing: 0.8)),
            ),
            ...active.take(2).map((o) => _BannerRow(order: o)),
            const SizedBox(height: 6),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: kMid),
                const SizedBox(width: 6),
                const Text('No bookings yet — book your first session!',
                    style: TextStyle(fontSize: 12, color: kMid)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _BannerRow extends StatelessWidget {
  final CoachingOrder order;
  const _BannerRow({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: order.status.pale, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: order.status.color.withOpacity(0.15),
        child: Text(order.coachInitials,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: order.status.color)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(order.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDark)),
        const SizedBox(height: 2),
        Text('${order.date} · ${order.time}', style: const TextStyle(fontSize: 10, color: kMid)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: order.status.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8)),
        child: Text(order.status.label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: order.status.color)),
      ),
    ]),
  );
}



class MyBookings1Page extends StatefulWidget {
  const MyBookings1Page({super.key});
  @override
  State<MyBookings1Page> createState() => _MyBookings1PageState();
}

class _MyBookings1PageState extends State<MyBookings1Page>
    with SingleTickerProviderStateMixin {
  int _filter = 0;
  late AnimationController _listAnim;
  static const _tabs = ['All', 'Active', 'Completed', 'Cancelled'];

  List<CoachingOrder> get _filtered {
    switch (_filter) {
      case 1: return kOrders.where((o) =>
          o.status == OrderStatus.pending ||
          o.status == OrderStatus.confirmed ||
          o.status == OrderStatus.inProgress).toList();
      case 2: return kOrders.where((o) => o.status == OrderStatus.completed).toList();
      case 3: return kOrders.where((o) => o.status == OrderStatus.cancelled).toList();
      default: return List.from(kOrders);
    }
  }

  @override
  void initState() {
    super.initState();
    _listAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _listAnim.forward();
  }

  @override
  void dispose() { _listAnim.dispose(); super.dispose(); }

  void _openDetail(CoachingOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final orders = _filtered;
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Container(
          color: kPrimary,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16, right: 16, bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: kDark, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('My Bookings',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark)),
                Text('All your coaching sessions',
                    style: TextStyle(fontSize: 11, color: kDark, fontWeight: FontWeight.w500)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text('${kOrders.length} Total',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kDark)),
              ),
            ]),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: List.generate(_tabs.length, (i) {
                final sel = _filter == i;
                return GestureDetector(
                  onTap: () => setState(() {
                    _filter = i;
                    _listAnim.forward(from: 0);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? kDark : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(_tabs[i],
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: sel ? kPrimary : kDark)),
                  ),
                );
              })),
            ),
          ]),
        ),
        Expanded(
          child: orders.isEmpty
              ? _BookingsEmptyState()
              : FadeTransition(
            opacity: _listAnim,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: orders.length,
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                onTap: () => _openDetail(orders[i]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _BookingsEmptyState extends StatefulWidget {
  @override
  State<_BookingsEmptyState> createState() => _BookingsEmptyStateState();
}

class _BookingsEmptyStateState extends State<_BookingsEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: 0, end: -10)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, _float.value),
              child: Transform.scale(
                scale: _pulse.value,
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimary.withOpacity(0.08 + _ctrl.value * 0.06),
                    ),
                  ),
                  Container(
                    width: 86, height: 86,
                    decoration: const BoxDecoration(
                        color: kPrimaryPale, shape: BoxShape.circle),
                    child: const Icon(Icons.receipt_long_outlined, size: 40, color: kPrimaryDark),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            const Text('No Bookings Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
            const SizedBox(height: 8),
            const Text(
              'Your coaching sessions will appear here once you book a session with a coach.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kMid, height: 1.6),
            ),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) {
              final delay = i / 3;
              final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
              final size = 6.0 + t * 4;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: size, height: size,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.3 + t * 0.7),
                  shape: BoxShape.circle,
                ),
              );
            })),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: kPrimary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, color: kDark, size: 18),
                SizedBox(width: 6),
                Text('Book a Session',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
              ]),
            ),
          ],
        ),
      ),
    ),
  );
}



class _ShopOrder {
  final String id, product, category, date, status;
  final double amount;
  final int qty;
  final IconData icon;
  final Color color;
  const _ShopOrder({
    required this.id, required this.product, required this.category,
    required this.date, required this.status, required this.amount,
    required this.qty, required this.icon, required this.color,
  });
}
class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  Color _statusColor(String s) {
    if (s == 'Delivered') return kGreen;
    if (s == 'Cancelled') return kRed;
    if (s == 'Out for Delivery') return kOrange;
    return kBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Container(
          color: kPrimary,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16, right: 16, bottom: 24),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: kDark, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('My Orders',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark)),
              Text('Shop & product orders', style: TextStyle(fontSize: 11, color: kDark)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text('${kShopOrders.length} Orders',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kDark)),
            ),
          ]),
        ),
        Expanded(
          child: kShopOrders.isEmpty
              ? _OrdersEmptyState()
              : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: kShopOrders.length,
            itemBuilder: (_, i) {
              final o = kShopOrders[i];
              final sc = _statusColor(o.status);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                            color: o.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(o.icon, color: o.color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o.product,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
                        const SizedBox(height: 3),
                        Text('${o.category} · Qty: ${o.qty}',
                            style: const TextStyle(fontSize: 11, color: kMid)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: sc.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(o.status,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: sc)),
                        ),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('₹${o.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kDark)),
                        const SizedBox(height: 2),
                        Text(o.date, style: const TextStyle(fontSize: 10, color: kMid)),
                      ]),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _OrdersEmptyState extends StatefulWidget {
  @override
  State<_OrdersEmptyState> createState() => _OrdersEmptyStateState();
}

class _OrdersEmptyStateState extends State<_OrdersEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _rotateCtrl;
  late Animation<double> _floatAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _floatAnim = Tween<double>(begin: 0, end: -12)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _rotateAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotateCtrl);
  }

  @override
  void dispose() { _floatCtrl.dispose(); _rotateCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _rotateCtrl]),
        builder: (_, __) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: Stack(alignment: Alignment.center, children: [
                Transform.rotate(
                  angle: _rotateAnim.value,
                  child: Container(
                    width: 112, height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kOrange.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CustomPaint(painter: _DashedCirclePainter(color: kOrange.withOpacity(0.3))),
                  ),
                ),
                Container(
                  width: 86, height: 86,
                  decoration: BoxDecoration(
                      color: kOrangePale, shape: BoxShape.circle),
                  child: const Icon(Icons.shopping_bag_outlined, size: 40, color: kOrange),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: Transform.rotate(
                    angle: -_rotateAnim.value * 0.5,
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                          color: kPrimary, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.inventory_2_rounded, size: 14, color: kDark),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4, left: 4,
                  child: Transform.rotate(
                    angle: _rotateAnim.value * 0.3,
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                          color: kGreen, borderRadius: BorderRadius.circular(7)),
                      child: const Icon(Icons.local_shipping_rounded, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            const Text('No Orders Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
            const SizedBox(height: 8),
            const Text(
              'Shop for fitness equipment, nutrition products, and apparel. Your orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kMid, height: 1.6),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: kOrange.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text('Browse Shop',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashCount = 12;
    const dashAngle = math.pi * 2 / dashCount;
    const gap = 0.04;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    for (int i = 0; i < dashCount; i++) {
      final start = i * dashAngle + gap;
      final sweep = dashAngle - gap * 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start, sweep, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => false;
}
class _Challenge {
  final String title, desc, reward, deadline;
  final double progress;
  final IconData icon;
  final Color color;
  final bool completed;
  final int current, total;
  final int timerSeconds;
  const _Challenge({
    required this.title, required this.desc, required this.reward,
    required this.deadline, required this.progress, required this.icon,
    required this.color, this.completed = false,
    required this.current, required this.total,
    this.timerSeconds = 0,
  });
}

const _challenges = [
  _Challenge(title: '7-Day Streak 🔥', desc: 'Complete 7 sessions in a row',
      reward: '₹150 Cashback', deadline: 'Ends Jul 20',
      progress: 0.71, icon: Icons.local_fire_department_rounded, color: kOrange,
      current: 5, total: 7, timerSeconds: 172800), // 2 days remaining
  _Challenge(title: 'First Booking ⭐', desc: 'Complete your first coaching session',
      reward: 'Free Session', deadline: 'Completed',
      progress: 1.0, icon: Icons.star_rounded, color: kPrimaryDark, completed: true,
      current: 1, total: 1, timerSeconds: 0),
  _Challenge(title: 'Fitness Explorer 🧭', desc: 'Try 3 different sport categories',
      reward: '₹100 Wallet', deadline: 'Ends Jul 31',
      progress: 0.33, icon: Icons.explore_rounded, color: const Color(0xFF4B8EF1),
      current: 1, total: 3, timerSeconds: 950400), // ~11 days
  _Challenge(title: 'Refer 3 Friends 👥', desc: 'Invite 3 friends who book a session',
      reward: '₹600 Total', deadline: 'Ends Aug 5',
      progress: 0.33, icon: Icons.group_add_rounded, color: kGreen,
      current: 1, total: 3, timerSeconds: 1296000), // 15 days
  _Challenge(title: 'Morning Warrior ☀️', desc: '5 sessions before 8 AM',
      reward: 'MrCoach T-Shirt', deadline: 'Ends Aug 10',
      progress: 0.2, icon: Icons.wb_sunny_rounded, color: kPrimaryDark,
      current: 1, total: 5, timerSeconds: 1728000), // 20 days
  _Challenge(title: 'Nutrition Pro 🥗', desc: 'Book 2 nutrition consultations',
      reward: '₹200 Cashback', deadline: 'Ends Aug 15',
      progress: 0.5, icon: Icons.restaurant_menu_rounded, color: kGreen,
      current: 1, total: 2, timerSeconds: 2160000), // 25 days
];

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final done = _challenges.where((c) => c.completed).length;
    final total = _challenges.length;
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: kPrimary,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16, right: 16, bottom: 24),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(13)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: kDark, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Challenges',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kDark)),
                    Text('Complete & earn rewards',
                        style: TextStyle(fontSize: 12, color: kDark)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Text('$done/$total Done',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kDark)),
                  ),
                ]),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Row(children: [
                      const Text('Overall Progress',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDark)),
                      const Spacer(),
                      Text('${(done / total * 100).round()}%',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kDark)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: done / total,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: const AlwaysStoppedAnimation(kDark),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        const Icon(Icons.emoji_events_rounded, size: 14, color: kDark),
                        const SizedBox(width: 4),
                        Text('$done completed', style: const TextStyle(fontSize: 11, color: kDark, fontWeight: FontWeight.w600)),
                      ]),
                      Text('${total - done} remaining', style: const TextStyle(fontSize: 11, color: kDark)),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => _ChallengeCard(challenge: _challenges[i]),
                childCount: _challenges.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ChallengeCard extends StatefulWidget {
  final _Challenge challenge;
  const _ChallengeCard({required this.challenge});
  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  bool _timerRunning = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.challenge.timerSeconds;

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_remainingSeconds <= 0) return;

    if (_timerRunning) {

      setState(() => _timerRunning = false);
      HapticFeedback.lightImpact();
    } else {
      setState(() => _timerRunning = true);
      HapticFeedback.mediumImpact();
      _tick();
    }
  }

  void _tick() async {
    if (!mounted || !_timerRunning || _remainingSeconds <= 0) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted || !_timerRunning) return;

    setState(() => _remainingSeconds--);
    if (_remainingSeconds == 0) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);
      setState(() => _timerRunning = false);
      if (mounted) _showTimerDoneDialog();
      return;
    }
    if (_remainingSeconds % 10 == 0) {
      HapticFeedback.selectionClick();
    }

    if (_remainingSeconds <= 60) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.selectionClick();
    }

    _tick(); 
  }

  void _showTimerDoneDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(
                color: widget.challenge.color.withOpacity(0.3),
                blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: kPrimaryPale, shape: BoxShape.circle),
              child: Icon(Icons.timer_rounded, size: 36,
                  color: widget.challenge.color),
            ),
            const SizedBox(height: 16),
            const Text("Time's Up! ⏰",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark)),
            const SizedBox(height: 8),
            Text('Your challenge timer for\n"${widget.challenge.title}" has ended!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: kMid, height: 1.5)),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() => _remainingSeconds = widget.challenge.timerSeconds);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Reset Timer',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }


  String _formatTime(int secs) {
    if (secs <= 0) return '00:00';
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final hasTimer = c.timerSeconds > 0 && !c.completed;
    final isUrgent = _remainingSeconds > 0 && _remainingSeconds <= 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: c.completed ? kPrimary.withOpacity(0.5) : kBorder,
          width: c.completed ? 2 : 1,
        ),
        boxShadow: [BoxShadow(
            color: c.completed ? kPrimary.withOpacity(0.15) : Colors.black.withOpacity(0.05),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) {
                return Stack(alignment: Alignment.center, children: [
                  if (_timerRunning)
                    Container(
                      width: 56 + _pulseAnim.value * 8,
                      height: 56 + _pulseAnim.value * 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.color.withOpacity(0.08 + _pulseAnim.value * 0.08),
                      ),
                    ),
                  child!,
                ]);
              },
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                    color: c.completed ? kPrimaryPale : c.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16)),
                child: Icon(c.icon, color: c.completed ? kPrimaryDark : c.color, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(c.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kDark))),
                if (c.completed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(10)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_rounded, size: 12, color: kDark),
                      SizedBox(width: 3),
                      Text('DONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: kDark)),
                    ]),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(c.desc, style: const TextStyle(fontSize: 12, color: kMid, height: 1.4)),
            ])),
          ]),
        ),

        if (hasTimer) ...[
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isUrgent
                  ? kRed.withOpacity(0.06)
                  : _timerRunning
                  ? c.color.withOpacity(0.07)
                  : kBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUrgent
                    ? kRed.withOpacity(0.25)
                    : _timerRunning
                    ? c.color.withOpacity(0.2)
                    : kBorder,
              ),
            ),
            child: Row(children: [
              Icon(
                isUrgent ? Icons.warning_amber_rounded : Icons.timer_outlined,
                size: 18,
                color: isUrgent ? kRed : _timerRunning ? c.color : kMid,
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isUrgent ? 'Hurry Up!' : _timerRunning ? 'Time Remaining' : 'Challenge Timer',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? kRed : kMid,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _remainingSeconds <= 0 ? 'Ended' : _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isUrgent ? kRed : _timerRunning ? c.color : kDark,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ]),
              const Spacer(),

              GestureDetector(
                onTap: _toggleTimer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _timerRunning
                        ? c.color
                        : isUrgent
                        ? kRed
                        : kPrimary,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(
                        color: (_timerRunning ? c.color : kPrimary).withOpacity(0.35),
                        blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Icon(
                    _timerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: kDark,
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _timerRunning = false;
                    _remainingSeconds = c.timerSeconds;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: kMid, size: 17),
                ),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              Icon(Icons.volume_up_rounded, size: 11,
                  color: _timerRunning ? c.color : kMid),
              const SizedBox(width: 4),
              Text(
                _timerRunning
                    ? 'Haptic ticks every 10s • Alert on finish'
                    : 'Tap ▶ to start — haptic + sound alerts enabled',
                style: TextStyle(
                  fontSize: 9,
                  color: _timerRunning ? c.color : kMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Progress: ${c.current}/${c.total}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: c.completed ? kPrimaryDark : c.color)),
              const Spacer(),
              Text('${(c.progress * 100).round()}%',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                      color: c.completed ? kPrimaryDark : c.color)),
            ]),
            const SizedBox(height: 8),
            Stack(children: [
              Container(height: 10, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(6))),
              FractionallySizedBox(
                widthFactor: c.progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: c.completed ? kPrimary : c.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        Container(height: 1, color: kBorder, margin: const EdgeInsets.symmetric(horizontal: 16)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: kPrimaryPale, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.card_giftcard_rounded, size: 13, color: kPrimaryDark),
                const SizedBox(width: 5),
                Text(c.reward,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimaryDeep)),
              ]),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.access_time_rounded, size: 11, color: c.completed ? kGreen : kMid),
                const SizedBox(width: 4),
                Text(c.deadline,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: c.completed ? kGreen : kMid)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  bool _isLoading = true;
  String _referralCode = 'MRCOACH2025';
  int _invited = 0;
  int _joined = 0;
  int _earned = 0;
  int _pending = 0;
  List<dynamic> _history = [];
  String _shareLink = '';

  @override
  void initState() {
    super.initState();
    _fetchReferralData();
  }

  Future<void> _fetchReferralData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final dashboard = await ApiService.getReferralDashboard();
      if (dashboard != null) {
        _referralCode = dashboard['code'] ?? 'MRCOACH2025';
        _invited = dashboard['invited'] ?? 0;
        _joined = dashboard['joined'] ?? 0;
        _earned = dashboard['earned'] ?? 0;
        _pending = dashboard['pending'] ?? 0;
      }

      final history = await ApiService.getReferralHistory();
      _history = history;

      final link = await ApiService.getReferralShareLink();
      if (link != null) {
        _shareLink = link;
      } else {
        _shareLink = 'https://mrcoach.in/signup?ref=$_referralCode';
      }
    } catch (e) {
      print('Error fetching referral data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: kPrimary,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
                        left: 20, right: 20, bottom: 32),
                    child: Column(children: [
                      Row(children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(13)),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: kDark, size: 16),
                          ),
                        ),
                        const Spacer(),
                        const Text('Refer & Earn',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kDark)),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ]),
                      const SizedBox(height: 28),
                      Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                              color: kPrimaryDark.withOpacity(0.3),
                              blurRadius: 24, offset: const Offset(0, 8))],
                        ),
                        child: const Center(child: Icon(Icons.card_giftcard_rounded, size: 42, color: kPrimaryDark)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Invite. Earn. Repeat!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kDark)),
                      const SizedBox(height: 8),
                      Text('Get ₹200 for every friend who books\ntheir first MrCoach session',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: kDark.withOpacity(0.65), height: 1.5)),
                      const SizedBox(height: 24),
                      Row(children: [
                        _RefStat(value: '$_invited', label: 'Invited', icon: Icons.people_alt_rounded),
                        const SizedBox(width: 10),
                        _RefStat(value: '$_joined', label: 'Joined', icon: Icons.how_to_reg_rounded),
                        const SizedBox(width: 10),
                        _RefStat(value: '₹$_earned', label: 'Earned', icon: Icons.account_balance_wallet_rounded),
                      ]),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: kBorder),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: Column(children: [
                        Text('Your Referral Code',
                            style: TextStyle(fontSize: 12, color: kDark.withOpacity(0.55), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: kPrimaryPale,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: kPrimary, width: 2),
                              ),
                              child: Center(child: Text(_referralCode,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kPrimaryDeep, letterSpacing: 3))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: _referralCode));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Code copied!', style: TextStyle(color: kDark, fontWeight: FontWeight.w700)),
                                backgroundColor: kPrimary,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ));
                            },
                            child: Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.copy_rounded, size: 22, color: kDark),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final text = 'Hey! Use my referral code $_referralCode to sign up on MrCoach and get rewards! Register here: $_shareLink';
                              Share.share(text);
                            },
                            icon: const Icon(Icons.share_rounded, size: 18, color: kDark),
                            label: const Text('Share & Invite Friends',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: OutlinedButton.icon(
                            onPressed: () async {
                              final text = 'Hey! Use my referral code $_referralCode to sign up on MrCoach and get rewards! Register here: $_shareLink';
                              final whatsappUrl = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');
                              if (await canLaunchUrl(whatsappUrl)) {
                                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                              } else {
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Could not open WhatsApp. Link copied to clipboard!', style: TextStyle(color: kDark, fontWeight: FontWeight.w700)),
                                  backgroundColor: kPrimary,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            },
                            icon: const Icon(Icons.chat_rounded, size: 15, color: kGreen),
                            label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDark)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: kBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _shareLink));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Referral link copied!', style: TextStyle(color: kDark, fontWeight: FontWeight.w700)),
                                backgroundColor: kPrimary,
                                behavior: SnackBarBehavior.floating,
                              ));
                            },
                            icon: const Icon(Icons.link_rounded, size: 15, color: kBlue),
                            label: const Text('Copy Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDark)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: kBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          )),
                        ]),
                      ]),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: kPrimaryDark),
                        SizedBox(width: 8),
                        Text('How it works',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDark)),
                      ]),
                      const SizedBox(height: 14),
                      ...[
                        ['1', 'Share your code', 'Send your code to friends via WhatsApp, Instagram, or any platform.'],
                        ['2', 'Friend signs up', 'They download MrCoach and create an account using your code.'],
                        ['3', 'They book first session', 'When they complete their first paid booking, you both earn ₹200!'],
                      ].map((step) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: kCard, borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: kBorder),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))]),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                            child: Center(child: Text(step[0],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kDark))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(step[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDark)),
                            const SizedBox(height: 3),
                            Text(step[2], style: const TextStyle(fontSize: 11, color: kMid, height: 1.4)),
                          ])),
                        ]),
                      )),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.history_rounded, size: 16, color: kPrimaryDark),
                        SizedBox(width: 8),
                        Text('Referral History',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDark)),
                      ]),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                            color: kCard, borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kBorder),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))]),
                        child: _history.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                                child: Center(
                                  child: Text(
                                    'No referral history yet.',
                                    style: TextStyle(color: kMid, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                            : Column(
                                children: _history.asMap().entries.map((entry) {
                                  final r = entry.value;
                                  final referredUser = r['referredUser'] ?? {};
                                  final userName = referredUser['name'] ?? 'Friend';
                                  final isRewarded = r['status']?.toString().toUpperCase() == 'REWARDED';
                                  final amount = '₹${r['rewardAmount'] ?? 200}';
                                  final isLast = entry.key == _history.length - 1;
                                  return Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(children: [
                                        Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            color: isRewarded ? kPrimaryPale : kOrangePale,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'F',
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                                                  color: isRewarded ? kPrimaryDark : kOrange))),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDark)),
                                          const SizedBox(height: 2),
                                          Text(_formatDate(r['createdAt']), style: const TextStyle(fontSize: 11, color: kMid)),
                                        ])),
                                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                          Text(amount,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                                                  color: isRewarded ? kPrimaryDark : kOrange)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: isRewarded ? kPrimaryPale : kOrangePale,
                                                borderRadius: BorderRadius.circular(6)),
                                            child: Text(isRewarded ? 'Earned' : 'Pending',
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                                                    color: isRewarded ? kPrimaryDark : kOrange)),
                                          ),
                                        ]),
                                      ]),
                                    ),
                                    if (!isLast) Container(height: 1, color: kBorder, margin: const EdgeInsets.only(left: 72)),
                                  ]);
                                }).toList(),
                              ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RefStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _RefStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: kPrimaryDark.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        Icon(icon, size: 22, color: kPrimaryDark),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: kMid)),
      ]),
    ),
  );
}



class ScratchRewards1Page extends StatefulWidget {
  const ScratchRewards1Page({super.key});
  @override
  State<ScratchRewards1Page> createState() => _ScratchRewards1PageState();
}

class _ScratchRewards1PageState extends State<ScratchRewards1Page>
    with SingleTickerProviderStateMixin {
  late final List<ScratchCardModel> _cards;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _cards = kScratchCards.map((c) => ScratchCardModel(
      id: c.id, reward: c.reward, subReward: c.subReward,
      condition: c.condition, earnedFrom: c.earnedFrom,
      expiry: c.expiry, theme: c.theme, expired: c.expired,
      scratched: c.scratched, claimed: c.claimed,
    )).toList();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  int get _available => _cards.where((c) => !c.scratched && !c.expired).length;
  int get _scratched  => _cards.where((c) => c.scratched).length;

  void _onCardScratched(int index) {
    if (_cards[index].scratched) return;
    setState(() => _cards[index].scratched = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _RewardRevealDialog(
          card: _cards[index],
          onClaim: () {
            setState(() => _cards[index].claimed = true);
            Navigator.pop(context);
            _showClaimedSnack(_cards[index]);
          },
          onLater: () => Navigator.pop(context),
        ),
      );
    });
  }

  void _showClaimedSnack(ScratchCardModel c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: kDark, size: 18),
        const SizedBox(width: 8),
        Text('${c.reward} ${c.subReward} claimed! 🎉',
            style: const TextStyle(fontWeight: FontWeight.w800, color: kDark)),
      ]),
      backgroundColor: kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _StatsRow(
                  total: _cards.length,
                  available: _available,
                  scratched: _scratched,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(children: [
                  Container(width: 4, height: 16,
                      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  const Text('Your Scratch Cards',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kDark)),
                  const Spacer(),
                  if (_available > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(20)),
                      child: Text('$_available New',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kDark)),
                    ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                      (_, i) => _RealScratchCard(
                    key: ValueKey(_cards[i].id),
                    card: _cards[i],
                    onScratched: () => _onCardScratched(i),
                  ),
                  childCount: _cards.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                child: _HowToEarnCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: _TermsCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD966), kPrimary, Color(0xFFE0AC00)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 28,
      ),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: kDark, size: 16),
            ),
          ),
          const Spacer(),
          const Column(children: [
            Text('Scratch & Win',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
            SizedBox(height: 2),
            Text('MrCoach Rewards',
                style: TextStyle(fontSize: 11, color: kDark, fontWeight: FontWeight.w500)),
          ]),
          const Spacer(),
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.history_rounded, color: kDark, size: 20),
          ),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.touch_app_rounded, size: 20, color: kDark),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Swipe to Scratch!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kDark)),
                Text('$_available card${_available == 1 ? '' : 's'} waiting for you',
                    style: TextStyle(fontSize: 11, color: kDark.withOpacity(0.7))),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: kDark, borderRadius: BorderRadius.circular(12)),
              child: const Text('Scratch\nNow', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kPrimary, height: 1.3)),
            ),
          ]),
        ),
      ]),
    );
  }
}


class _RealScratchCard extends StatefulWidget {
  final ScratchCardModel card;
  final VoidCallback onScratched;
  const _RealScratchCard({super.key, required this.card, required this.onScratched});

  @override
  State<_RealScratchCard> createState() => _RealScratchCardState();
}

class _RealScratchCardState extends State<_RealScratchCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScratcherState> _scratchKey = GlobalKey();
  bool _triggered = false;

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _glowCtrl.dispose(); super.dispose(); }

  void _handleThreshold() {
    if (_triggered) return;
    _triggered = true;
    HapticFeedback.mediumImpact();
    widget.onScratched();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    if (c.expired) return _ExpiredCard(card: c);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: c.theme.accent.withOpacity(
                  c.scratched ? 0.15 : 0.2 + _glowAnim.value * 0.2),
              blurRadius: c.scratched ? 12 : 16 + _glowAnim.value * 10,
              offset: const Offset(0, 5),
            ),
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            _RewardContent(card: c),
            if (!c.scratched)
              Scratcher(
                key: _scratchKey,
                brushSize: 44,
                threshold: 45,
                accuracy: ScratchAccuracy.low,
                color: c.theme.foilColor,
                onThreshold: _handleThreshold,
                child: _FoilLayer(theme: c.theme, earnedFrom: c.earnedFrom),
              ),
            if (c.scratched && c.claimed)
              Positioned(top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_rounded, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text('CLAIMED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
                  ]),
                ),
              ),
            if (c.scratched && !c.claimed)
              Positioned(top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(8)),
                  child: const Text('TAP TO CLAIM',
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: kDark)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _FoilLayer extends StatefulWidget {
  final ScratchTheme theme;
  final String earnedFrom;
  const _FoilLayer({required this.theme, required this.earnedFrom});

  @override
  State<_FoilLayer> createState() => _FoilLayerState();
}

class _FoilLayerState extends State<_FoilLayer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _shimmerAnim = _shimmerCtrl;
  }

  @override
  void dispose() { _shimmerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _shimmerAnim,
    builder: (_, __) => Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.theme.gradient,
        ),
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _CoinPatternPainter(theme: widget.theme))),
        Positioned.fill(child: CustomPaint(painter: _ShimmerPainter(shimmer: _shimmerAnim.value))),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: const Center(child: Text('MC',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: 0.5))),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.touch_app_rounded, size: 13, color: Colors.white),
                SizedBox(width: 5),
                Text('Scratch here',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(widget.earnedFrom,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kDark)),
            ),
          ]),
        ),
      ]),
    ),
  );
}

class _RewardContent extends StatelessWidget {
  final ScratchCardModel card;
  const _RewardContent({required this.card});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    width: double.infinity,
    height: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: card.theme.gradient),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
                color: card.theme.accent.withOpacity(0.35),
                blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: const Center(child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28)),
        ),
        const SizedBox(height: 10),
        Text(
          card.reward,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
              color: card.theme.accent, letterSpacing: -1),
        ),
        Text(
          card.subReward,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kMid),
        ),
        const SizedBox(height: 6),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: kBg, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder)),
          child: Text(card.condition, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: kMid, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: card.theme.gradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
                color: card.theme.accent.withOpacity(0.35),
                blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: const Text('CLAIM NOW',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
        const SizedBox(height: 6),
        Text(
          card.expiry,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, color: kMid),
        ),
      ],
    ),
  );
}

class _ShimmerPainter extends CustomPainter {
  final double shimmer;
  const _ShimmerPainter({required this.shimmer});

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width * 0.5 + size.width * 2.0 * shimmer;
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.18),
        Colors.white.withOpacity(0.38),
        Colors.white.withOpacity(0.18),
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0, 0.3, 0.45, 0.5, 0.55, 0.7, 1],
    ).createShader(Rect.fromLTWH(x, 0, size.width * 2, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.shimmer != shimmer;
}

class _CoinPatternPainter extends CustomPainter {
  final ScratchTheme theme;
  const _CoinPatternPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(theme.index * 100 + 42);
    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final coins = [
      Offset(size.width * 0.08, size.height * 0.12),
      Offset(size.width * 0.85, size.height * 0.08),
      Offset(size.width * 0.92, size.height * 0.72),
      Offset(size.width * 0.05, size.height * 0.78),
      Offset(size.width * 0.50, size.height * 0.05),
      Offset(size.width * 0.55, size.height * 0.92),
    ];
    for (final pos in coins) {
      final r = 8.0 + rng.nextDouble() * 6;
      canvas.drawCircle(pos, r + 3, strokePaint);
      canvas.drawCircle(pos, r, fillPaint);
    }

    for (final pos in [
      Offset(size.width * 0.18, size.height * 0.20),
      Offset(size.width * 0.72, size.height * 0.30),
      Offset(size.width * 0.15, size.height * 0.65),
      Offset(size.width * 0.78, size.height * 0.68),
    ]) {
      final tp = TextPainter(
        text: TextSpan(text: '₹',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.12))),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double x = -size.height; x < size.width + size.height; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), linePaint);
    }

    final mcPainter = TextPainter(
      text: TextSpan(text: 'MC', style: TextStyle(
          fontSize: size.width * 0.5, fontWeight: FontWeight.w900,
          color: Colors.white.withOpacity(0.05), letterSpacing: 4)),
      textDirection: TextDirection.ltr,
    )..layout();
    mcPainter.paint(canvas, Offset(
        (size.width - mcPainter.width) / 2, (size.height - mcPainter.height) / 2));
  }

  @override
  bool shouldRepaint(_CoinPatternPainter old) => false;
}

class _ExpiredCard extends StatelessWidget {
  final ScratchCardModel card;
  const _ExpiredCard({required this.card});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: const Color(0xFFF0EEE8), borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 52, height: 52,
        decoration: const BoxDecoration(color: kBorder, shape: BoxShape.circle),
        child: const Icon(Icons.timer_off_rounded, size: 26, color: kMid),
      ),
      const SizedBox(height: 10),
      const Text('Expired',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: kMid)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: kBorder.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
        child: Text(card.expiry,
            style: const TextStyle(fontSize: 9, color: kMid, fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 8),
      Text(card.reward, style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w900,
          color: kMid.withOpacity(0.4), decoration: TextDecoration.lineThrough)),
    ]),
  );
}


class _RewardRevealDialog extends StatefulWidget {
  final ScratchCardModel card;
  final VoidCallback onClaim;
  final VoidCallback onLater;
  const _RewardRevealDialog({required this.card, required this.onClaim, required this.onLater});

  @override
  State<_RewardRevealDialog> createState() => _RewardRevealDialogState();
}

class _RewardRevealDialogState extends State<_RewardRevealDialog>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl, _confettiCtrl, _pulseCtrl;
  late Animation<double> _scaleAnim, _slideAnim, _pulseAnim;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 24; i++) {
      _particles.add(_ConfettiParticle(
        x: _rng.nextDouble(), delay: _rng.nextDouble() * 0.4,
        speed: 0.4 + _rng.nextDouble() * 0.6,
        size: 5.0 + _rng.nextDouble() * 6,
        rotation: _rng.nextDouble() * math.pi * 2,
        color: [kPrimary, kGreen, const Color(0xFF4B8EF1), kOrange,
          Colors.white, const Color(0xFFFF6B9D)][_rng.nextInt(6)],
      ));
    }
    _entryCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..forward();
    _pulseCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _scaleAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _slideAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _entryCtrl.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _entryCtrl.dispose(); _confettiCtrl.dispose(); _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnim, _confettiCtrl, _pulseAnim]),
      builder: (_, __) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(child: IgnorePointer(child: CustomPaint(
            painter: _ConfettiPainter(particles: _particles, progress: _confettiCtrl.value),
          ))),
          Transform.scale(
            scale: _scaleAnim.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: c.theme.accent.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 12)),
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: c.theme.gradient),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Transform.scale(
                      scale: 1.0 + _pulseAnim.value * 0.06,
                      child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: c.theme.gradient),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                              color: c.theme.accent.withOpacity(0.4 + _pulseAnim.value * 0.2),
                              blurRadius: 20 + _pulseAnim.value * 10, spreadRadius: 2)],
                        ),
                        child: const Center(child: Icon(Icons.emoji_events_rounded, size: 46, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_slideAnim),
                      child: FadeTransition(
                        opacity: _slideAnim,
                        child: Column(children: [
                          const Text("You've Won! 🎉",
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kDark, letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Text('Earned from: ${c.earnedFrom}',
                              style: const TextStyle(fontSize: 12, color: kMid)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_slideAnim),
                      child: FadeTransition(
                        opacity: _slideAnim,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                                colors: c.theme.gradient.map((col) => col.withOpacity(0.12)).toList()),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.theme.accent.withOpacity(0.3), width: 2),
                          ),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(c.reward, style: TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.w900,
                                  color: c.theme.accent, letterSpacing: -2)),
                              const SizedBox(width: 10),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c.subReward, style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900, color: c.theme.accent)),
                                Text(c.condition, style: const TextStyle(fontSize: 11, color: kMid)),
                              ]),
                            ]),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Text(c.expiry,
                                  style: const TextStyle(fontSize: 10, color: kMid, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_slideAnim),
                      child: FadeTransition(
                        opacity: _slideAnim,
                        child: Column(children: [
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: widget.onClaim,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 17),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: c.theme.gradient),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [BoxShadow(
                                      color: c.theme.accent.withOpacity(0.4),
                                      blurRadius: 16, offset: const Offset(0, 6))],
                                ),
                                child: const Center(child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.redeem_rounded, size: 20, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Claim Reward',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ],
                                )),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: widget.onLater,
                            child: const Text('Claim Later',
                                style: TextStyle(fontSize: 13, color: kMid, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ConfettiParticle {
  final double x, delay, speed, size, rotation;
  final Color color;
  const _ConfettiParticle({required this.x, required this.delay, required this.speed,
    required this.size, required this.rotation, required this.color});
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (int idx = 0; idx < particles.length; idx++) {
      final p = particles[idx];
      final t = ((progress - p.delay) * p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x = p.x * size.width;
      final y = -20.0 + t * (size.height + 80);
      final rot = p.rotation + t * math.pi * 5;
      final opacity = t < 0.8 ? 1.0 : (1.0 - t) / 0.2;
      final paint = Paint()..color = p.color.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      if (idx % 2 == 0) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
                const Radius.circular(1.5)),
            paint);
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _StatsRow extends StatelessWidget {
  final int total, available, scratched;
  const _StatsRow({required this.total, required this.available, required this.scratched});

  @override
  Widget build(BuildContext context) => Row(children: [
    _StatPill(icon: Icons.style_rounded, label: 'Total', value: '$total', color: kPrimaryDark, pale: kPrimaryPale),
    const SizedBox(width: 10),
    _StatPill(icon: Icons.redeem_rounded, label: 'Available', value: '$available', color: kGreen, pale: kGreenPale),
    const SizedBox(width: 10),
    _StatPill(icon: Icons.done_all_rounded, label: 'Scratched', value: '$scratched', color: const Color(0xFF4B8EF1), pale: kBluePale),
  ]);
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color, pale;
  const _StatPill({required this.icon, required this.label,
    required this.value, required this.color, required this.pale});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: pale, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 7),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: kMid, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

class _HowToEarnCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      [Icons.check_circle_outline_rounded, kGreen, kGreenPale, 'Complete a session', '+1 Card'],
      [Icons.emoji_events_rounded, kOrange, kOrangePale, 'Complete a challenge', '+2 Cards'],
      [Icons.group_add_rounded, const Color(0xFF4B8EF1), kBluePale, 'Successful referral', '+1 Card'],
      [Icons.star_rounded, kPrimary, kPrimaryPale, 'Give 5-star review', '+1 Card'],
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.info_outline_rounded, size: 16, color: kPrimaryDark),
          SizedBox(width: 8),
          Text('How to earn more cards',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kDark)),
        ]),
        const SizedBox(height: 16),
        ...items.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: r[2] as Color, shape: BoxShape.circle),
              child: Icon(r[0] as IconData, color: r[1] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(r[3] as String,
                style: const TextStyle(fontSize: 13, color: kDark, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(8)),
              child: Text(r[4] as String,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kDark)),
            ),
          ]),
        )),
      ]),
    );
  }
}

class _TermsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kPrimaryPale, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kPrimary.withOpacity(0.3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.gavel_rounded, size: 14, color: kPrimaryDark),
        SizedBox(width: 6),
        Text('Terms & Conditions',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kPrimaryDeep)),
      ]),
      const SizedBox(height: 8),
      ...[
        '• Rewards are valid only within the expiry date shown on each card.',
        '• Each reward can be claimed once and is non-transferable.',
        '• Cashback is credited to your MrCoach wallet within 24 hours.',
        '• MrCoach reserves the right to modify or withdraw rewards without notice.',
      ].map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(t, style: const TextStyle(fontSize: 10, color: kPrimaryDeep, height: 1.5)),
      )),
    ]),
  );
}


class _OrderCard extends StatelessWidget {
  final CoachingOrder order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: order.status.pale, borderRadius: BorderRadius.circular(15)),
              child: Center(child: Text(order.coachInitials,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: order.status.color))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(order.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                _Badge(status: order.status),
              ]),
              const SizedBox(height: 3),
              Text(order.coach, style: const TextStyle(fontSize: 12, color: kMid)),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: kPrimaryPale, borderRadius: BorderRadius.circular(6)),
                child: Text(order.category,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kPrimaryDeep, letterSpacing: 0.5)),
              ),
            ])),
          ]),
        ),
        Container(height: 1, color: kBorder, margin: const EdgeInsets.symmetric(horizontal: 16)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(children: [
            _MetaChip(icon: Icons.calendar_today_rounded, label: order.date),
            const SizedBox(width: 10),
            _MetaChip(icon: Icons.access_time_rounded, label: order.time),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${order.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kDark)),
              const Text('paid', style: TextStyle(fontSize: 9, color: kMid)),
            ]),
          ]),
        ),
        if (order.status == OrderStatus.inProgress) ...[
          Container(height: 1, color: kBorder),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(
              color: kPrimaryPale,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: Column(children: [
              Row(children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Live session in progress!',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
                const Spacer(),
                const Text('60%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kMid)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: kBorder,
                  valueColor: AlwaysStoppedAnimation(kPrimary),
                  minHeight: 7,
                ),
              ),
            ]),
          ),
        ],
      ]),
    ),
  );
}


class _OrderDetailSheet extends StatelessWidget {
  final CoachingOrder order;
  const _OrderDetailSheet({required this.order});

  static const _steps = [
    OrderStatus.pending, OrderStatus.confirmed,
    OrderStatus.inProgress, OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          Center(child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            width: 40, height: 4,
            decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)),
          )),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#${order.id}',
                  style: const TextStyle(fontSize: 11, color: kMid, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(order.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark)),
            ])),
            const SizedBox(width: 12),
            _Badge(status: order.status, large: true),
          ]),
          const SizedBox(height: 4),
          Text('${order.coach} · ${order.category}',
              style: const TextStyle(fontSize: 13, color: kMid)),
          const SizedBox(height: 22),
          if (order.status != OrderStatus.cancelled) ...[
            const Text('Order Progress',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDark)),
            const SizedBox(height: 16),
            _Tracker(status: order.status, steps: _steps),
            const SizedBox(height: 24),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kRedPale, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: kRed.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.cancel_outlined, color: kRed, size: 20)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Booking Cancelled',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kRed)),
                  SizedBox(height: 2),
                  Text('This session was cancelled', style: TextStyle(fontSize: 12, color: kMid)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Session Details',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDark)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              _Detail(icon: Icons.person_outline_rounded, label: 'Coach', value: order.coach),
              _Detail(icon: Icons.fitness_center_rounded, label: 'Category', value: order.category),
              _Detail(icon: Icons.calendar_today_rounded, label: 'Date', value: order.date),
              _Detail(icon: Icons.access_time_rounded, label: 'Time', value: order.time),
              _Detail(icon: Icons.location_on_outlined, label: 'Venue', value: order.venue),
              _Detail(icon: Icons.currency_rupee_rounded, label: 'Amount',
                  value: '₹${order.amount.toStringAsFixed(0)}',
                  valueColor: kGreen, isLast: order.note == null),
              if (order.note != null)
                _Detail(icon: Icons.notes_rounded, label: 'Note', value: order.note!, isLast: true),
            ]),
          ),
          const SizedBox(height: 24),
          if (order.status == OrderStatus.completed)
            _PrimaryBtn(icon: Icons.refresh_rounded, label: 'Book Again',
                onTap: () => Navigator.pop(context)),
          if (order.status == OrderStatus.inProgress)
            _PrimaryBtn(icon: Icons.videocam_rounded, label: 'Join Live Session',
                onTap: () => Navigator.pop(context)),
          if (order.status == OrderStatus.confirmed || order.status == OrderStatus.pending) ...[
            _PrimaryBtn(icon: Icons.support_agent_rounded, label: 'Contact Coach',
                onTap: () => Navigator.pop(context)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel_outlined, size: 17, color: kRed),
                label: const Text('Cancel Booking',
                    style: TextStyle(color: kRed, fontWeight: FontWeight.w700, fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: kRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
          if (order.status == OrderStatus.cancelled)
            _PrimaryBtn(icon: Icons.refresh_rounded, label: 'Rebook This Session',
                onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}



class _Tracker extends StatelessWidget {
  final OrderStatus status;
  final List<OrderStatus> steps;
  const _Tracker({required this.status, required this.steps});

  @override
  Widget build(BuildContext context) {
    final cur = steps.indexOf(status);
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final filled = (i ~/ 2) < cur;
          return Expanded(child: Container(
              height: 4,
              decoration: BoxDecoration(
                  color: filled ? kPrimary : kBorder,
                  borderRadius: BorderRadius.circular(2))));
        }
        final si = i ~/ 2;
        final done = si < cur;
        final active = si == cur;
        return Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: active ? 38 : 30, height: active ? 38 : 30,
            decoration: BoxDecoration(
              color: done ? kPrimary : active ? kPrimary : kBorder,
              shape: BoxShape.circle,
              boxShadow: active ? [BoxShadow(
                  color: kPrimary.withOpacity(0.5), blurRadius: 14, spreadRadius: 2)] : [],
            ),
            child: Icon(done ? Icons.check_rounded : steps[si].icon,
                size: active ? 18 : 14, color: done ? kDark : active ? kDark : kMid),
          ),
          const SizedBox(height: 8),
          Text(steps[si].label, style: TextStyle(
            fontSize: 9, letterSpacing: 0.2,
            fontWeight: active || done ? FontWeight.w800 : FontWeight.w500,
            color: active ? kPrimaryDark : done ? kDark : kMid,
          )),
        ]);
      }),
    );
  }
}


class _Badge extends StatelessWidget {
  final OrderStatus status;
  final bool large;
  const _Badge({required this.status, this.large = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 9, vertical: large ? 7 : 4),
    decoration: BoxDecoration(color: status.pale, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(status.icon, size: large ? 11 : 9, color: status.color),
      SizedBox(width: large ? 5 : 3),
      Text(status.label, style: TextStyle(
          fontSize: large ? 11 : 9, fontWeight: FontWeight.w800, color: status.color)),
    ]),
  );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: kMid),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: kMid, fontWeight: FontWeight.w500)),
  ]);
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  final bool isLast;
  const _Detail({required this.icon, required this.label, required this.value,
    this.valueColor, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Icon(icon, size: 16, color: kPrimaryDark),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: kMid)),
        const Spacer(),
        Flexible(child: Text(value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? kDark))),
      ]),
    ),
    if (!isLast) Container(height: 1, color: kBorder),
  ]);
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> tiles;
  final Color? titleColor;
  const _Section({required this.title, required this.icon,
    required this.tiles, this.titleColor});

  List<Widget> _interleave(List<Widget> items) {
    final r = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      r.add(items[i]);
      if (i < items.length - 1)
        r.add(Container(height: 1, color: kBorder, margin: const EdgeInsets.only(left: 66)));
    }
    return r;
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(children: [
        Icon(icon, size: 12, color: titleColor ?? kMid),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w800,
            color: titleColor ?? kMid, letterSpacing: 1.2)),
      ]),
    ),
    Container(
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(children: _interleave(tiles)),
    ),
  ]);
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor, labelColor;
  final String label;
  final String? sub;
  final VoidCallback? onTap;
  final Widget? trail;
  const _Tile({required this.icon, required this.label, this.onTap,
    this.iconColor, this.labelColor, this.sub, this.trail});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap, behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(
                color: (iconColor ?? kPrimaryDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor ?? kPrimaryDark, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: labelColor ?? kDark)),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!, style: const TextStyle(fontSize: 11, color: kMid),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ])),
        if (trail != null) trail!,
      ]),
    ),
  );
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.icon, required this.label,
    required this.value, required this.onChanged, this.sub});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(children: [
      Container(width: 40, height: 40,
          decoration: BoxDecoration(color: kPrimaryPale, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: kPrimaryDark, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDark)),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(sub!, style: const TextStyle(fontSize: 11, color: kMid)),
        ],
      ])),
      CupertinoSwitch(value: value, onChanged: onChanged, activeColor: kPrimary, trackColor: kBorder),
    ]),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: kPrimaryPale, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: const TextStyle(
        fontSize: 11, color: kPrimaryDeep, fontWeight: FontWeight.w800)),
  );
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: kDark, size: 16),
    ),
  );
}

class _PrimaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: kDark),
      label: Text(label, style: const TextStyle(color: kDark, fontWeight: FontWeight.w800, fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 84, height: 84,
          decoration: const BoxDecoration(color: kPrimaryPale, shape: BoxShape.circle),
          child: const Icon(Icons.receipt_long_outlined, size: 38, color: kPrimaryDark)),
      const SizedBox(height: 18),
      const Text('No orders here',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kDark)),
      const SizedBox(height: 6),
      const Text('Try a different filter', style: TextStyle(fontSize: 13, color: kMid)),
    ]),
  );
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: kPrimary, borderRadius: BorderRadius.circular(17),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: const Center(child: Text('MC',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kDark, letterSpacing: 0.5))),
    ),
    const SizedBox(height: 12),
    const Text('MrCoach', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
    const SizedBox(height: 4),
    const Text('Your personal fitness companion', style: TextStyle(fontSize: 11, color: kMid)),
    const SizedBox(height: 8),
    const Text('©2025 MrCoach. All rights reserved.', style: TextStyle(fontSize: 10, color: kMid)),
  ]);
}



class _AvatarSheet extends StatelessWidget {
  final VoidCallback onRemove;
  const _AvatarSheet({required this.onRemove});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(),
        const SizedBox(height: 16),
        const Text('Update Photo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDark)),
        const SizedBox(height: 16),
        _SheetTile(icon: Icons.camera_alt_rounded, label: 'Take Photo',
            onTap: () => Navigator.pop(context, ImageSource.camera)),
        const SizedBox(height: 8),
        _SheetTile(icon: Icons.photo_library_rounded, label: 'Choose from Gallery',
            onTap: () => Navigator.pop(context, ImageSource.gallery)),
        const SizedBox(height: 8),
        _SheetTile(icon: Icons.delete_outline_rounded, label: 'Remove Photo',
            color: kRed, onTap: onRemove),
        const SizedBox(height: 8),
      ]),
    ),
  );
}

class _EditSheet extends StatefulWidget {
  final String name, email, alternatePhone, address, gender, dateOfBirth, serviceType, preferredLanguage, area, pincode, district, stateField, emergencyContact, fitnessGoal;
  final int? age;
  final Function(Map<String, dynamic> updatedData) onSave;

  const _EditSheet({
    required this.name,
    required this.email,
    required this.alternatePhone,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.serviceType,
    required this.preferredLanguage,
    required this.area,
    required this.pincode,
    required this.district,
    required this.stateField,
    required this.emergencyContact,
    required this.fitnessGoal,
    required this.age,
    required this.onSave,
  });

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _goalCtrl;

  late String _selectedGender;
  late String _selectedServiceType;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _emailCtrl = TextEditingController(text: widget.email);
    _phoneCtrl = TextEditingController(text: widget.alternatePhone);
    _ageCtrl = TextEditingController(text: widget.age?.toString() ?? '');
    _dobCtrl = TextEditingController(text: widget.dateOfBirth);
    _areaCtrl = TextEditingController(text: widget.area);
    _pincodeCtrl = TextEditingController(text: widget.pincode);
    _districtCtrl = TextEditingController(text: widget.district);
    _stateCtrl = TextEditingController(text: widget.stateField);
    _addressCtrl = TextEditingController(text: widget.address);
    _emergencyCtrl = TextEditingController(text: widget.emergencyContact);
    _goalCtrl = TextEditingController(text: widget.fitnessGoal);

    _selectedGender = widget.gender.isNotEmpty ? widget.gender : 'Male';
    _selectedServiceType = widget.serviceType.isNotEmpty ? widget.serviceType : 'Online';
    _selectedLanguage = widget.preferredLanguage.isNotEmpty ? widget.preferredLanguage : 'English';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _dobCtrl.dispose();
    _areaCtrl.dispose();
    _pincodeCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimary,
              onPrimary: kDark,
              onSurface: kDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        // Calculate age automatically
        final now = DateTime.now();
        int age = now.year - picked.year;
        if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        _ageCtrl.text = age.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const SizedBox(height: 14),
            _Handle(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.translate('edit_profile'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: kMid),
                  ),
                ],
              ),
            ),
            const Divider(color: kBorder),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Basic Details'),
                    _Field(ctrl: _nameCtrl, label: 'Full Name', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Gender',
                            value: _selectedGender,
                            items: ['Male', 'Female', 'Other'],
                            onChanged: (val) => setState(() => _selectedGender = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Field(
                            ctrl: _ageCtrl,
                            label: 'Age',
                            icon: Icons.cake_outlined,
                            type: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: _Field(
                          ctrl: _dobCtrl,
                          label: 'Date of Birth (DD/MM/YYYY)',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    _buildSectionHeader('Contact & Language'),
                    _buildDropdown(
                      label: 'Preferred Language',
                      value: _selectedLanguage,
                      items: ['English', 'Tamil', 'Hindi'],
                      onChanged: (val) => setState(() => _selectedLanguage = val!),
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      ctrl: _phoneCtrl,
                      label: 'Alternate Phone',
                      icon: Icons.phone_android_outlined,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      ctrl: _emergencyCtrl,
                      label: 'Emergency Contact',
                      icon: Icons.contact_phone_outlined,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      ctrl: _emailCtrl,
                      label: 'Email Address',
                      icon: Icons.mail_outline_rounded,
                      type: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader('Service Preference'),
                    _buildDropdown(
                      label: 'Service Type',
                      value: _selectedServiceType,
                      items: ['Online', 'Home Visit', 'Hybrid'],
                      onChanged: (val) => setState(() => _selectedServiceType = val!),
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      ctrl: _goalCtrl,
                      label: 'Fitness Goal',
                      icon: Icons.emoji_events_outlined,
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader('Location Details'),
                    Row(
                      children: [
                        Expanded(
                          child: _Field(ctrl: _areaCtrl, label: 'Area', icon: Icons.location_on_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Field(
                            ctrl: _pincodeCtrl,
                            label: 'Pincode',
                            icon: Icons.pin_drop_outlined,
                            type: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _Field(ctrl: _districtCtrl, label: 'District', icon: Icons.map_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Field(ctrl: _stateCtrl, label: 'State', icon: Icons.explore_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      ctrl: _addressCtrl,
                      label: 'Detailed Address',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: kBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        AppLocalizations.translate('cancel'),
                        style: const TextStyle(color: kMid, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final data = {
                          'name': _nameCtrl.text.trim(),
                          'email': _emailCtrl.text.trim(),
                          'alternatePhone': _phoneCtrl.text.trim(),
                          'age': int.tryParse(_ageCtrl.text.trim()),
                          'dateOfBirth': _dobCtrl.text.trim(),
                          'gender': _selectedGender,
                          'preferredLanguage': _selectedLanguage,
                          'serviceType': _selectedServiceType,
                          'emergencyContact': _emergencyCtrl.text.trim(),
                          'fitnessGoal': _goalCtrl.text.trim(),
                          'area': _areaCtrl.text.trim(),
                          'pincode': _pincodeCtrl.text.trim(),
                          'district': _districtCtrl.text.trim(),
                          'state': _stateCtrl.text.trim(),
                          'address': _addressCtrl.text.trim(),
                        };
                        widget.onSave(data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.translate('save_changes'),
                        style: const TextStyle(color: kDark, fontWeight: FontWeight.w800, fontSize: 14),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kPrimaryDark, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((i) => DropdownMenuItem(
          value: i,
          child: Text(i, style: const TextStyle(fontSize: 14, color: kDark, fontWeight: FontWeight.w600)),
        )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: kMid),
          border: InputBorder.none,
          floatingLabelStyle: const TextStyle(fontSize: 11, color: kPrimaryDark),
        ),
        dropdownColor: Colors.white,
        iconEnabledColor: kPrimaryDark,
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title, msg, btnLabel;
  final Color btnColor, btnText;
  final IconData icon;
  final VoidCallback onConfirm;
  const _ConfirmDialog({required this.title, required this.msg,
    required this.btnLabel, required this.btnColor, required this.btnText,
    required this.icon, required this.onConfirm});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: kCard,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 64, height: 64,
            decoration: BoxDecoration(color: btnColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: btnColor, size: 30)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kDark)),
        const SizedBox(height: 8),
        Text(msg, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: kMid, height: 1.5)),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel', style: TextStyle(color: kMid, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(btnLabel,
                  style: TextStyle(color: btnText, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ]),
      ]),
    ),
  );
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SheetTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? kDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: c == kRed ? kRedPale : kPrimaryPale,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final int maxLines;
  const _Field({required this.ctrl, required this.label, required this.icon, this.type, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
    child: TextField(
      controller: ctrl, keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: kDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: kMid),
        prefixIcon: Icon(icon, color: kPrimaryDark, size: 18),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        floatingLabelStyle: const TextStyle(fontSize: 11, color: kPrimaryDark),
      ),
    ),
  );
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 40, height: 4,
    decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)),
  );
}