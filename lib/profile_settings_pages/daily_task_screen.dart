import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mrcoach/services/api_service.dart';
import 'package:mrcoach/services/location_service.dart';
import 'package:mrcoach/home%20screens/scratch_card_screen.dart';

const Color kYellow      = Color(0xFFF9C413);
const Color kYellowLight = Color(0xFFFFF8E1);
const Color kYellowDark  = Color(0xFFF0A500);
const Color kYellowMid   = Color(0xFFFDD835);
const Color kDark        = Color(0xFF1A1A2E);
const Color kDarkCard    = Color(0xFF16213E);
const Color kGreen       = Color(0xFF4CAF50);
const Color kGreenLight  = Color(0xFFE8F5E9);
const Color kGrey        = Color(0xFF888888);
const Color kGreyLight   = Color(0xFFF7F7F7);
const Color kWhite       = Colors.white;
const Color kOrange      = Color(0xFFFF6B35);
const Color kBgYellow    = Color(0xFFFFFDE7);

class TasksHomeScreen extends StatefulWidget {
  const TasksHomeScreen({super.key});

  @override
  State<TasksHomeScreen> createState() => _TasksHomeScreenState();
}

class _TasksHomeScreenState extends State<TasksHomeScreen> with TickerProviderStateMixin {
  int _tabIndex = 0; // 0 = Weekly, 1 = Monthly, 2 = Coins
  int _totalCoins = 0;
  int _streakDays = 5;
  int _coinsToday = 0;
  bool _isLoading = true;

  Map<String, dynamic>? _wallet;
  List<dynamic> _challenges = [];
  List<dynamic> _vouchers = [];
  List<dynamic> _transactions = [];

  late AnimationController _coinController;
  late Animation<double> _coinAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _coinController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _coinAnim = CurvedAnimation(parent: _coinController, curve: Curves.elasticOut);
    _coinController.forward();
    _fetchData();
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final wallet = await ApiService.getUserWallet();
      final challenges = await ApiService.getChallenges();
      final vouchers = await ApiService.getUserVouchers();
      final transactions = await ApiService.getCoinTransactions();

