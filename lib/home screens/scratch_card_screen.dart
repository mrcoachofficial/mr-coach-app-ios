
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scratcher/scratcher.dart';
import '../services/api_service.dart';

const Color _kYellow      = Color(0xFFFFD54F);
const Color _kYellowDark  = Color(0xFFFFC107);
const Color _kYellowLight = Color(0xFFFFF8D6);
const Color _kBg          = Color(0xFFFFFDE7);
const Color _kTextDark    = Color(0xFF1A1200);
const Color _kTextMid     = Color(0xFF5C4A00);
const Color _kTextLight   = Color(0xFF9C8400);
const Color _kBorder      = Color(0xFFFFB300);
const Color _kGreen       = Color(0xFF00BFA5);
const Color _kGreenLight  = Color(0xFFE0F7F4);

enum ScratchTheme { gold, blue, green, purple, red }

extension ScratchThemeExt on ScratchTheme {
  Color get foilColor {
    switch (this) {
      case ScratchTheme.gold:   return const Color(0xFFE0AC00);
      case ScratchTheme.blue:   return const Color(0xFFE0AC00);
      case ScratchTheme.green:  return const Color(0xFF7C4DFF);
      case ScratchTheme.purple: return const Color(0xFFE0AC00);
      case ScratchTheme.red:    return const Color(0xFFE03131);
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
    }
  }

  Color get accent {
    switch (this) {
      case ScratchTheme.gold:   return const Color(0xFFB88A00);
      case ScratchTheme.blue:   return const Color(0xFFF9C413);
      case ScratchTheme.green:  return const Color(0xFF5E35B1);
      case ScratchTheme.purple: return const Color(0xFFF9C413);
      case ScratchTheme.red:    return const Color(0xFFE03131);
    }
  }
}

class GlobalScratchCard {
  final String id;
  final String reward;
  final String subReward;
  final String condition;
  final String earnedFrom;
  final String expiry;
  final ScratchTheme theme;
  final bool expired;
  bool scratched;
  bool claimed;

  GlobalScratchCard({
    required this.id,
    required this.reward,
    required this.subReward,
    required this.condition,
    required this.earnedFrom,
    required this.expiry,
    required this.theme,
    this.expired = false,
    this.scratched = false,
    this.claimed = false,
  });

  factory GlobalScratchCard.fromJson(Map<String, dynamic> json) {
    ScratchTheme themeEnum = ScratchTheme.gold;
    switch (json['theme'] ?? 'gold') {
      case 'blue': themeEnum = ScratchTheme.blue; break;
      case 'green': themeEnum = ScratchTheme.green; break;
      case 'purple': themeEnum = ScratchTheme.purple; break;
      case 'red': themeEnum = ScratchTheme.red; break;
      default: themeEnum = ScratchTheme.gold;
    }
    
    final status = json['status'] ?? 'pending';
    
    return GlobalScratchCard(
      id: json['_id'] ?? '',
      reward: json['title'] ?? '₹100',
      subReward: json['subTitle'] ?? 'Cashback',
      condition: json['condition'] ?? 'On next booking',
      earnedFrom: json['earnedFrom'] ?? 'Booking Reward',
      expiry: json['expiryDate'] != null 
          ? 'Expires on ${DateTime.parse(json['expiryDate']).toLocal().toString().split(' ')[0]}'
          : 'Expires in 30 days',
      theme: themeEnum,
      scratched: status == 'scratched' || status == 'claimed',
      claimed: status == 'claimed',
    );
  }
}

class ScratchCardStore {
  static final ScratchCardStore _instance = ScratchCardStore._internal();
  factory ScratchCardStore() => _instance;
  ScratchCardStore._internal();

  final List<GlobalScratchCard> cards = [];

  void addCard(GlobalScratchCard card) {
    cards.insert(0, card);
  }

  int get availableCount =>
      cards.where((c) => !c.scratched && !c.expired).length;

  Future<void> refreshFromBackend() async {
    try {
      final list = await ApiService.getUserRewards();
      cards.clear();
      for (final item in list) {
        cards.add(GlobalScratchCard.fromJson(item));
      }
    } catch (e) {
      debugPrint('Error fetching user rewards: $e');
    }
  }

