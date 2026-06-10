import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mrcoach/main.dart';
import 'package:mrcoach/theme_notifier.dart';




class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _activeFilter = 'All Events';
  final _filters = ['All Events', 'Running', 'Wellness'];

  late Timer _timer;
  int _secondsLeft = 45 * 86400 + 9 * 3600 + 57 * 60 + 30;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int get _days => _secondsLeft ~/ 86400;
  int get _hours => (_secondsLeft % 86400) ~/ 3600;
  int get _mins => (_secondsLeft % 3600) ~/ 60;
  int get _secs => _secondsLeft % 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavBar(),
            _buildEventHero(),
            const SizedBox(height: 16),
            _buildFilterBar(),
            const SizedBox(height: 16),
            _buildEventCard(),
            const SizedBox(height: 32),
            _buildFooter(),
            const SizedBox(height: 32),
            
            const SizedBox(height: 32),
           
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _logo(),
          const SizedBox(width: 10),
          Expanded(
              child: _searchBar(
                  'Search for events, locations, dates...')),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: kGrey),
                SizedBox(width: 3),
                Text('Select Location',
                    style: TextStyle(fontSize: 11, color: kBlack)),
                SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down, size: 13),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _bookDemoButton(context),
          const SizedBox(width: 6),
          const Icon(Icons.menu, size: 22),
        ],
      ),
    );
  }

  Widget _buildEventHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFECB3), Color(0xFFFFF3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 600;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('MAY 24, 12:00 AM',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const SizedBox(height: 14),
            const Text(
              'CHENNAI RISE UP RUN –\nFUN & AWARENESS MARATHON',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kBlack,
                  height: 1.3),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: kGrey),
                SizedBox(width: 5),
                Flexible(
                  child: Text('DECATHLON – MOGAPPAIR – CHENNAI',
                      style: TextStyle(
                          fontSize: 11,
                          color: kGrey,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                _countdownUnit(
                    _days.toString().padLeft(2, '0'), 'DAYS'),
                _colonSep(),
                _countdownUnit(
                    _hours.toString().padLeft(2, '0'), 'HRS'),
                _colonSep(),
                _countdownUnit(
                    _mins.toString().padLeft(2, '0'), 'MINS'),
                _colonSep(),
                _countdownUnit(
                    _secs.toString().padLeft(2, '0'), 'SECS'),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kYellow,
                foregroundColor: kBlack,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('BOOK TICKETS',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ],
        );

        if (!isWide) return content;

        return Row(
          children: [
            Expanded(child: content),
            const SizedBox(width: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://cdn.pixabay.com/photo/2016/11/29/03/53/adult-1867743_1280.jpg',
                width: 260,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 260,
                  height: 260,
                  color: Colors.amber.shade100,
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _countdownUnit(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: kBlack)),
        Text(label, style: const TextStyle(fontSize: 9, color: kGrey)),
      ],
    );
  }

  Widget _colonSep() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text(':',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: kBlack)),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final active = f == _activeFilter;
            return GestureDetector(
              onTap: () => setState(() => _activeFilter = f),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? kBlack : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: active ? kBlack : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      f == 'All Events'
                          ? Icons.apps
                          : f == 'Running'
                              ? Icons.directions_run
                              : Icons.spa,
                      size: 14,
                      color: active ? Colors.white : kGrey,
                    ),
                    const SizedBox(width: 5),
                    Text(f,
                        style: TextStyle(
                            color: active ? Colors.white : kGrey,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEventCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 320,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: Image.network(
                      'https://img.freepik.com/free-psd/marathon-run-event-poster_23-2151978594.jpg?semt=ais_rp_progressive&w=740&q=80',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 40)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('500 SPOTS LEFT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_outlined,
                              size: 11, color: kGrey),
                          SizedBox(width: 3),
                          Text('MAY 24',
                              style:
                                  TextStyle(fontSize: 10, color: kGrey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CHENNAI RISE UP RUN – FUN &\nAWARENESS MARATHON',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: kBlack),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 11, color: kGrey),
                          SizedBox(width: 3),
                          Text('DECATHLON – MOGAPPAIR - CHENNAI',
                              style: TextStyle(
                                  fontSize: 10, color: kGrey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check, size: 13, color: kYellow),
                        SizedBox(width: 5),
                        Text('Join us for this event!',
                            style:
                                TextStyle(fontSize: 11, color: kGrey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: kLightGrey,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('₹299',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.people_outline,
                                size: 14, color: kGrey),
                            SizedBox(width: 3),
                            Text('500/500',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: kGrey,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: kYellow,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _logo(),
                    const SizedBox(height: 6),
                    const Text(
                      "Mr. Coach – India's Smart Fitness App",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GET IN TOUCH',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 8),
                    _footerContact('PHONE:', '+91 74484 21134'),
                    const SizedBox(height: 5),
                    _footerContact(
                        'EMAIL:', 'mrcoachofficial@gmail.com'),
                  ],
                ),
              ),
              Row(
                children: [
                  _socialIcon2(Icons.facebook, Colors.blue),
                  const SizedBox(width: 5),
                  _socialIcon2(Icons.camera_alt_outlined, Colors.pink),
                  const SizedBox(width: 5),
                  _socialIcon2(Icons.message, Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('© 2026 MR.COACH. All rights reserved.',
              style: TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _footerContact(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: kBlack),
          children: [
            TextSpan(
                text: '$label ',
                style:
                    const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon2(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }
}
Widget _logo() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
        //     color: kBlack, borderRadius: BorderRadius.circular(6)),
        // child: const Icon(Icons.fitness_center, color: kYellow, size: 18),
        
        )
      ),
      Image.asset("assets/images/logo.jpeg",height: 20,width: 20,),
      const SizedBox(width: 7),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('MR.COACH',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1)),
          Text('FITNESS COMPANY',
              style: TextStyle(
                  fontSize: 7,
                  letterSpacing: 1.5,
                  color: Colors.black54)),
        ],
      ),
    ],
  );
}

Widget _searchBar(String hint) {
  return Container(
    height: 36,
    decoration: BoxDecoration(
      color: kLightGrey,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        const SizedBox(width: 10),
        const Icon(Icons.search, size: 15, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
            child: Text(hint,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11))),
      ],
    ),
  );
}
Widget _bookDemoButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () => showDialog(
      context: context,
      builder: (_) => const BookDemoDialog(),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: kBlack,
      side: const BorderSide(color: kBlack, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    child: const Text(
      'BOOK A DEMO',
      style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    ),
  );
}

class BookDemoDialog extends StatefulWidget {
  const BookDemoDialog({super.key});

  @override
  State<BookDemoDialog> createState() => _BookDemoDialogState();
}

class _BookDemoDialogState extends State<BookDemoDialog> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _gender;
  

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: kYellow, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'BOOK A DEMO',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB8860B)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Start with your basic details.',
                        style: TextStyle(
                            color: Color(0xFFB8860B),
                            fontWeight: FontWeight.w600)),
                    const Text(
                        "We'll never spam or share your contact info.",
                        style:
                            TextStyle(color: kGrey, fontSize: 11)),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 14),
            if (_step == 0) ...[
              _formField('NAME', _nameCtrl, 'Full Name'),
              _formField('EMAIL', _emailCtrl, 'name@example.com',
                  keyboardType: TextInputType.emailAddress),
              _formField('PHONE', _phoneCtrl, 'Mobile Number',
                  keyboardType: TextInputType.phone),
              _dropdownField(),
            ],
            if (_step > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Step ${_step + 1} of 4\nMore details coming…',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kGrey, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  children: List.generate(
                    4,
                    (i) => Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: i == _step
                            ? kYellow
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_step < 3) {
                      setState(() => _step++);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kYellow,
                    foregroundColor: kBlack,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Text('Next',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  label: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: kBlack,
                  letterSpacing: 0.5),
              children: [
                TextSpan(text: label),
                const TextSpan(
                    text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Colors.grey, fontSize: 12),
              filled: true,
              fillColor: kLightGrey,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: kBlack,
                letterSpacing: 0.5),
            children: [
              TextSpan(text: 'GENDER'),
              TextSpan(
                  text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kLightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _gender,
              hint: const Text('-- Please choose an option --',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              items: ['Male', 'Female', 'Other']
                  .map((g) =>
                      DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
          ),
        ),
      ],
    );
  }
}