      setState(() {
        _wallet = wallet;
        _totalCoins = wallet != null ? (wallet['currentCoins'] ?? 0) : 0;
        _challenges = challenges;
        _vouchers = vouchers;
        _transactions = transactions;

        // Calculate coins earned today
        _coinsToday = 0;
        final now = DateTime.now();
        for (var txn in transactions) {
          if (txn['type'] == 'earn' && txn['createdAt'] != null) {
            try {
              final date = DateTime.parse(txn['createdAt']).toLocal();
              if (date.year == now.year && date.month == now.month && date.day == now.day) {
                _coinsToday += (txn['coins'] as num).toInt();
              }
            } catch (_) {}
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showCoinPopup(int coins) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _CoinPopup(coins: coins),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  Future<void> _claimReward(String challengeId, String title, int rewardCoins) async {
    setState(() => _isLoading = true);
    final res = await ApiService.claimChallengeReward(challengeId);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _coinController.reset();
      _coinController.forward();
      _showCoinPopup(rewardCoins);
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Failed to claim reward'),
        backgroundColor: kOrange,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _redeemVoucher(int coins, int amount) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kWhite,
        title: const Text('Confirm Redemption', style: TextStyle(fontWeight: FontWeight.w900, color: kDark)),
        content: Text('Are you sure you want to redeem $coins coins for a $amount% discount voucher?', style: const TextStyle(color: kDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kGrey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kYellow, foregroundColor: kDark, elevation: 0),
            child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final res = await ApiService.redeemCoinsForVoucher(coins);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      final code = res['voucher']?['voucherCode'] ?? '';
      showDialog(
        context: context,
        builder: (_) => _VoucherRedeemedDialog(code: code, amount: amount),
      );
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Failed to redeem voucher'),
        backgroundColor: kOrange,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusH = MediaQuery.of(context).padding.top;
    
    // Filter challenges based on Tab
    final weeklyChallenges = _challenges.where((c) => c['type'] == 'Weekly').toList();
    final monthlyChallenges = _challenges.where((c) => c['type'] == 'Monthly').toList();

    return Scaffold(
      backgroundColor: kBgYellow,
      body: Column(
        children: [
          _buildHeader(statusH),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kYellowDark)))
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    color: kYellowDark,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildTabBar(),
                          if (_tabIndex == 0) _buildWeeklyTab(weeklyChallenges),
                          if (_tabIndex == 1) _buildMonthlyTab(monthlyChallenges),
                          if (_tabIndex == 2) _buildCoinsTab(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double statusH) {
    return Container(
      decoration: const BoxDecoration(
        color: kYellow,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: statusH + 12, left: 20, right: 20, bottom: 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: kDark),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Rewards & Challenges',
                    style: TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              ScaleTransition(
                scale: _coinAnim,
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: kYellowDark.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          _totalCoins.toString(),
                          style: const TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatChip('🔥 $_streakDays day streak', kOrange, const Color(0xFFFFF3ED)),
              const SizedBox(width: 8),
              _buildStatChip('⭐ +$_coinsToday today', kYellowDark, kWhite),
              const SizedBox(width: 8),
              _buildStatChip('🏆 Ecosystem Reward', kGreen, kGreenLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Weekly Challenges', 'Monthly Challenges', 'Coin Wallet'];
    return Container(
      color: kBgYellow,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kYellowDark.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final bool active = _tabIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tabIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: active ? kYellow : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: active ? kDark : kGrey,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWeeklyTab(List<dynamic> challenges) {
    if (challenges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No weekly challenges active right now.', style: TextStyle(color: kGrey, fontWeight: FontWeight.w600)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          ...challenges.map((challenge) => _buildChallengeCard(challenge)),
          const SizedBox(height: 12),
          _buildDailyStreakCard(),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(List<dynamic> challenges) {
    if (challenges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No monthly challenges active right now.', style: TextStyle(color: kGrey, fontWeight: FontWeight.w600)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          ...challenges.map((challenge) => _buildChallengeCard(challenge)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(dynamic ch) {
    final String id = ch['_id'] ?? '';
    final String title = ch['title'] ?? '';
    final String activityType = ch['activityType'] ?? 'walk';
    final double target = (ch['target'] as num?)?.toDouble() ?? 10.0;
    final int rewardCoins = (ch['rewardCoins'] as num?)?.toInt() ?? 100;
    final double progress = (ch['userProgress'] as num?)?.toDouble() ?? 0.0;
    final String status = ch['userStatus'] ?? 'active';

    final bool isCompleted = status == 'completed';
    final bool isClaimed = status == 'claimed';
    final double pct = (progress / target).clamp(0.0, 1.0);

    IconData iconData = Icons.directions_walk_rounded;
    Color iconColor = const Color(0xFF09ACD0);
    String unit = 'km';

    if (activityType == 'run') {
      iconData = Icons.directions_run_rounded;
      iconColor = kOrange;
    } else if (activityType == 'cycling') {
      iconData = Icons.directions_bike_rounded;
      iconColor = const Color(0xFF07F178);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClaimed ? kGreenLight.withOpacity(0.6) : kWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isClaimed ? kGreen.withOpacity(0.3) : kYellow.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: kYellowDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isClaimed ? kGreen.withOpacity(0.2) : iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: isClaimed
                ? const Icon(Icons.check_circle_rounded, color: kGreen, size: 28)
                : Icon(iconData, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isClaimed ? kGreen : kDark,
                    decoration: isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isClaimed) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: kYellowLight,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} $unit (${(pct * 100).toInt()}%)',
                    style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w700),
                  ),
                ] else
                  const Text(
                    'Claimed! 🎉 coins added to wallet',
                    style: TextStyle(fontSize: 11, color: kGreen, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 2),
                  Text(
                    '+$rewardCoins',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: kYellowDark),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (isClaimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Claimed', style: TextStyle(color: kGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else if (isCompleted)
                ElevatedButton(
                  onPressed: () => _claimReward(id, title, rewardCoins),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: kWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Claim ✓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(
                          challengeId: id,
                          title: title,
                          activityType: activityType,
                          target: target,
                          rewardCoins: rewardCoins,
                          currentProgress: progress,
                        ),
                      ),
                    );
                    _fetchData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kYellow,
                    foregroundColor: kDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Start', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kYellow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kYellowDark.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_streakDays Day Streak!',
                    style: const TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  'Complete weekly activities to multiply rewards!',
                  style: TextStyle(color: kDark.withOpacity(0.65), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('+100', style: TextStyle(color: kYellow, fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          _buildCoinBalanceCard(),
          const SizedBox(height: 16),
          _buildVoucherRedemptionSection(),
          const SizedBox(height: 16),
          _buildActiveVouchersSection(),
          const SizedBox(height: 16),
          _buildTransactionListSection(),
        ],
      ),
    );
  }

  Widget _buildCoinBalanceCard() {
    final lifetime = _wallet != null ? (_wallet!['lifetimeCoins'] ?? 0) : 0;
    final redeemed = _wallet != null ? (_wallet!['redeemedCoins'] ?? 0) : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            _totalCoins.toString(),
            style: const TextStyle(color: kYellow, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const Text('Current Coin Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniStat('Today', '+$_coinsToday'),
                Container(width: 1, height: 30, color: kWhite.withOpacity(0.15)),
                _buildMiniStat('Lifetime', '+$lifetime'),
                Container(width: 1, height: 30, color: kWhite.withOpacity(0.15)),
                _buildMiniStat('Redeemed', '-$redeemed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: kYellow, fontWeight: FontWeight.w900, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildVoucherRedemptionSection() {
    final redemptionOptions = [
      {'coins': 500, 'amount': 5},
      {'coins': 1000, 'amount': 10},
      {'coins': 2000, 'amount': 15},
      {'coins': 5000, 'amount': 25},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kYellowDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Redeem Coins for Vouchers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchRewardsPage()));
                },
                icon: const Icon(Icons.style_rounded, size: 16, color: kYellowDark),
                label: const Text('Scratch Cards', style: TextStyle(color: kYellowDark, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: redemptionOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (_, index) {
              final opt = redemptionOptions[index];
              final int coins = opt['coins']!;
              final int amount = opt['amount']!;
              final bool canRedeem = _totalCoins >= coins;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBgYellow.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: canRedeem ? kYellow : kGrey.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$amount% Off Voucher', style: const TextStyle(fontWeight: FontWeight.w900, color: kDark, fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text('$coins coins', style: const TextStyle(fontSize: 11, color: kGrey, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: canRedeem ? () => _redeemVoucher(coins, amount) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kYellow,
                        foregroundColor: kDark,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 28),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Redeem', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveVouchersSection() {
    final activeVouchers = _vouchers.where((v) => v['status'] == 'active').toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kYellowDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Active Vouchers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
          const SizedBox(height: 12),
          if (activeVouchers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No active vouchers found. Redeem some coins!', style: TextStyle(color: kGrey, fontSize: 12)),
              ),
            )
          else
            ...activeVouchers.map((v) {
              final String code = v['voucherCode'] ?? '';
              final int amount = (v['amount'] as num?)?.toInt() ?? 0;
              final bool isPercent = v['isPercentage'] == true || amount <= 25;
              final String displayValue = isPercent ? '$amount% Off' : '₹$amount';
              
              String expiryText = 'Active';
              if (v['expiryDate'] != null) {
                try {
                  final exp = DateTime.parse(v['expiryDate']).toLocal();
                  expiryText = 'Expires: ${exp.day}/${exp.month}/${exp.year}';
                } catch (_) {}
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
                      child: const Icon(Icons.local_offer_rounded, color: kGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$displayValue Druxx Voucher', style: const TextStyle(fontWeight: FontWeight.w800, color: kDark)),
                          const SizedBox(height: 2),
                          Text(code, style: const TextStyle(fontWeight: FontWeight.bold, color: kYellowDark, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(expiryText, style: const TextStyle(color: kGrey, fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: kYellowDark),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Voucher code copied to clipboard!'),
                          backgroundColor: kGreen,
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTransactionListSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kYellowDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Coin Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
          const SizedBox(height: 12),
          if (_transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No transaction history found.', style: TextStyle(color: kGrey, fontSize: 12)),
              ),
            )
          else
            ..._transactions.take(10).map((txn) {
              final String desc = txn['description'] ?? 'Activity completion';
              final int coins = (txn['coins'] as num?)?.toInt() ?? 0;
              final bool isEarn = txn['type'] == 'earn';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isEarn ? kYellowLight : const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(isEarn ? '🪙' : '🎁', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kDark)),
                    ),
                    Text(
                      '${isEarn ? '+' : '-'}$coins',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isEarn ? kYellowDark : kOrange,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  final String challengeId;
  final String title;
  final String activityType;
  final double target;
  final int rewardCoins;
  final double currentProgress;

  const TaskDetailScreen({
    super.key,
    required this.challengeId,
    required this.title,
    required this.activityType,
    required this.target,
    required this.rewardCoins,
    required this.currentProgress,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with TickerProviderStateMixin {
  bool _isRunning = false;
  bool _isPaused  = false;
  late Timer _timer;
  int _elapsedSeconds = 0;
  double _currentValue = 0.0;
  double _speed = 0.0;

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;

  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentProgress;
    _ringController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final initialPct = _currentValue / widget.target;
    _ringController.value = initialPct.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
      _positionStreamSubscription?.cancel();
    }
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleTimer() async {
    if (!_isRunning) {
      // Check location permission
      bool hasPermission = await LocationService.requestPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permission is required to track your physical movement.'),
            backgroundColor: kOrange,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      setState(() {
        _isRunning = true;
        _isPaused = false;
        _lastPosition = null;
      });

      // 1. Start real GPS tracking stream on mobile, fallback to simulation if on web
      if (!kIsWeb) {
        _positionStreamSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 3, // Trigger every 3 meters
          ),
        ).listen((Position position) {
          if (!mounted || !_isRunning) return;

          setState(() {
            if (_lastPosition != null) {
              double meters = Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                position.latitude,
                position.longitude,
              );

              // Filter out sensor noise / huge gps jumps
              if (meters > 0.5 && meters < 100) {
                double km = meters / 1000.0;
                _currentValue = min(_currentValue + km, widget.target);
              }
            }
            
            _lastPosition = position;
            
            // Calculate speed in km/h (position.speed is in m/s)
            double gpsSpeed = position.speed * 3.6;
            if (gpsSpeed > 0.5) {
              _speed = gpsSpeed;
            } else {
              _speed = 0.0;
            }

            final double newPct = _currentValue / widget.target;
            _ringController.animateTo(newPct, duration: const Duration(milliseconds: 500));

            if (_currentValue >= widget.target) {
              _stopTracking();
              Future.delayed(const Duration(milliseconds: 500), _onComplete);
            }
          });
        }, onError: (err) {
          debugPrint('GPS Stream error: $err');
        });
      }

      // 2. Start time elapsed timer
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_isRunning) return;
        setState(() {
          _elapsedSeconds++;
          
          // Fallback simulation (web only)
          if (kIsWeb) {
            final double increment = (Random().nextDouble() * 0.15 + 0.05);
            _currentValue = min(_currentValue + increment, widget.target);
            _speed = widget.activityType == 'walk'
                ? (Random().nextDouble() * 0.5 + 4.5)
                : (Random().nextDouble() * 1.5 + 8.5);

            final double newPct = _currentValue / widget.target;
            _ringController.animateTo(newPct, duration: const Duration(milliseconds: 500));

            if (_currentValue >= widget.target) {
              _stopTracking();
              Future.delayed(const Duration(milliseconds: 500), _onComplete);
            }
          }
        });
      });
    } else {
      _stopTracking();
    }
  }

  void _stopTracking() {
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    _timer.cancel();
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _lastPosition = null;
  }

  void _fastComplete() {
    _stopTracking();
    setState(() {
      _currentValue = widget.target;
      _isRunning = false;
      _isPaused = false;
    });
    _ringController.animateTo(1.0, duration: const Duration(milliseconds: 300));
    Future.delayed(const Duration(milliseconds: 500), _onComplete);
  }

  Future<void> _onComplete() async {
    // Send progress to backend
    await ApiService.updateChallengeProgress(widget.challengeId, widget.target);
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _CompletionSheet(title: widget.title, rewardCoins: widget.rewardCoins),
      ).then((_) => Navigator.pop(context));
    }
  }

  String get _elapsedFormatted {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double pct = _currentValue / widget.target;
    final double statusH = MediaQuery.of(context).padding.top;

    IconData iconData = Icons.directions_walk_rounded;
    Color iconColor = const Color(0xFF09ACD0);
    if (widget.activityType == 'run') {
      iconData = Icons.directions_run_rounded;
      iconColor = kOrange;
    } else if (widget.activityType == 'cycling') {
      iconData = Icons.directions_bike_rounded;
      iconColor = const Color(0xFF07F178);
    }

    return Scaffold(
      backgroundColor: kBgYellow,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: kYellow,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(top: statusH + 10, left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: kDark.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_rounded, color: kDark, size: 20),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildRing(pct, iconData, iconColor),
                    const SizedBox(height: 24),
                    _buildStats(iconColor),
                    const SizedBox(height: 24),
                    _buildStartButton(),
                    const SizedBox(height: 12),
                    _buildFastCompleteButton(),
                    const SizedBox(height: 20),
                    _buildRewardPreview(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double pct, IconData iconData, Color color) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _ringController,
                builder: (_, __) => CustomPaint(
                  painter: _RingPainter(progress: _ringController.value, color: color),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: color, size: 32),
                const SizedBox(height: 6),
                Text(
                  _currentValue.toStringAsFixed(1),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: color),
                ),
                const Text('km', style: TextStyle(fontSize: 13, color: kGrey, fontWeight: FontWeight.w600)),
                Text('/ ${widget.target.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 11, color: kGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(icon: Icons.timer_rounded, label: 'Time', value: _elapsedFormatted, color: kDark),
        _StatChip(icon: Icons.speed_rounded, label: 'Speed', value: _isRunning ? '${_speed.toStringAsFixed(1)} km/h' : '—', color: color),
        _StatChip(icon: Icons.local_fire_department_rounded, label: 'Calories', value: _isRunning ? '${(_elapsedSeconds * 0.12).toInt()} kcal' : '—', color: kOrange),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _toggleTimer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: _isRunning ? kOrange : kYellow,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (_isRunning ? kOrange : kYellowDark).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: kDark, size: 28),
            const SizedBox(width: 10),
            Text(
              _isRunning ? 'PAUSE SIMULATOR' : _isPaused ? 'RESUME SIMULATOR' : 'START SIMULATOR',
              style: const TextStyle(color: kDark, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastCompleteButton() {
    return OutlinedButton.icon(
      onPressed: _fastComplete,
      style: OutlinedButton.styleFrom(
        foregroundColor: kYellowDark,
        side: const BorderSide(color: kYellow, width: 2),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.flash_on_rounded),
      label: const Text('FAST COMPLETE (DEMO)', style: TextStyle(fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildRewardPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kYellowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kYellow, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            'Complete to earn ${widget.rewardCoins} coins',
            style: const TextStyle(color: kYellowDark, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final trackPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kYellowDark.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: kGrey)),
        ],
      ),
    );
  }
}

class _CoinPopup extends StatelessWidget {
  final int coins;
  const _CoinPopup({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: kYellow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kYellowDark.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text('Challenge Completed!', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w900, decoration: TextDecoration.none)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 24, decoration: TextDecoration.none)),
                const SizedBox(width: 6),
                Text('+$coins coins', style: const TextStyle(color: kDark, fontSize: 22, fontWeight: FontWeight.w900, decoration: TextDecoration.none)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionSheet extends StatelessWidget {
  final String title;
  final int rewardCoins;
  const _CompletionSheet({required this.title, required this.rewardCoins});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: kYellowLight, shape: BoxShape.circle),
            child: const Center(child: Text('🏆', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 16),
          Text('$title Complete!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
          const SizedBox(height: 8),
          Text(
            'You are now eligible to claim $rewardCoins coins!',
            style: const TextStyle(fontSize: 14, color: kGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kYellow,
                foregroundColor: kDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Awesome! 🎉', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _VoucherRedeemedDialog extends StatelessWidget {
  final String code;
  final int amount;

  const _VoucherRedeemedDialog({required this.code, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: kYellow, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            const Text('Voucher Redeemed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
            const SizedBox(height: 6),
            Text('You got a $amount% discount voucher.', style: const TextStyle(color: kGrey, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kBgYellow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kYellow, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SelectableText(
                      code,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kYellowDark, letterSpacing: 1.1),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: kYellowDark),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Voucher code copied to clipboard!'),
                        backgroundColor: kGreen,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Use this code on your next product purchase or booking to get a discount.', style: TextStyle(color: kGrey, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kYellow,
                  foregroundColor: kDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}