  Future<bool> updateStatusOnBackend(String cardId, String status) async {
    try {
      return await ApiService.updateRewardStatus(cardId, status);
    } catch (e) {
      debugPrint('Error updating reward status: $e');
      return false;
    }
  }

  GlobalScratchCard createBookingReward({
    required String earnedFrom,
    ScratchTheme theme = ScratchTheme.gold,
  }) {
    return GlobalScratchCard(
      id: 'SC-${DateTime.now().millisecondsSinceEpoch}',
      reward: '₹100',
      subReward: 'Cashback',
      condition: 'On next booking',
      earnedFrom: earnedFrom,
      expiry: 'Expires in 30 days',
      theme: theme,
    );
  }
}

class ScratchCardBottomSheet extends StatefulWidget {
  final GlobalScratchCard card;
  final VoidCallback onViewAll;

  const ScratchCardBottomSheet({
    super.key,
    required this.card,
    required this.onViewAll,
  });

  static void show(
    BuildContext context, {
    required GlobalScratchCard card,
    required VoidCallback onViewAll,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ScratchCardBottomSheet(card: card, onViewAll: onViewAll),
    );
  }

  @override
  State<ScratchCardBottomSheet> createState() =>
      _ScratchCardBottomSheetState();
}

class _ScratchCardBottomSheetState extends State<ScratchCardBottomSheet>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScratcherState> _scratchKey = GlobalKey();
  bool _scratched = false;
  bool _claimed   = false;
  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _glowAnim =
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onThreshold() {
    if (_scratched) return;
    setState(() => _scratched = true);
    widget.card.scratched = true;
    HapticFeedback.heavyImpact();
    ScratchCardStore().updateStatusOnBackend(widget.card.id, 'scratched');
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _showRevealDialog();
    });
  }

  void _showRevealDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RewardRevealDialog(
        card: widget.card,
        onClaim: () {
          setState(() => _claimed = true);
          widget.card.claimed = true;
          ScratchCardStore().updateStatusOnBackend(widget.card.id, 'claimed');
          Navigator.pop(context);
        },
        onLater: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final theme = widget.card.theme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎁 Booking Reward!',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _kTextDark)),
                    const SizedBox(height: 4),
                    Text(
                      _scratched
                          ? (_claimed
                              ? 'Reward claimed! 🎉'
                              : 'Tap "Claim" to use your reward')
                          : 'Scratch to reveal your reward',
                      style:
                          const TextStyle(fontSize: 12, color: _kTextMid),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: _kTextMid),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent.withOpacity(
                          _scratched
                              ? 0.15
                              : 0.2 + _glowAnim.value * 0.2),
                      blurRadius: _scratched
                          ? 12
                          : 20 + _glowAnim.value * 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _CardRewardContent(theme: theme),
                      if (!_scratched)
                        Scratcher(
                          key: _scratchKey,
                          brushSize: 50,
                          threshold: 45,
                          accuracy: ScratchAccuracy.low,
                          color: theme.foilColor,
                          onThreshold: _onThreshold,
                          child: _CardFoilLayer(theme: theme),
                        ),
                      if (_scratched && _claimed)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: _kGreen,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded,
                                      size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('CLAIMED',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white)),
                                ]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!_scratched)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _kYellowLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder)),
              child: const Row(
                children: [
                  Text('👆', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Swipe your finger across the card to reveal your reward!',
                        style: TextStyle(
                            fontSize: 12,
                            color: _kTextMid,
                            height: 1.4)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onViewAll,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _kBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('View All Cards',
                      style: TextStyle(
                          color: _kTextMid,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              if (_scratched && !_claimed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showRevealDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kYellow,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Claim Reward',
                        style: TextStyle(
                            color: _kTextDark,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class ScratchRewardsPage extends StatefulWidget {
  const ScratchRewardsPage({super.key});

  @override
  State<ScratchRewardsPage> createState() => _ScratchRewardsPageState();
}

class _ScratchRewardsPageState extends State<ScratchRewardsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
  bool _loading = true;

  List<GlobalScratchCard> get _cards => ScratchCardStore().cards;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _fetchFromBackend();
  }

  Future<void> _fetchFromBackend() async {
    setState(() => _loading = true);
    await ScratchCardStore().refreshFromBackend();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onScratched(int i) {
    if (_cards[i].scratched) return;
    setState(() => _cards[i].scratched = true);
    ScratchCardStore().updateStatusOnBackend(_cards[i].id, 'scratched');
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => RewardRevealDialog(
          card: _cards[i],
          onClaim: () {
            setState(() => _cards[i].claimed = true);
            ScratchCardStore().updateStatusOnBackend(_cards[i].id, 'claimed');
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                '${_cards[i].reward} ${_cards[i].subReward} claimed! 🎉',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: _kTextDark),
              ),
              backgroundColor: _kYellow,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ));
          },
          onLater: () => Navigator.pop(context),
        ),
      );
    });
  }

  int get _available =>
      _cards.where((c) => !c.scratched && !c.expired).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD966), _kYellow, Color(0xFFE0AC00)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  bottom: 28,
                ),
                child: Column(children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _kTextDark,
                            size: 16),
                      ),
                    ),
                    const Spacer(),
                    const Column(children: [
                      Text('Scratch & Win',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _kTextDark)),
                      SizedBox(height: 2),
                      Text('Your Rewards',
                          style: TextStyle(
                              fontSize: 11, color: _kTextDark)),
                    ]),
                    const Spacer(),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.history_rounded,
                          color: _kTextDark, size: 20),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      const Icon(Icons.touch_app_rounded,
                          size: 20, color: _kTextDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Swipe to Scratch!',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: _kTextDark)),
                            Text(
                              '$_available card${_available == 1 ? '' : 's'} waiting for you',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _kTextDark.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: _kTextDark,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text('Scratch\nNow',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: _kYellow,
                                height: 1.3)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_kBorder),
                  ),
                ),
              )
            else if (_cards.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                            color: _kYellowLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _kBorder, width: 1.5)),
                        alignment: Alignment.center,
                        child: const Text('🎟️',
                            style: TextStyle(fontSize: 38)),
                      ),
                      const SizedBox(height: 20),
                      const Text('No Scratch Cards Yet',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _kTextDark)),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete a booking to earn\nyour first scratch card!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: _kTextMid,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              )

            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(children: [
                    Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                            color: _kYellow,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    const Text('Your Scratch Cards',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _kTextDark)),
                    const Spacer(),
                    if (_available > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: _kYellow,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('$_available New',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _kTextDark)),
                      ),
                  ]),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _GridScratchCard(
                      key: ValueKey(_cards[i].id),
                      entry: _cards[i],
                      onScratched: () => _onScratched(i),
                    ),
                    childCount: _cards.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class FullScreenScratchPage extends StatefulWidget {
  final GlobalScratchCard entry;
  final VoidCallback onScratched;

  const FullScreenScratchPage({
    super.key,
    required this.entry,
    required this.onScratched,
  });

  @override
  State<FullScreenScratchPage> createState() =>
      _FullScreenScratchPageState();
}

