
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

const kYellow       = Color(0xFFF5C518);
const kLightBg      = Color(0xFFFFFFFF);
const kLightCard    = Color(0xFFF5F5F5);
const kLightDivider = Color(0xFFE0E0E0);
const kBlackText    = Color(0xFF1A1A1A);
const kSubText      = Color(0xFF666666);

class TicketItem {
  final String title;
  final String price;
  int quantity;
  TicketItem({required this.title, required this.price, this.quantity = 0});
}

class ScheduleItem {
  final String time;
  final String label;
  ScheduleItem(this.label, this.time);
}
const _kEventTitle    = 'NAMMA BESSY MILE RUN 2026';
const _kEventDate     = 'Sun, 9 Aug 2026 | 5:00 AM';
const _kEventLocation = 'Olcott Memorial Higher Secondary School, Besant Nagar, Chennai';
const _kEventUrl      = 'https://mrcoach.in/events/bessy-mile-run-2026';  
const _kShareText     =
    '🏃 $_kEventTitle\n📅 $_kEventDate\n📍 $_kEventLocation\n\nRegister now: $_kEventUrl';

class Event1DetailPage extends StatefulWidget {
  final bool isBookmarked;
  final ValueChanged<bool>? onBookmarkChanged;

  const Event1DetailPage({
    super.key,
    this.isBookmarked = false,
    this.onBookmarkChanged,
  });

  @override
  State<Event1DetailPage> createState() => _Event1DetailPageState();
}

