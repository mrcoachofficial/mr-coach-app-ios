import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:flutter/gestures.dart';
import 'package:mrcoach/profile_settings_pages/legal_screens.dart';

// ── Colour Palette ─────────────────────────────────────────────────────────────
const Color kBtnYellow   = Color(0xFFFFD800);
const Color kTopBg       = Color(0xFFFFF8C5);
const Color kBottomBg    = Color(0xFFFFFFFF);
const Color kCardBg      = Color(0xFFFFFFFF);
const Color kSliderCardBg= Color(0xFFFFF3B0);
const Color kDark        = Color(0xFF1A1A2E);
const Color kText        = Color(0xFF1A1A2E);
const Color kSubText     = Color(0xFF6B6B8A);
const Color kInputBg     = Color(0xFFF5F5F5);
const Color kBorder      = Color(0xFFE0E0E0);

// ── Testimonials ───────────────────────────────────────────────────────────────
class Testimonial {
  final String name, role, quote;
  final IconData icon;
  const Testimonial({required this.name, required this.role, required this.quote, required this.icon});
}

const List<Testimonial> _testimonials = [
  Testimonial(name: 'Prashanthi Reddy', role: 'Home Maker',      quote: 'MrCoach transformed my daily routine. Feeling healthier than ever!', icon: Icons.self_improvement),
  Testimonial(name: 'Arjun Krishnan',   role: 'Software Engineer',quote: 'Best fitness investment I made. Coaches are world-class!',            icon: Icons.fitness_center),
  Testimonial(name: 'Divya Menon',      role: 'Entrepreneur',     quote: 'Lost 12 kg in 3 months with personalised plans. Love MrCoach!',       icon: Icons.emoji_events),
  Testimonial(name: 'Rahul Sharma',     role: 'Student',          quote: 'Affordable, flexible and super effective. Perfect for me!',            icon: Icons.sports_gymnastics),
  Testimonial(name: 'Kavitha Nair',     role: 'Teacher',          quote: 'Nutrition plans are spot on. I feel stronger every day.',              icon: Icons.restaurant_menu),
  Testimonial(name: 'Sanjay Patel',     role: 'Business Owner',   quote: 'MrCoach kept me accountable. Best decision for my health!',           icon: Icons.trending_up),
];