class _FullScreenScratchPageState extends State<FullScreenScratchPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScratcherState> _scratchKey = GlobalKey();
  bool _triggered = false;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _glowAnim =
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _handleThreshold() {
    if (_triggered) return;
    _triggered = true;
    HapticFeedback.heavyImpact();
    widget.entry.scratched = true;

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onScratched();
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final screenH = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1200),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FullScreenBgPainter(theme: e.theme),
            ),
          ),
          Positioned(
            top: topPad + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
          Positioned(
            top: topPad + 18,
            left: 0,
            right: 0,
            child: const Column(
              children: [
                Text(
                  '🎁 Booking Reward',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Scratch to reveal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
          Positioned(
            top: topPad + 90,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Container(
                height: screenH * 0.52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: e.theme.accent.withOpacity(
                          0.28 + _glowAnim.value * 0.22),
                      blurRadius: 36 + _glowAnim.value * 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'scratch_card_${e.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _FullScreenRewardContent(entry: e),
                        Scratcher(
                          key: _scratchKey,
                          brushSize: 62,
                          threshold: 45,
                          accuracy: ScratchAccuracy.low,
                          color: e.theme.foilColor,
                          onThreshold: _handleThreshold,
                          child: _FullScreenFoilLayer(
                              theme: e.theme,
                              earnedFrom: e.earnedFrom),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: bottomPad + 32,
            left: 40,
            right: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('👆', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Text(
                    'Swipe your finger to scratch!',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _FullScreenFoilLayer extends StatefulWidget {
  final ScratchTheme theme;
  final String earnedFrom;
  const _FullScreenFoilLayer(
      {required this.theme, required this.earnedFrom});

  @override
  State<_FullScreenFoilLayer> createState() =>
      _FullScreenFoilLayerState();
}

class _FullScreenFoilLayerState extends State<_FullScreenFoilLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimCtrl;

  @override
  void initState() {
    super.initState();
    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimCtrl,
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
          Positioned.fill(
              child: CustomPaint(
                  painter:
                      _CoinPatternPainter(theme: widget.theme))),
          Positioned.fill(
              child: CustomPaint(
                  painter:
                      _ShimmerPainter(shimmer: _shimCtrl.value))),
          Positioned.fill(
              child: CustomPaint(
                  painter: _GlitterPainter(
                      progress: _shimCtrl.value,
                      theme: widget.theme))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2.5),
                  ),
                  child: const Center(
                    child: Text('MC',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Scratch here',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ]),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(widget.earnedFrom,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _kTextDark)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
class _FullScreenRewardContent extends StatelessWidget {
  final GlobalScratchCard entry;
  const _FullScreenRewardContent({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: entry.theme.gradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: entry.theme.accent.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ],
          ),
          child: const Center(
              child: Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 46)),
        ),
        const SizedBox(height: 16),
        Text(entry.reward,
            style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: entry.theme.accent,
                letterSpacing: -2)),
        Text(entry.subReward,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: entry.theme.accent.withOpacity(0.8))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10)),
          child: Text(entry.condition,
              style: const TextStyle(
                  fontSize: 13,
                  color: _kTextMid,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: entry.theme.gradient),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: entry.theme.accent.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5))
            ],
          ),
          child: const Text('CLAIM NOW',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Text(entry.expiry,
            style: const TextStyle(fontSize: 11, color: _kTextMid)),
      ]),
    );
  }
}
class _FullScreenBgPainter extends CustomPainter {
  final ScratchTheme theme;
  const _FullScreenBgPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1200),
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.accent.withOpacity(0.18),
          Colors.transparent,
        ],
        radius: 0.75,
      ).createShader(Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_FullScreenBgPainter old) => false;
}