class _Event1DetailPageState extends State<Event1DetailPage> {
  late bool _bookmarked;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.isBookmarked;
  }
  void _toggleBookmark() {
    setState(() => _bookmarked = !_bookmarked);
    HapticFeedback.lightImpact();
    widget.onBookmarkChanged?.call(_bookmarked);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        _bookmarked ? '🔖 Event saved!' : 'Bookmark removed',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF0D0D0D),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 1),
    ));
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kLightBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Share Event',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kBlackText)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _ShareOption(
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    icon: Icons.chat_rounded,
                    onTap: () async {
                      Navigator.pop(context);
                      final encoded = Uri.encodeComponent(_kShareText);
                      final uri = Uri.parse('whatsapp://send?text=$encoded');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        final webUri = Uri.parse('https://wa.me/?text=$encoded');
                        await launchUrl(webUri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  _ShareOption(
                    label: 'Instagram',
                    color: const Color(0xFFE1306C),
                    icon: Icons.camera_alt_rounded,
                    onTap: () async {
                      Navigator.pop(context);
                      await Clipboard.setData(const ClipboardData(text: _kShareText));
                      final uri = Uri.parse('instagram://story-camera');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        final storeUri = Uri.parse('https://www.instagram.com');
                        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Event details copied! Paste in Instagram'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ));
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  _ShareOption(
                    label: 'More',
                    color: const Color(0xFF0D0D0D),
                    icon: Icons.more_horiz_rounded,
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.share(
                        _kShareText,
                        subject: _kEventTitle,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(color: kLightDivider),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(const ClipboardData(text: _kEventUrl));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('🔗 Link copied!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: kLightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kLightDivider),
                      ),
                      child: const Icon(Icons.link_rounded, color: kBlackText, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Copy link',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kBlackText)),
                          Text(_kEventUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: kSubText)),
                        ],
                      ),
                    ),
                    const Icon(Icons.copy, size: 18, color: kSubText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showVenueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kLightBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Venue',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kBlackText)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                          color: kLightCard, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: kBlackText, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OLCOTT MEMORIAL HIGHER SECONDARY SCHOOL\nBESANT NAGAR, CHENNAI',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kBlackText),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(const ClipboardData(
                              text: 'Olcott Memorial Higher Secondary School, Besant Nagar, Chennai'));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Address copied!'),
                                  duration: Duration(seconds: 1)),
                            );
                          }
                        },
                        child: const Icon(Icons.copy, size: 20, color: kSubText),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () async => await Share.share(
                            'Olcott Memorial Higher Secondary School, Besant Nagar, Chennai'),
                        child: const Icon(Icons.ios_share, size: 20, color: kSubText),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    const double lat = 13.0694;
                    const double lng = 80.2131;
                    final Uri googleMapsApp =
                        Uri.parse('google.navigation:q=$lat,$lng&mode=d');
                    final Uri googleMapsBrowser = Uri.parse(
                        'https://www.google.com/maps/dir//Olcott+Memorial+Higher+Secondary+School,+New+No.2,+III+Avenue+Road,+Sai+Ram+Colony,+Besant+Nagar,+Chennai,+Tamil+Nadu+600020/@12.9171456,80.2062336,12z/data=!4m8!4m7!1m0!1m5!1m1!1s0x3a5267eeb10dff37:0xa6429b7e4032d57b!2m2!1d80.2686637!2d13.0034516?entry=ttu&g_ep=EgoyMDI2MDQyOS4wIKXMDSoASAFQAw%3D%3D');
                    if (await canLaunchUrl(googleMapsApp)) {
                      await launchUrl(googleMapsApp);
                    } else {
                      await launchUrl(googleMapsBrowser,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlackText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Get directions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showScheduleSheet(BuildContext context) {
    final items = [
      ScheduleItem('Reporting Time', '5:00 AM'),
      ScheduleItem('Warm Up Session', '5:15 AM'),
      ScheduleItem('Race Start', '5:30 AM'),
      ScheduleItem('Finish Line Refreshments', '9:30 AM'),
      ScheduleItem('Awards Ceremony', '10:00 AM'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kLightBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Schedule and timeline',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kBlackText)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                          color: kLightCard, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: kBlackText, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 20, color: kBlackText),
                  SizedBox(width: 12),
                  Text('SUN, 09 AUG 2026',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: kBlackText)),
                ],
              ),
              const SizedBox(height: 28),
              ...List.generate(items.length, (i) {
                final isLast = i == items.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Column(
                          children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kSubText, width: 1.5),
                                color: Colors.transparent,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(width: 1.5, color: kLightDivider),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(items[i].label,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: kBlackText,
                                      fontWeight: FontWeight.w500)),
                              Text(items[i].time,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: kSubText,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kLightBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('About the Event',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kBlackText)),
              ),
            ),
            const Divider(height: 24, color: kLightDivider),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: const [
                  _TermsItem('🎉🎉 CHENNAI KIDATHON 2026\n\n✨ Presented by Vincera Sports'),
                  _TermsItem('About the Event\n\nChennai Kidathon 2026 is a fun-filled running event specially designed for children to promote fitness, confidence, and sportsmanship'),
                  _TermsItem('The event encourages young runners to stay active, build endurance, and enjoy the thrill of participating in a professionally organized race.'),
                  _TermsItem('With a safe and energetic environment, kids will experience the joy of running, cheering, and achieving their goals.'),
                  _TermsItem('From beginners to budding athletes, every child gets a chance to shine and create unforgettable memories.'),
                  _TermsItem('⏰Report Time: 5:00 AM\n\n🏁Race Start Time: 5:30 AM\n\n🎁 TAKEAWAY FOR PARTICIPANTS\n\n🏆 Trophies for the top three winners in each category\n\n👕 T-Shirts for all participants'),
                  _TermsItem('🏅Finisher Medal'),
                  _TermsItem('📜 Certificate of Participation'),
                  _TermsItem('🎟️ Bib Number'),
                  _TermsItem('🥪 Refreshments for all participants'),
                  _TermsItem('🚑 First-aid & Ambulance Support'),
                  _TermsItem('📸 Event Photos & Video Coverage'),
                  _TermsItem('🎟️ SPECIAL CATEGORY - MOM & DAD (CASH PRIZE)'),
                  _TermsItem('🏃‍♀️‍➡️🏃‍➡️Open Category 400 Mts (Minimum 16 Entries Required)\n\n🏆Cash Prizes'),
                  _TermsItem('🥇Winner: INR 2,000'),
                  _TermsItem('🥈Runner-Up: INR 1,000'),
                  _TermsItem('🥉Second Runner-Up: INR 500\n\n🏃‍➡️Participation\n\n- All participants must be medically fit to take part in the event.'),
                  _TermsItem('By registering, you confirm that you are physically capable of completing your chosen distance.\n\n⏰Event Rules\n\n- All runners must wear their bib number visibly during the race.\n\n- Follow the instructions of event organizers, volunteers, and officials at all times.\n\n- The organizer reserves the right to disqualify any participant for misconduct or rule violations.\n\n🚑 Safety & Responsibility\n\n- Basic first-aid and ambulance support will be available.\n\n- Participants run at their own risk.\n\n- The organizers are not responsible for any injury, loss, or damage during the event.\n\n📸 Media Consent\n\n- By participating, you agree to the use of your photos/videos for promotional and marketing purposes.\n\n- Merchandise & Collection Details'),
                  _TermsItem('👕 T-SHIRT & BIB COLLECTION\n\nDecathlon T Nagar\n\nDate: 1st August\n\nTime: 12:00 PM - 8:00 PM\n\n🏅 Certificate, Medal & Refreshments:\n\nWill be distributed on race day at the venue upon completion of the run.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showThingsToKnow(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kLightBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Things to know',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kBlackText)),
              ),
            ),
            const Divider(height: 24, color: kLightDivider),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  const Text('Event Guide',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: kBlackText)),
                  const SizedBox(height: 12),
                  _ThingsRow(Icons.language, 'Event will be conducted in English and Tamil'),
                  _ThingsRow(Icons.timer_outlined, 'Duration 5 Hours'),
                  _ThingsRow(Icons.confirmation_number_outlined, 'Ticket needed for ages 3 and above'),
                  _ThingsRow(Icons.person_outlined, 'Entry allowed for ages 3 and above'),
                  _ThingsRow(Icons.park_outlined, 'Layout Outdoor'),
                  _ThingsRow(Icons.event_seat_outlined, 'Seating Arrangement Seated & Standing'),
                  _ThingsRow(Icons.child_care, 'Kid friendly'),
                  const SizedBox(height: 20),
                  const Text('Rules & Guidelines',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: kBlackText)),
                  const SizedBox(height: 12),
                  _ThingsRow(Icons.check_circle_outline, 'Carry your bib on race day'),
                  _ThingsRow(Icons.check_circle_outline, 'No refunds once registered'),
                  _ThingsRow(Icons.check_circle_outline, 'Report 30 minutes before race start'),
                  _ThingsRow(Icons.check_circle_outline, 'Only registered participants allowed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kLightBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Terms and Conditions',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kBlackText)),
              ),
            ),
            const Divider(height: 24, color: kLightDivider),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: const [
                  _TermsItem('Please carry a valid ID proof along with you.'),
                  _TermsItem('No refunds on purchased tickets are possible, even in case of any rescheduling.'),
                  _TermsItem('Security procedures, including frisking remain the right of the management.'),
                  _TermsItem('No dangerous or potentially hazardous objects including but not limited to weapons, knives, guns, fireworks, helmets, laser devices, bottles, musical instruments will be allowed in the venue.'),
                  _TermsItem('The sponsors/performers/organizers are not responsible for any injury or damage occurring due to the event.'),
                  _TermsItem('People in an inebriated state may not be allowed entry.'),
                  _TermsItem('Organizers hold the right to deny late entry to the event.'),
                  _TermsItem('Venue rules apply.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kLightBg,
      body: Stack(
        children: [
          SizedBox(
            height: screenHeight * 0.55,
            width: double.infinity,
            child: Image.asset('assets/images/bessy.jpeg', fit: BoxFit.cover),
          ),

          Positioned(
            top: screenHeight * 0.38,
            left: 0, right: 0,
            height: screenHeight * 0.17,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [kLightBg, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight - 20,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios, color: kBlackText, size: 20),
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight - 20,
            right: 12,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36, height: 36,
                    // decoration: BoxDecoration(
                    //   color: _bookmarked
                    //       ? kYellow
                    //       : Colors.white.withOpacity(0.85),
                    //   shape: BoxShape.circle,
                      //boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.12),
                      //     blurRadius: 8, offset: const Offset(0, 2),
                      //   ),
                      // ],
                    ),
                    // child: Icon(
                    //   _bookmarked
                    //       ? Icons.bookmark_rounded
                    //       : Icons.bookmark_border_rounded,
                    //   color: _bookmarked ? const Color(0xFF0D0D0D) : kBlackText,
                    //   size: 20,
                    // ),
                  ),
               // ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showShareSheet(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8, offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.ios_share, color: kBlackText, size: 20),
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.52,
            minChildSize: 0.52,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: const [0.52, 1.0],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: kLightBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Wrap(
                        spacing: 8,
                        children: const [
                          _TagChip('Marathons'),
                          _TagChip('Kids'),
                          _TagChip('Fitness Events'),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Text(
                        'NAMMA BESSY MILE RUN 2026',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: kBlackText),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 6, 16, 16),
                      child: Text(
                        'SUN, 9 AUG, 5:00 AM',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: kYellow),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _InfoTile(
                            icon: Icons.location_on_outlined,
                            title: 'OLCOTT MEMORIAL HIGHER SECONDARY SCHOOL, BESANT NAGAR',
                            subtitle: '10.5 km away',
                            onTap: () => _showVenueSheet(context),
                          ),
                          const SizedBox(height: 10),
                          _InfoTile(
                            icon: Icons.calendar_month_outlined,
                            title: 'Reporting at 5:00 AM',
                            subtitle: 'View full schedule & timeline',
                            onTap: () => _showScheduleSheet(context),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('About the event',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: kBlackText)),
                          const SizedBox(height: 12),
                          const Text(
                            '🎉🎉 NAMMA BESSY MILE RUN 2026\n\n✨ Presented by Vincera Sports\n\nJoin us for an exciting run event at Besant Nagar, Chennai. A fun-filled day of fitness, energy, and celebration for all ages. Let\'s get Chennai running!',
                            style: TextStyle(fontSize: 14, color: kSubText, height: 1.6),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showAboutSheet(context),
                            child: const Row(
                              children: [
                                Text('Read more',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: kBlackText,
                                        fontWeight: FontWeight.w700)),
                                Icon(Icons.chevron_right, size: 18, color: kBlackText),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: kLightDivider, thickness: 0.5),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Things to Know',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: kBlackText)),
                          const SizedBox(height: 16),
                          _ThingsRow(Icons.translate, 'Event will be in English, Tamil'),
                          const Divider(color: kLightDivider, thickness: 0.5),
                          const SizedBox(height: 12),
                          _ThingsRow(Icons.person_outlined, 'Ticket needed for ages 3 and above'),
                          const Divider(color: kLightDivider, thickness: 0.5),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showThingsToKnow(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Text('Show all',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: kBlackText,
                                          fontWeight: FontWeight.w600)),
                                  Icon(Icons.chevron_right, size: 18, color: kBlackText),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: kLightDivider, thickness: 0.5),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: kLightCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description_outlined,
                            size: 18, color: kSubText),
                      ),
                      title: const Text('Terms and Conditions',
                          style: TextStyle(fontSize: 15, color: kBlackText)),
                      trailing: const Icon(Icons.chevron_right, color: kSubText),
                      onTap: () => _showTermsSheet(context),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(color: kLightDivider, width: 1)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₹600 ',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: kBlackText),
                                    ),
                                    TextSpan(
                                      text: 'onwards',
                                      style: TextStyle(fontSize: 13, color: kSubText),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const ChooseTicketPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kBlackText,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Book tickets',
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
class _ShareOption extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ShareOption({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kBlackText)),
        ],
      ),
    );
  }
}
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kLightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kLightDivider),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: kBlackText)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _InfoTile({
    required this.icon, required this.title,
    required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kLightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kLightDivider),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: kYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kYellow, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kBlackText)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: kSubText)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kSubText, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThingsRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ThingsRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: kBlackText),
          const SizedBox(width: 14),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, color: kSubText))),
        ],
      ),
    );
  }
}