// ══════════════════════════════════════════════════════════════════════════════
//  LOGIN SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController       _pageController  = PageController();
  final TextEditingController _nameController  = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  int    _currentPage      = 0;
  Timer? _timer;
  bool   _whatsappUpdates  = true;
  bool   _isLoading        = false;
  bool   _isExistingUser   = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        final next = (_currentPage + 1) % _testimonials.length;
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _onGetOtp() async {
    final name  = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final refCode = _isExistingUser ? '' : _referralController.text.trim();
    if (!_isExistingUser && name.isEmpty) {
      _snack('Please enter your name', Colors.redAccent); return;
    }
    if (phone.length != 10) {
      _snack('Enter a valid 10-digit mobile number', Colors.redAccent); return;
    }
    setState(() => _isLoading = true);

    final String fullPhone = '+91$phone';
    final result = await ApiService.sendLoginOtp(fullPhone, isLogin: _isExistingUser);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _snack('OTP sent successfully!', Colors.green);
      final dummyOtp = result['dummyOtp'] as String?;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phone: phone,
            name: _isExistingUser ? '' : name,
            dummyOtp: dummyOtp,
            whatsappUpdates: _whatsappUpdates,
            isExistingUser: _isExistingUser,
            referralCode: refCode.isEmpty ? null : refCode,
          ),
        ),
      );
    } else {
      _snack(result['message'] ?? 'Failed to send OTP', Colors.redAccent);
    }
  }

  void _snack(String msg, Color color, [Color textColor = Colors.white]) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: TextStyle(color: textColor)),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));

  void _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '91035596332-akkmai05bpof4jjaau3tg126seba4ip4.apps.googleusercontent.com',
        serverClientId: '91035596332-akkmai05bpof4jjaau3tg126seba4ip4.apps.googleusercontent.com',
      );
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User cancelled
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        _snack('Google authentication failed: Both ID and Access tokens are null', Colors.redAccent);
        setState(() => _isLoading = false);
        return;
      }

      final result = await ApiService.loginWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _snack('Logged in with Google! 🎉', Colors.green);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        _snack(result['message'] ?? 'Failed Google sign in', Colors.redAccent);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _snack('Google sign-in error: $e', Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBottomBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildTopSection(),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        image: DecorationImage(
          image: const AssetImage('assets/images/mrcoachbackground.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.25),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(children: [
              TextSpan(text: 'MR.',   style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              TextSpan(text: 'Coach', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFFFFD800), letterSpacing: -0.5)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal coach, always with you.',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500, height: 1.5),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 116,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _testimonials.length,
              itemBuilder: (_, i) => _TestimonialCard(testimonial: _testimonials[i]),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_testimonials.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == _currentPage ? const Color(0xFFFFD800) : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isExistingUser ? 'Welcome Back' : 'Get Started',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kText, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(_isExistingUser 
                  ? 'Login to access your workouts and coaching plans.'
                  : 'Login to unlock your Free Guided\nWorkouts and Coaching Plans.',
                  style: const TextStyle(fontSize: 13.5, color: kSubText, height: 1.5)),
              const SizedBox(height: 24),

              if (!_isExistingUser) ...[
                _inputContainer(
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: const Icon(Icons.person_outline, color: kSubText, size: 22),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(color: kText, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: kSubText, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              _inputContainer(
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: kBorder))),
                    child: const Row(children: [
                      Text('🇮🇳', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 6),
                      Text('+91', style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 15)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: kSubText, size: 18),
                    ]),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: kText, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Mobile Number',
                        hintStyle: TextStyle(color: kSubText, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        counterText: '',
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              if (!_isExistingUser) ...[
                _inputContainer(
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: const Icon(Icons.card_giftcard_rounded, color: kSubText, size: 22),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _referralController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(color: kText, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Referral Code (Optional)',
                          hintStyle: TextStyle(color: kSubText, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              GestureDetector(
                onTap: () => setState(() => _whatsappUpdates = !_whatsappUpdates),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(children: [
                    Container(height: 52, decoration: const BoxDecoration(color: Color(0xFF111B21))),
                    Positioned.fill(child: CustomPaint(painter: _WaPatternPainter())),
                    SizedBox(
                      height: 52,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: _whatsappUpdates ? const Color(0xFF25D366) : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _whatsappUpdates ? const Color(0xFF25D366) : Colors.white38,
                                width: 1.5,
                              ),
                            ),
                            child: _whatsappUpdates
                                ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 10),
                          const Text('Get updates on WhatsApp',
                              style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onGetOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBtnYellow,
                    disabledBackgroundColor: kBtnYellow.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: kDark, strokeWidth: 2.5))
                      : const Text('Get OTP',
                          style: TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isExistingUser = !_isExistingUser),
                  child: Text(
                    _isExistingUser
                        ? "New user? Create an account"
                        : "Already have an account? Log in",
                    style: const TextStyle(
                      color: kText,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(children: [
                const Expanded(child: Divider(color: kBorder, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR', style: TextStyle(color: kSubText.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const Expanded(child: Divider(color: kBorder, thickness: 1)),
              ]),
              const SizedBox(height: 18),

              GestureDetector(
                onTap: _onGoogleSignIn,
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _GoogleIcon(),
                    const SizedBox(width: 12),
                    const Text('Continue with Google',
                        style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 40),

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: kSubText, height: 1.6),
                    children: [
                      const TextSpan(text: 'By registering you agree to the '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(color: kText, decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                            );
                          },
                      ),
                      const TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: const TextStyle(color: kText, decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inputContainer({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: kInputBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kBorder),
    ),
    child: child,
  );
}

// ── Fitness Pattern Painter ────────────────────────────────────────────────────

class _FitnessPatternPainter extends CustomPainter {
  final Color  color;
  final double iconSize;
  final double spacingX;
  final double spacingY;

  const _FitnessPatternPainter({
    required this.color,
    this.iconSize = 13,   
    this.spacingX = 42,  
    this.spacingY = 38,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final icons = [
      Icons.fitness_center,
      Icons.directions_run,
      Icons.self_improvement,
      Icons.sports_gymnastics,
      Icons.restaurant_menu,
      Icons.emoji_events,
      Icons.favorite_border,
      Icons.trending_up,
      Icons.sports_basketball,
      Icons.local_fire_department,
      Icons.monitor_heart_outlined,
      Icons.sports_soccer,
      Icons.pool,
      Icons.pedal_bike,
      Icons.sports_tennis,
      Icons.set_meal,
      Icons.water_drop_outlined,
      Icons.timer_outlined,
      Icons.star_border,
      Icons.bolt,
    ];

    final tp = TextPainter(textDirection: TextDirection.ltr);
    int iconIndex = 0;
    double y = -6;
    int row = 0;

    while (y < size.height + iconSize) {
      double x = (row % 2 == 0) ? 8 : spacingX * 0.55;
      while (x < size.width + iconSize) {
        final icon = icons[iconIndex % icons.length];
        tp.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: color,
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(x, y));
        x += spacingX;
        iconIndex++;
      }
      y += spacingY;
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _FitnessPatternPainter old) =>
      old.color != color ||
      old.iconSize != iconSize ||
      old.spacingX != spacingX ||
      old.spacingY != spacingY;
}

// ── WA Pattern Painter ────────────────────────────────────────────────────────

class _WaPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final icons = [
      Icons.camera_alt_outlined,
      Icons.mic_none,
      Icons.emoji_emotions_outlined,
      Icons.favorite_border,
      Icons.phone_outlined,
      Icons.videocam_outlined,
      Icons.lock_outline,
      Icons.people_outline,
      Icons.thumb_up_alt_outlined,
      Icons.sentiment_satisfied_outlined,
      Icons.star_border,
      Icons.music_note,
      Icons.image_outlined,
      Icons.location_on_outlined,
      Icons.attach_file,
      Icons.send_outlined,
      Icons.notifications_outlined,
      Icons.check_circle_outline,
      Icons.chat_bubble_outline,
      Icons.sports_gymnastics,
    ];

    final tp = TextPainter(textDirection: TextDirection.ltr);
    const double iconSize = 11;
    const double spacingX = 26;
    const double spacingY = 22;
    int iconIndex = 0;
    double y = -4;
    int row = 0;

    while (y < size.height + iconSize) {
      double x = (row % 2 == 0) ? 6 : 16;
      while (x < size.width + iconSize) {
        final icon = icons[iconIndex % icons.length];
        tp.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: Colors.white.withOpacity(0.07),
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(x, y));
        x += spacingX;
        iconIndex++;
      }
      y += spacingY;
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Google Icon ───────────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 24, height: 24, child: CustomPaint(painter: _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    void arc(double start, double sweep, Color color) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false,
          Paint()..color = color..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.18..strokeCap = StrokeCap.butt);
    }
    arc(-1.05, 1.57, const Color(0xFFEA4335));
    arc(0.52,  1.57, const Color(0xFF4285F4));
    arc(2.09,  1.05, const Color(0xFFFBBC05));
    arc(3.14,  1.05, const Color(0xFF34A853));
    canvas.drawRect(
        Rect.fromLTRB(c.dx - 0.5, c.dy - size.height * 0.12, size.width, c.dy + size.height * 0.12),
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(c.dx + size.width * 0.22, c.dy), size.width * 0.12,
        Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Testimonial Card ──────────────────────────────────────────────────────────

class _TestimonialCard extends StatelessWidget {
  final Testimonial testimonial;
  const _TestimonialCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.40), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD800).withOpacity(0.18),
            border: Border.all(color: const Color(0xFFFFD800).withOpacity(0.8), width: 1.5),
          ),
          child: Icon(testimonial.icon, color: const Color(0xFF1A1A2E), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                testimonial.name,
                style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              Text(
                testimonial.role,
                style: const TextStyle(color: Color(0xFF5A4000), fontSize: 11, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                testimonial.quote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF4A4A5A), fontSize: 11.5, height: 1.4, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  OTP SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class OtpScreen extends StatefulWidget {
  final String phone, name;
  final String? dummyOtp;
  final bool whatsappUpdates;
  final bool isExistingUser;
  final String? referralCode;
  const OtpScreen({
    super.key,
    required this.phone,
    required this.name,
    this.dummyOtp,
    required this.whatsappUpdates,
    required this.isExistingUser,
    this.referralCode,
  });
  @override State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode>             _focusNodes   = List.generate(6, (_) => FocusNode());
  int    _resendSeconds = 30;
  Timer? _resendTimer;
  bool   _isVerifying  = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
      if (widget.dummyOtp != null && widget.dummyOtp!.length == 6) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = widget.dummyOtp![i];
        }
      }
    });
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() => setState(() {}));
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendSeconds == 0) { _resendTimer?.cancel(); }
      else { setState(() => _resendSeconds--); }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)  f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (_otp.length == 6) _verifyOtp();
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void _verifyOtp() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter complete 6-digit OTP'), backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _isVerifying = true);
    final String fullPhone = '+91${widget.phone}';
    final result = await ApiService.verifyLoginOtp(
      fullPhone,
      _otp,
      whatsappUpdates: widget.whatsappUpdates,
      referralCode: widget.referralCode,
    );

    if (result['success'] == true) {
      final user = result['user'];
      final String? name = user['name'];

      // If name is not set on the backend, or it's different/empty, we update it to the entered name!
      if (!widget.isExistingUser && (name == null || name.isEmpty || name == 'Enter your name')) {
        await ApiService.updateProfile({'name': widget.name});
      }

      setState(() => _isVerifying = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${widget.name}! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      setState(() => _isVerifying = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Invalid OTP'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
    }
  }

  void _resendOtp() async {
    if (_resendSeconds > 0) return;
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();

    setState(() => _isVerifying = true);
    final String fullPhone = '+91${widget.phone}';
    final result = await ApiService.sendLoginOtp(fullPhone, isLogin: widget.isExistingUser);
    setState(() => _isVerifying = false);

    if (result['success'] == true) {
      _startResendTimer();
      final newDummyOtp = result['dummyOtp'] as String?;
      if (newDummyOtp != null && newDummyOtp.length == 6) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = newDummyOtp[i];
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP resent to +91 ${widget.phone}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to resend OTP'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBottomBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TOP: yellow ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft:  Radius.circular(36),
                      bottomRight: Radius.circular(36)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft:  Radius.circular(36),
                      bottomRight: Radius.circular(36)),
                  child: Stack(
                    children: [
                      // 1. Base gradient
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFFBE6), // very soft yellow
                                Color(0xFFFFF099), // warm yellow
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 2. Colored gradient blobs
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF9F43).withOpacity(0.25), // soft peach/orange
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD800).withOpacity(0.35), // gold
                          ),
                        ),
                      ),
                      // 3. Blur effect overlay
                      Positioned.fill(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      // 4. Subtle pattern overlay (microtexture)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FitnessPatternPainter(
                            color: Colors.black.withOpacity(0.015),
                            iconSize: 11,
                            spacingX: 38,
                            spacingY: 34,
                          ),
                        ),
                      ),
                      // 5. Content Layout
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: kText.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.arrow_back_ios_new, color: kText, size: 18),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Glassmorphic Card Container for text/icon content
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: kText.withOpacity(0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.lock_outline, color: kText, size: 28),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Hi, ${widget.name}! 👋',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: kText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Enter OTP',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: kText,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF4A4A5A),
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        const TextSpan(text: 'We sent a 6-digit code to '),
                                        TextSpan(
                                          text: '+91 ${widget.phone}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: kText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                // ── BOTTOM: white + icon pattern ─────────────────────────────
                Stack(children: [
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter 6-digit OTP',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kSubText)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, _buildOtpBox),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: _resendSeconds > 0
                              ? RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 13.5, color: kSubText),
                                    children: [
                                      const TextSpan(text: "Didn't receive OTP? Resend in "),
                                      TextSpan(text: '${_resendSeconds}s',
                                          style: const TextStyle(color: kText, fontWeight: FontWeight.w700)),
                                    ],
                                  ))
                              : GestureDetector(
                                  onTap: _resendOtp,
                                  child: const Text('Resend OTP',
                                      style: TextStyle(color: kText, fontWeight: FontWeight.w700,
                                          fontSize: 13.5, decoration: TextDecoration.underline)),
                                ),
                        ),
                        const SizedBox(height: 36),

                        SizedBox(
                          width: double.infinity, height: 54,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBtnYellow,
                              disabledBackgroundColor: kBtnYellow.withOpacity(0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: _isVerifying
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(color: kDark, strokeWidth: 2.5))
                                : const Text('Verify & Continue',
                                    style: TextStyle(color: kDark, fontSize: 16,
                                        fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Change Mobile Number',
                                style: TextStyle(color: kSubText, fontSize: 13,
                                    decoration: TextDecoration.underline)),
                          ),
                        ),
                        if (widget.dummyOtp != null) ...[
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBE6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFF3B0)),
                              ),
                              child: Text(
                                'Developer Dummy OTP: ${widget.dummyOtp}',
                                style: const TextStyle(color: Color(0xFFE0AC00), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildOtpBox(int index) {
    final filled = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 48, height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace(index);
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _onOtpChanged(v, index),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: filled ? kBtnYellow : kCardBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kDark, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: filled ? const Color(0xFFFFD800) : kBorder)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