class RewardRevealDialog extends StatefulWidget {
  final GlobalScratchCard card;
  final VoidCallback onClaim;
  final VoidCallback onLater;

  const RewardRevealDialog({
    super.key,
    required this.card,
    required this.onClaim,
    required this.onLater,
  });

  @override
  State<RewardRevealDialog> createState() => _RewardRevealDialogState();
}

class _RewardRevealDialogState extends State<RewardRevealDialog>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl, _confettiCtrl, _pulseCtrl;
  late Animation<double>   _scaleAnim, _slideAnim, _pulseAnim;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 28; i++) {
      _particles.add(_ConfettiParticle(
        x: _rng.nextDouble(),
        delay: _rng.nextDouble() * 0.4,
        speed: 0.4 + _rng.nextDouble() * 0.6,
        size: 5.0 + _rng.nextDouble() * 6,
        rotation: _rng.nextDouble() * math.pi * 2,
        color: [
          _kYellow,
          _kGreen,
          const Color(0xFF4B8EF1),
          const Color(0xFFFF6B35),
          Colors.white,
          const Color(0xFFFF6B9D),
        ][_rng.nextInt(6)],
      ));
    }
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..forward();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _scaleAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _slideAnim = CurvedAnimation(
        parent: _entryCtrl, curve: Curves.easeOutCubic);
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _entryCtrl.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _confettiCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return AnimatedBuilder(
      animation:
          Listenable.merge([_scaleAnim, _confettiCtrl, _pulseAnim]),
      builder: (_, __) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiCtrl.value),
              ),
            ),
          ),
          Transform.scale(
            scale: _scaleAnim.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                      color: c.theme.accent.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 12)),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: c.theme.gradient),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32)),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(28, 24, 28, 28),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 1.0 + _pulseAnim.value * 0.06,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: c.theme.gradient),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: c.theme.accent.withOpacity(
                                        0.4 +
                                            _pulseAnim.value * 0.2),
                                    blurRadius:
                                        20 + _pulseAnim.value * 10,
                                    spreadRadius: 2)
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.emoji_events_rounded,
                                  size: 46, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero)
                              .animate(_slideAnim),
                          child: FadeTransition(
                            opacity: _slideAnim,
                            child: Column(children: [
                              const Text("You've Won! 🎉",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: _kTextDark,
                                      letterSpacing: -0.5)),
                              const SizedBox(height: 6),
                              Text(
                                  'Earned from: ${c.earnedFrom}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: _kTextMid)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0.5),
                                  end: Offset.zero)
                              .animate(_slideAnim),
                          child: FadeTransition(
                            opacity: _slideAnim,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 22, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: c.theme.gradient
                                        .map((col) =>
                                            col.withOpacity(0.12))
                                        .toList()),
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color: c.theme.accent
                                        .withOpacity(0.3),
                                    width: 2),
                              ),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(c.reward,
                                        style: TextStyle(
                                            fontSize: 48,
                                            fontWeight:
                                                FontWeight.w900,
                                            color: c.theme.accent,
                                            letterSpacing: -2)),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(c.subReward,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w900,
                                                color:
                                                    c.theme.accent)),
                                        Text(c.condition,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: _kTextMid)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  child: Text(c.expiry,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: _kTextMid,
                                          fontWeight:
                                              FontWeight.w600)),
                                ),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0.5),
                                  end: Offset.zero)
                              .animate(_slideAnim),
                          child: FadeTransition(
                            opacity: _slideAnim,
                            child: Column(children: [
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: widget.onClaim,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 17),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: c.theme.gradient),
                                      borderRadius:
                                          BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                            color: c.theme.accent
                                                .withOpacity(0.4),
                                            blurRadius: 16,
                                            offset:
                                                const Offset(0, 6))
                                      ],
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.redeem_rounded,
                                              size: 20,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Claim Reward',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  color:
                                                      Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: widget.onLater,
                                child: const Text('Claim Later',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: _kTextMid,
                                        fontWeight:
                                            FontWeight.w600)),
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
class _CardFoilLayer extends StatefulWidget {
  final ScratchTheme theme;
  const _CardFoilLayer({required this.theme});