class _TermsItem extends StatelessWidget {
  final String text;
  const _TermsItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  fontSize: 14, color: kBlackText, fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: kSubText, height: 1.6)),
          ),
        ],
      ),
    );
  }
}
class ChooseTicketPage extends StatefulWidget {
  const ChooseTicketPage({super.key});

  @override
  State<ChooseTicketPage> createState() => _ChooseTicketPageState();
}

class _ChooseTicketPageState extends State<ChooseTicketPage> {
  final List<TicketItem> _tickets = [
    TicketItem(title: '2 MILE RUN - BELOW 16 YEARS', price: '₹600'),
    TicketItem(title: '2 MILE RELAY X4 TEAM ENTRY', price: '₹2000'),
    TicketItem(title: '3 MILE RUN (4.8 KM)', price: '₹700'),
    TicketItem(title: '6 MILE RUN (9.6 KM)', price: '₹800'),
  ];

  int get _totalItems => _tickets.fold(0, (sum, t) => sum + t.quantity);
  int get _totalPrice => _tickets.fold(
      0,
      (sum, t) =>
          sum +
          (t.quantity * int.parse(t.price.replaceAll(RegExp(r'[₹,]'), ''))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBg,
      appBar: AppBar(
        backgroundColor: kLightBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kBlackText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NAMMA BESSY MILE RUN 2026',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: kBlackText)),
            Text('Sun, 9 Aug | 5 AM • Chennai',
                style: TextStyle(fontSize: 11, color: kSubText)),
          ],
        ),
      ),
      bottomNavigationBar: _totalItems > 0
          ? _CheckoutBar(total: _totalPrice, items: _totalItems)
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('CHOOSE TICKETS',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: kBlackText,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...List.generate(
            _tickets.length,
            (i) => _TicketRow(
              ticket: _tickets[i],
              onAdd: () => setState(() => _tickets[i].quantity++),
              onRemove: () => setState(() {
                if (_tickets[i].quantity > 0) _tickets[i].quantity--;
              }),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: Colors.red),
              SizedBox(width: 6),
              Text('Registration closes: August 2, 2026',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final TicketItem ticket;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _TicketRow(
      {required this.ticket, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kLightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kLightDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ticket.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kBlackText)),
              ),
              const SizedBox(width: 10),
              if (ticket.quantity == 0)
                OutlinedButton(
                  onPressed: onAdd,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBlackText),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('ADD',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kBlackText)),
                )
              else
                Row(
                  children: [
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(color: kBlackText),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.remove, size: 16, color: kBlackText),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${ticket.quantity}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: kBlackText)),
                    ),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: kBlackText,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(ticket.price,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kBlackText)),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final int total;
  final int items;
  const _CheckoutBar({required this.total, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kLightBg,
        border: Border(top: BorderSide(color: kLightDivider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹$total',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kBlackText)),
                Text('$items item${items > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 11, color: kSubText)),
              ],
            ),
            const SizedBox(width: 96),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlackText,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Checkout',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