  @override
  State<_CardFoilLayer> createState() => _CardFoilLayerState();
}

class _CardFoilLayerState extends State<_CardFoilLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimCtrl;

  @override
  void initState() {
    super.initState();
    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimCtrl,
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
          Positioned.fill(
              child: CustomPaint(
                  painter:
                      _CoinPatternPainter(theme: widget.theme))),
          Positioned.fill(
              child: CustomPaint(
                  painter:
                      _ShimmerPainter(shimmer: _shimCtrl.value))),
          Positioned.fill(
              child: CustomPaint(
                  painter: _GlitterPainter(
                      progress: _shimCtrl.value,
                      theme: widget.theme))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2),
                  ),
                  child: const Center(
                    child: Text('MC',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Scratch here',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('Booking Reward',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _kTextDark)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _CardRewardContent extends StatelessWidget {
  final ScratchTheme theme;
  const _CardRewardContent({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.gradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: theme.accent.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Center(
              child: Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 30)),
        ),
        const SizedBox(height: 10),
        Text('₹100',
            style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: theme.accent,
                letterSpacing: -1)),
        const Text('Cashback',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kTextMid)),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8)),
          child: const Text('On next booking',
              style: TextStyle(
                  fontSize: 10,
                  color: _kTextMid,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: theme.gradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: theme.accent.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: const Text('CLAIM NOW',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
      ]),
    );
  }
}
class _GridScratchCard extends StatefulWidget {
  final GlobalScratchCard entry;
  final VoidCallback onScratched;
  const _GridScratchCard(
      {super.key, required this.entry, required this.onScratched});

  @override
  State<_GridScratchCard> createState() => _GridScratchCardState();
}

class _GridScratchCardState extends State<_GridScratchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _glowAnim =
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    if (e.expired) return _ExpiredGridCard(entry: e);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => GestureDetector(
        onTap: e.scratched
            ? null
            : () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration:
                        const Duration(milliseconds: 420),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 380),
                    pageBuilder: (_, animation, __) => FadeTransition(
                      opacity: animation,
                      child: FullScreenScratchPage(
                        entry: e,
                        onScratched: widget.onScratched,
                      ),
                    ),
                  ),
                );
              },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: e.theme.accent.withOpacity(
                    e.scratched
                        ? 0.15
                        : 0.2 + _glowAnim.value * 0.2),
                blurRadius:
                    e.scratched ? 12 : 16 + _glowAnim.value * 10,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Hero(
            tag: 'scratch_card_${e.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _GridRewardContent(entry: e),
                  if (!e.scratched)
                    IgnorePointer(
                      child: _GridFoilLayer(
                          theme: e.theme,
                          earnedFrom: e.earnedFrom),
                    ),
                  if (e.scratched && e.claimed)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: _kGreen,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  size: 10, color: Colors.white),
                              SizedBox(width: 3),
                              Text('CLAIMED',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ]),
                      ),
                    ),
                  if (e.scratched && !e.claimed)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: _kYellow,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('TAP TO CLAIM',
                            style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                color: _kTextDark)),
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

class _GridFoilLayer extends StatefulWidget {
  final ScratchTheme theme;
  final String earnedFrom;
  const _GridFoilLayer(
      {required this.theme, required this.earnedFrom});

  @override
  State<_GridFoilLayer> createState() => _GridFoilLayerState();
}

class _GridFoilLayerState extends State<_GridFoilLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimCtrl;

  @override
  void initState() {
    super.initState();
    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimCtrl,
      builder: (_, __) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.theme.gradient),
        ),
        child: Stack(children: [
          Positioned.fill(
              child: CustomPaint(
                  painter:
                      _CoinPatternPainter(theme: widget.theme))),
          Positioned.fill(
              child: CustomPaint(
                  painter:
                      _ShimmerPainter(shimmer: _shimCtrl.value))),
          Positioned.fill(
              child: CustomPaint(
                  painter: _GlitterPainter(
                      progress: _shimCtrl.value,
                      theme: widget.theme))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2),
                  ),
                  child: const Center(
                      child: Text('MC',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white))),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Scratch here',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ]),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.earnedFrom,
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: _kTextDark)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
class _GridRewardContent extends StatelessWidget {
  final GlobalScratchCard entry;
  const _GridRewardContent({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: entry.theme.gradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: entry.theme.accent.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Center(
              child: Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 26)),
        ),
        const SizedBox(height: 8),
        Text(entry.reward,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: entry.theme.accent,
                letterSpacing: -1)),
        Text(entry.subReward,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kTextMid)),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6)),
          child: Text(entry.condition,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 8,
                  color: _kTextMid,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: entry.theme.gradient),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: entry.theme.accent.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: const Text('CLAIM',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(entry.expiry,
            style: const TextStyle(fontSize: 8, color: _kTextMid)),
      ]),
    );
  }
}

class _ExpiredGridCard extends StatelessWidget {
  final GlobalScratchCard entry;
  const _ExpiredGridCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF0EEE8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFEEEDEA))),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
              color: Color(0xFFEEEDEA), shape: BoxShape.circle),
          child: const Icon(Icons.timer_off_rounded,
              size: 24, color: Color(0xFF888880)),
        ),
        const SizedBox(height: 8),
        const Text('Expired',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF888880))),
        const SizedBox(height: 4),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
              color: const Color(0xFFEEEDEA).withOpacity(0.8),
              borderRadius: BorderRadius.circular(6)),
          child: Text(entry.expiry,
              style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF888880),
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 6),
        Text(entry.reward,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFFCCCCCC),
                decoration: TextDecoration.lineThrough)),
      ]),
    );
  }
}
class _GlitterPainter extends CustomPainter {
  final double progress;
  final ScratchTheme theme;

  _GlitterPainter({required this.progress, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final sparklePositions = [
      Offset(size.width * 0.15, size.height * 0.20),
      Offset(size.width * 0.80, size.height * 0.15),
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.70, size.height * 0.70),
      Offset(size.width * 0.50, size.height * 0.30),
      Offset(size.width * 0.88, size.height * 0.50),
      Offset(size.width * 0.10, size.height * 0.50),
      Offset(size.width * 0.60, size.height * 0.88),
    ];
    for (int i = 0; i < sparklePositions.length; i++) {
      final phase = (progress + i * 0.13) % 1.0;
      final scale = math.sin(phase * math.pi);
      if (scale <= 0) continue;
      final pos = sparklePositions[i];
      final sparkleSize = 4.0 + scale * 5.0;
      final opacity = scale * 0.9;
      _drawSparkle(canvas, pos, sparkleSize, opacity);
    }
  }

  void _drawSparkle(
      Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final r = i.isEven ? size : size * 0.35;
      final x = center.dx + r * math.cos(angle - math.pi / 2);
      final y = center.dy + r * math.sin(angle - math.pi / 2);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, size * 0.15,
        paint..color = Colors.white.withOpacity(opacity * 0.8));
  }

  @override
  bool shouldRepaint(_GlitterPainter old) => old.progress != progress;
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
        Colors.white.withOpacity(0.20),
        Colors.white.withOpacity(0.45),
        Colors.white.withOpacity(0.20),
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0, 0.3, 0.45, 0.5, 0.55, 0.7, 1],
    ).createShader(
        Rect.fromLTWH(x, 0, size.width * 2, size.height));
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
      canvas.drawCircle(pos, 11, strokePaint);
      canvas.drawCircle(pos, 8, fillPaint);
    }

    for (final pos in [
      Offset(size.width * 0.18, size.height * 0.20),
      Offset(size.width * 0.72, size.height * 0.30),
      Offset(size.width * 0.15, size.height * 0.65),
      Offset(size.width * 0.78, size.height * 0.68),
    ]) {
      final tp = TextPainter(
        text: TextSpan(
            text: '₹',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.12))),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double x = -size.height;
        x < size.width + size.height;
        x += 14) {
      canvas.drawLine(Offset(x, 0),
          Offset(x + size.height, size.height), linePaint);
    }

    final mcPainter = TextPainter(
      text: TextSpan(
          text: 'MC',
          style: TextStyle(
              fontSize: size.width * 0.5,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.05),
              letterSpacing: 4)),
      textDirection: TextDirection.ltr,
    )..layout();
    mcPainter.paint(
        canvas,
        Offset((size.width - mcPainter.width) / 2,
            (size.height - mcPainter.height) / 2));
  }

  @override
  bool shouldRepaint(_CoinPatternPainter old) => false;
}

class _ConfettiParticle {
  final double x, delay, speed, size, rotation;
  final Color color;
  const _ConfettiParticle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  const _ConfettiPainter(
      {required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (int idx = 0; idx < particles.length; idx++) {
      final p = particles[idx];
      final t = ((progress - p.delay) * p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x = p.x * size.width;
      final y = -20.0 + t * (size.height + 80);
      final rot = p.rotation + t * math.pi * 5;
      final opacity =
          t < 0.8 ? 1.0 : (1.0 - t) / 0.2;
      final paint = Paint()
        ..color =
            p.color.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      if (idx % 2 == 0) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset.zero,
                    width: p.size,
                    height: p.size * 0.5),
                const Radius.circular(1.5)),
            paint);
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress;
}