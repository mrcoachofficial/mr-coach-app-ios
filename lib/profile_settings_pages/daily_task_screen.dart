import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
const Color kBgYellow    = Color(0xFFFFFDE7); // very light yellow bg

enum TaskType   { walk, run, steps, timed, cycling }
enum TaskStatus { locked, available, inProgress, completed }

class DailyTask {
  final String id;
  final String title;
  final String subtitle;
  final TaskType type;
  final double targetValue;
  final String unit;
  final int coinReward;
  final int bonusCoins;
  TaskStatus status;
  double progress;
  double currentValue;

  DailyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.targetValue,
    required this.unit,
    required this.coinReward,
    this.bonusCoins = 0,
    this.status = TaskStatus.available,
    this.progress = 0.0,
    this.currentValue = 0.0,
  });

  IconData get icon {
    switch (type) {
      case TaskType.walk:  return Icons.directions_walk_rounded;
      case TaskType.run:   return Icons.directions_run_rounded;
      case TaskType.steps: return Icons.show_chart_rounded;
      case TaskType.timed: return Icons.timer_rounded;
      case TaskType.cycling: return Icons.directions_bike_rounded;
    }
  }

  Color get color {
    switch (type) {
      case TaskType.walk:  return const Color.fromARGB(255, 9, 172, 208);
      case TaskType.run:   return kOrange;
      case TaskType.steps: return const Color(0xFF7C4DFF);
      case TaskType.timed: return const Color(0xFF00BCD4);
      case TaskType.cycling: return const Color.fromARGB(255, 7, 241, 120);
    }
  }
}

class WeekDay {
  final String day;
  final bool completed;
  final int coinsEarned;
  const WeekDay({required this.day, required this.completed, this.coinsEarned = 0});
}

class CoinTransaction {
  final String title;
  final int amount;
  final bool isEarned;
  final DateTime time;
  const CoinTransaction({
    required this.title,
    required this.amount,
    required this.isEarned,
    required this.time,
  });
}

class LeaderUser {
  final String name;
  final int coins;
  final int rank;
  final String avatar; 
  final bool isYou;
  const LeaderUser({
    required this.name,
    required this.coins,
    required this.rank,
    required this.avatar,
    this.isYou = false,
  });
}
class TasksHomeScreen extends StatefulWidget {
  const TasksHomeScreen({super.key});

  @override
  State<TasksHomeScreen> createState() => _TasksHomeScreenState();
}

class _TasksHomeScreenState extends State<TasksHomeScreen>
    with TickerProviderStateMixin {
  int _tabIndex = 0;
  int _totalCoins = 1250;
  int _streakDays = 5;
  int _coinsToday = 0;

  late AnimationController _coinController;
  late Animation<double> _coinAnim;

  final List<DailyTask> _tasks = [
    DailyTask(
      id: '1', title: 'Morning Walk', subtitle: 'Start your day right',
      type: TaskType.walk, targetValue: 2.0, unit: 'km',
      coinReward: 50, bonusCoins: 10,
    ),
    DailyTask(
      id: '2', title: 'Power Run', subtitle: 'Push your limits',
      type: TaskType.run, targetValue: 3.0, unit: 'km',
      coinReward: 100, bonusCoins: 25,
    ),
     DailyTask(
      id: '3', title: 'Cycling', subtitle: 'Push your limits',
      type: TaskType.cycling, targetValue: 5.0, unit: 'km',
      coinReward: 100, bonusCoins: 30,
    ),
    // DailyTask(
    //   id: '4', title: 'Timed Workout', subtitle: 'Stay active 30 minutes',
    //   type: TaskType.timed, targetValue: 30, unit: 'min',
    //   coinReward: 60, bonusCoins: 0,
    //   status: TaskStatus.completed, progress: 1.0, currentValue: 30,
    // ),
  ];

  final List<WeekDay> _week = const [
    WeekDay(day: 'M', completed: true,  coinsEarned: 185),
    WeekDay(day: 'T', completed: true,  coinsEarned: 210),
    WeekDay(day: 'W', completed: true,  coinsEarned: 175),
    WeekDay(day: 'T', completed: true,  coinsEarned: 200),
    WeekDay(day: 'F', completed: true,  coinsEarned: 195),
    WeekDay(day: 'S', completed: false, coinsEarned: 0),
    WeekDay(day: 'S', completed: false, coinsEarned: 0),
  ];

  final List<LeaderUser> _allLeaders = const [
    LeaderUser(name: 'Arjun',   coins: 3450, rank: 1, avatar: 'A'),
    LeaderUser(name: 'Priya',   coins: 3120, rank: 2, avatar: 'P'),
    LeaderUser(name: 'Karthik', coins: 2980, rank: 3, avatar: 'K'),
    LeaderUser(name: 'Meera',   coins: 2700, rank: 4, avatar: 'M'),
    LeaderUser(name: 'Ravi',    coins: 2540, rank: 5, avatar: 'R'),
    LeaderUser(name: 'Divya',   coins: 2310, rank: 6, avatar: 'D'),
    LeaderUser(name: 'You',     coins: 1250, rank: 7, avatar: 'Y', isYou: true),
    LeaderUser(name: 'Surya',   coins: 1100, rank: 8, avatar: 'S'),
    LeaderUser(name: 'Anitha',  coins: 980,  rank: 9, avatar: 'A'),
    LeaderUser(name: 'Vijay',   coins: 750,  rank: 10, avatar: 'V'),
  ];

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

    _coinsToday = _tasks
        .where((t) => t.status == TaskStatus.completed)
        .fold(0, (sum, t) => sum + t.coinReward);
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  void _onTaskComplete(DailyTask task) {
    setState(() {
      task.status = TaskStatus.completed;
      task.progress = 1.0;
      task.currentValue = task.targetValue;
      _totalCoins += task.coinReward + task.bonusCoins;
      _coinsToday += task.coinReward + task.bonusCoins;
    });
    _coinController..reset()..forward();
    _showCoinPopup(task.coinReward + task.bonusCoins);
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

  void _openLeaderboardFull() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullLeaderboardScreen(
          leaders: _allLeaders,
          totalCoins: _totalCoins,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((t) => t.status == TaskStatus.completed).length;
    final double statusH = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBgYellow,
      body: Column(
        children: [
          _buildHeader(statusH, completedCount),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildTabBar(),
                  if (_tabIndex == 0) _buildDailyTab(),
                  if (_tabIndex == 1) _buildWeeklyTab(),
                  if (_tabIndex == 2) _buildCoinsTab(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(double statusH, int completedCount) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 IconButton(onPressed: (){
                  Navigator.pop(context);
                 }, icon: Icon(Icons.arrow_back_ios_rounded, color: kDark)),
                  const SizedBox(height: 2),
                  const Text('Daily Challenges',
                      style: TextStyle(
                          color: kDark, fontSize: 22, fontWeight: FontWeight.w900)),
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
                          style: const TextStyle(
                              color: kDark, fontSize: 16, fontWeight: FontWeight.w900),
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
              _buildStatChip('✅ $completedCount/${_tasks.length} done', kGreen, kGreenLight),
            ],
          ),
          const SizedBox(height: 14),
          _buildOverallProgress(completedCount),
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
      child: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildOverallProgress(int completedCount) {
    final double pct = completedCount / _tasks.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Progress",
                style: TextStyle(color: kDark.withOpacity(0.7), fontSize: 12)),
            Text('${(pct * 100).round()}%',
                style: const TextStyle(
                    color: kDark, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: kDark.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(kDark),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Daily', 'Weekly', 'Coins'];
    return Container(
      color: kBgYellow,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 42,
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
                      fontSize: 13,
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

  Widget _buildDailyTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          ..._tasks.map((task) => _TaskCard(
                task: task,
                streakDays: _streakDays,
                onTap: () => _openTaskDetail(task),
                onComplete: () => _onTaskComplete(task),
              )),
          const SizedBox(height: 12),
          _buildDailyStreakCard(),
        ],
      ),
    );
  }

  void _openTaskDetail(DailyTask task) {
    if (task.status == TaskStatus.completed) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          onComplete: () => _onTaskComplete(task),
        ),
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
                    style: const TextStyle(
                        color: kDark, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  'Complete all tasks today for +100 streak bonus coins',
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
            child: const Text('+100',
                style: TextStyle(
                    color: kYellow, fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ],
      ),
    );
  }
  Widget _buildWeeklyTab() {
    final int completedDays = _week.where((d) => d.completed).length;
    final int weeklyCoins   = _week.fold(0, (s, d) => s + d.coinsEarned);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          _buildWeeklyHeader(completedDays, weeklyCoins),
          const SizedBox(height: 14),
          _buildWeekGrid(),
          const SizedBox(height: 14),
          _buildWeeklyBonus(completedDays),
          const SizedBox(height: 14),
          _buildLeaderboardMini(),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeader(int completedDays, int weeklyCoins) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kYellowDark.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('This Week',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: kDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: kYellowLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('🪙 $weeklyCoins earned',
                    style: const TextStyle(
                        color: kYellowDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completedDays / 7,
                    minHeight: 10,
                    backgroundColor: kYellowLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(kYellow),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$completedDays/7 days',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: kDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kYellowDark.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _week.map((day) {
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: day.completed ? kYellow : kYellowLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: day.completed ? kYellowDark : kYellow.withOpacity(0.5),
                    width: day.completed ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: day.completed
                      ? const Icon(Icons.check_rounded, size: 18, color: kDark)
                      : Text(day.day,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: kGrey)),
                ),
              ),
              const SizedBox(height: 4),
              Text(day.day,
                  style: TextStyle(
                      fontSize: 10,
                      color: day.completed ? kYellowDark : kGrey,
                      fontWeight: FontWeight.w600)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyBonus(int completedDays) {
    final bool canClaim = completedDays >= 7;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canClaim ? kYellow : kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kYellowDark.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canClaim ? 'Weekly Bonus Unlocked!' : 'Complete all 7 days',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800, color: kDark),
                ),
                Text(
                  canClaim
                      ? 'Claim your 500 bonus coins'
                      : '${7 - completedDays} days remaining',
                  style: TextStyle(fontSize: 12, color: kDark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: canClaim ? kDark : kYellowLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              canClaim ? 'Claim' : '+500',
              style: TextStyle(
                  color: canClaim ? kYellow : kYellowDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardMini() {
    final top3 = _allLeaders.where((l) => l.rank <= 3).toList();
    final youEntry = _allLeaders.firstWhere((l) => l.isYou);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kYellowDark.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Leaderboard',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: kDark)),
              GestureDetector(
                onTap: _openLeaderboardFull,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('See All',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kDark)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Podium (top 3) ─ 2nd | 1st | 3rd
          _buildPodium(top3),
          const SizedBox(height: 14),

          // Divider
          Divider(color: kYellowLight, thickness: 1.5),
          const SizedBox(height: 10),

          // Your rank row
          _buildYourRankRow(youEntry),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderUser> top3) {
    final rank1 = top3.firstWhere((l) => l.rank == 1);
    final rank2 = top3.firstWhere((l) => l.rank == 2);
    final rank3 = top3.firstWhere((l) => l.rank == 3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumItem(rank2, 90, '🥈', const Color(0xFFC0C0C0), const Color(0xFFF5F5F5)),
        _buildPodiumItem(rank1, 110, '🥇', kYellowDark, kYellowLight, isFirst: true),
        _buildPodiumItem(rank3, 75, '🥉', const Color(0xFFCD7F32), const Color(0xFFFFF3E0)),
      ],
    );
  }

  Widget _buildPodiumItem(
    LeaderUser user,
    double podiumHeight,
    String medal,
    Color medalColor,
    Color bgColor, {
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: TextStyle(fontSize: isFirst ? 22 : 18)),
        const SizedBox(height: 4),
        Container(
          width: isFirst ? 56 : 46,
          height: isFirst ? 56 : 46,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: medalColor, width: isFirst ? 3 : 2),
          ),
          child: Center(
            child: Text(
              user.avatar,
              style: TextStyle(
                  fontSize: isFirst ? 20 : 16,
                  fontWeight: FontWeight.w900,
                  color: medalColor),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(user.name,
            style: TextStyle(
                fontSize: isFirst ? 13 : 11,
                fontWeight: FontWeight.w800,
                color: kDark)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 2),
            Text('${user.coins}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: medalColor)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: isFirst ? 80 : 66,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: medalColor.withOpacity(0.4), width: 1.5),
          ),
          child: Center(
            child: Text(
              '#${user.rank}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: medalColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYourRankRow(LeaderUser you) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kYellowLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kYellow, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: kYellow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('#${you.rank}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: kDark)),
            ),
          ),
          const SizedBox(width: 10),
          const Text('You',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
          const Spacer(),
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text('${you.coins}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kYellowDark)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openLeaderboardFull,
            child: const Text('See All →',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kYellowDark)),
          ),
        ],
      ),
    );
  }
  Widget _buildCoinsTab() {
    final transactions = [
      CoinTransaction(
          title: 'Power Run completed',
          amount: 150,
          isEarned: true,
          time: DateTime.now().subtract(const Duration(hours: 1))),
      CoinTransaction(
          title: 'Morning Walk completed',
          amount: 70,
          isEarned: true,
          time: DateTime.now().subtract(const Duration(hours: 3))),
      CoinTransaction(
          title: 'Streak Bonus (5 days)',
          amount: 100,
          isEarned: true,
          time: DateTime.now().subtract(const Duration(hours: 5))),
      CoinTransaction(
          title: 'Redeemed – Shop discount',
          amount: 200,
          isEarned: false,
          time: DateTime.now().subtract(const Duration(days: 1))),
      CoinTransaction(
          title: 'Step Counter completed',
          amount: 100,
          isEarned: true,
          time: DateTime.now().subtract(const Duration(days: 1))),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          _buildCoinBalance(),
          const SizedBox(height: 16),
          _buildCoinActions(),
          const SizedBox(height: 16),
          _buildTransactionList(transactions),
        ],
      ),
    );
  }

  Widget _buildCoinBalance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kYellow,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kYellowDark.withOpacity(0.35),
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
            style: const TextStyle(
                color: kDark, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
          ),
          Text('Total Coins',
              style: TextStyle(color: kDark.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: kDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniStat('Today', '+$_coinsToday'),
                Container(width: 1, height: 30, color: kDark.withOpacity(0.15)),
                _buildMiniStat('This Week', '+965'),
                Container(width: 1, height: 30, color: kDark.withOpacity(0.15)),
                _buildMiniStat('All Time', '+4,580'),
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
        Text(value,
            style: const TextStyle(
                color: kDark, fontWeight: FontWeight.w900, fontSize: 15)),
        Text(label,
            style: TextStyle(color: kDark.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }

  Widget _buildCoinActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            icon: Icons.redeem_rounded,
            label: 'Redeem',
            color: kYellowDark,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionBtn(
            icon: Icons.share_rounded,
            label: 'Refer & Earn',
            color: kGreen,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionBtn(
            icon: Icons.history_rounded,
            label: 'History',
            color: kOrange,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(List<CoinTransaction> txns) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kYellowDark.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: kDark)),
          const SizedBox(height: 12),
          ...txns.map((txn) => _TxnRow(txn: txn)),
        ],
      ),
    );
  }
}

class FullLeaderboardScreen extends StatelessWidget {
  final List<LeaderUser> leaders;
  final int totalCoins;

  const FullLeaderboardScreen({
    super.key,
    required this.leaders,
    required this.totalCoins,
  });

  @override
  Widget build(BuildContext context) {
    final double statusH = MediaQuery.of(context).padding.top;
    final top3  = leaders.where((l) => l.rank <= 3).toList();
    final rest  = leaders.where((l) => l.rank > 3).toList();

    return Scaffold(
      backgroundColor: kBgYellow,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: kYellow,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
                top: statusH + 10, left: 16, right: 16, bottom: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kDark.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: kDark, size: 20),
                      ),
                    ),
                    const Expanded(
                      child: Text('Leaderboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 6),
                Text('This Week\'s Top Athletes',
                    style: TextStyle(
                        color: kDark.withOpacity(0.6), fontSize: 13)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Full Podium top 3
                    _buildFullPodium(top3),
                    const SizedBox(height: 20),

                    // Ranks 4–10
                    Container(
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: kYellowDark.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          ...rest.map((user) => _buildRankRow(user)),
                        ],
                      ),
                    ),
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

  Widget _buildFullPodium(List<LeaderUser> top3) {
    final rank1 = top3.firstWhere((l) => l.rank == 1);
    final rank2 = top3.firstWhere((l) => l.rank == 2);
    final rank3 = top3.firstWhere((l) => l.rank == 3);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kYellowDark.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text('🏆 Top 3 Champions',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: kDark)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _fullPodiumItem(rank2, 100, '🥈', const Color(0xFFC0C0C0),
                  const Color(0xFFF5F5F5)),
              _fullPodiumItem(rank1, 130, '🥇', kYellowDark, kYellowLight,
                  isFirst: true),
              _fullPodiumItem(rank3, 80, '🥉', const Color(0xFFCD7F32),
                  const Color(0xFFFFF3E0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fullPodiumItem(
    LeaderUser user,
    double podiumH,
    String medal,
    Color medalColor,
    Color bgColor, {
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: TextStyle(fontSize: isFirst ? 26 : 20)),
        const SizedBox(height: 6),
        Container(
          width: isFirst ? 64 : 52,
          height: isFirst ? 64 : 52,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: medalColor, width: isFirst ? 3 : 2),
          ),
          child: Center(
            child: Text(user.avatar,
                style: TextStyle(
                    fontSize: isFirst ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    color: medalColor)),
          ),
        ),
        const SizedBox(height: 6),
        Text(user.name,
            style: TextStyle(
                fontSize: isFirst ? 14 : 12,
                fontWeight: FontWeight.w800,
                color: kDark)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 2),
            Text('${user.coins}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: medalColor)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: isFirst ? 90 : 72,
          height: podiumH,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: medalColor.withOpacity(0.5), width: 1.5),
          ),
          child: Center(
            child: Text('#${user.rank}',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: medalColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(LeaderUser user) {
    final bool isYou = user.isYou;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isYou ? kYellowLight : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isYou
            ? Border.all(color: kYellow, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#${user.rank}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isYou ? kYellowDark : kGrey)),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isYou ? kYellow : kYellowLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(user.avatar,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isYou ? kDark : kYellowDark)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(user.name,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isYou ? kYellowDark : kDark)),
          ),
          if (isYou)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('You',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: kDark)),
            ),
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text('${user.coins}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kDark)),
        ],
      ),
    );
  }
}
class _TaskCard extends StatelessWidget {
  final DailyTask task;
  final int streakDays;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const _TaskCard({
    required this.task,
    required this.streakDays,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final bool done = task.status == TaskStatus.completed;
    return GestureDetector(
      onTap: done ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done ? kGreenLight : kWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: done ? kGreen.withOpacity(0.4) : kYellow.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: kYellowDark.withOpacity(done ? 0.05 : 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: done
                    ? kGreen.withOpacity(0.2)
                    : task.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check_circle_rounded, color: kGreen, size: 28)
                  : Icon(task.icon, color: task.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(task.title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: done ? kGreen : kDark,
                              decoration: done ? TextDecoration.lineThrough : null)),
                      const SizedBox(width: 6),
                      if (task.bonusCoins > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kYellowLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('+${task.bonusCoins} bonus',
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: kYellowDark)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(task.subtitle,
                      style: const TextStyle(fontSize: 11, color: kGrey)),
                  const SizedBox(height: 6),
                  if (!done) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.progress,
                        minHeight: 6,
                        backgroundColor: kYellowLight,
                        valueColor: AlwaysStoppedAnimation<Color>(task.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task.currentValue.toStringAsFixed(task.type == TaskType.steps ? 0 : 1)} / ${task.targetValue.toStringAsFixed(task.type == TaskType.steps ? 0 : 1)} ${task.unit}',
                      style: TextStyle(
                          fontSize: 10,
                          color: task.color,
                          fontWeight: FontWeight.w600),
                    ),
                  ] else
                    const Text('Completed! 🎉',
                        style: TextStyle(
                            fontSize: 11,
                            color: kGreen,
                            fontWeight: FontWeight.w700)),
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
                    Text('+${task.coinReward}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: kYellowDark)),
                  ],
                ),
                const SizedBox(height: 4),
                if (!done)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Start',
                        style: TextStyle(
                            color: kDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Done ✓',
                        style: TextStyle(
                            color: kWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class TaskDetailScreen extends StatefulWidget {
  final DailyTask task;
  final VoidCallback onComplete;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with TickerProviderStateMixin {
  bool _isRunning = false;
  bool _isPaused  = false;
  late Timer _timer;
  int    _elapsedSeconds = 0;
  double _currentValue   = 0.0;
  double _speed          = 0.0;

  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (!_isRunning) {
      setState(() { _isRunning = true; _isPaused = false; });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsedSeconds++;
          final double increment = widget.task.type == TaskType.steps
              ? (Random().nextDouble() * 3 + 1)
              : widget.task.type == TaskType.timed
                  ? 1 / 60.0
                  : (Random().nextDouble() * 0.005 + 0.002);
          _currentValue = min(_currentValue + increment, widget.task.targetValue);
          _speed = widget.task.type == TaskType.walk
              ? (Random().nextDouble() * 0.5 + 3.5)
              : (Random().nextDouble() * 1.0 + 7.0);
          final double newPct = _currentValue / widget.task.targetValue;
          _ringController.animateTo(newPct,
              duration: const Duration(milliseconds: 500));
          if (_currentValue >= widget.task.targetValue) {
            _timer.cancel();
            _isRunning = false;
            Future.delayed(const Duration(milliseconds: 500), _onComplete);
          }
        });
      });
    } else {
      setState(() { _isRunning = false; _isPaused = true; });
      _timer.cancel();
    }
  }

  void _onComplete() {
    widget.onComplete();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompletionSheet(task: widget.task),
    ).then((_) => Navigator.pop(context));
  }

  String get _elapsedFormatted {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double pct     = _currentValue / widget.task.targetValue;
    final double statusH = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBgYellow,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: kYellow,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
                top: statusH + 10, left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kDark.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: kDark, size: 20),
                  ),
                ),
                Expanded(
                  child: Text(widget.task.title,
                      style: const TextStyle(
                          color: kDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center),
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
                    _buildRing(pct),
                    const SizedBox(height: 24),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildStartButton(),
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

  Widget _buildRing(double pct) {
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
                  painter: _RingPainter(
                      progress: _ringController.value,
                      color: widget.task.color),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.task.icon, color: widget.task.color, size: 32),
                const SizedBox(height: 6),
                Text(
                  widget.task.type == TaskType.steps
                      ? _currentValue.toInt().toString()
                      : _currentValue.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: widget.task.color),
                ),
                Text(widget.task.unit,
                    style: const TextStyle(
                        fontSize: 13, color: kGrey, fontWeight: FontWeight.w600)),
                Text(
                  '/ ${widget.task.type == TaskType.steps ? widget.task.targetValue.toInt() : widget.task.targetValue.toStringAsFixed(1)} ${widget.task.unit}',
                  style: const TextStyle(fontSize: 11, color: kGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(
            icon: Icons.timer_rounded,
            label: 'Time',
            value: _elapsedFormatted,
            color: kDark),
        _StatChip(
            icon: Icons.speed_rounded,
            label: 'Speed',
            value: _isRunning ? '${_speed.toStringAsFixed(1)} km/h' : '—',
            color: widget.task.color),
        _StatChip(
            icon: Icons.local_fire_department_rounded,
            label: 'Calories',
            value: _isRunning ? '${(_elapsedSeconds * 0.1).toInt()} kcal' : '—',
            color: kOrange),
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
            Icon(
              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: kDark,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              _isRunning ? 'PAUSE' : _isPaused ? 'RESUME' : 'START TASK',
              style: const TextStyle(
                  color: kDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2),
            ),
          ],
        ),
      ),
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
            'Complete to earn ${widget.task.coinReward + widget.task.bonusCoins} coins',
            style: const TextStyle(
                color: kYellowDark, fontWeight: FontWeight.w700, fontSize: 13),
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
  const _StatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: kGrey)),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  final CoinTransaction txn;
  const _TxnRow({required this.txn});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: txn.isEarned ? kYellowLight : const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(txn.isEarned ? '🪙' : '🎁',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(txn.title,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: kDark)),
          ),
          Text(
            '${txn.isEarned ? '+' : '-'}${txn.amount}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: txn.isEarned ? kYellowDark : kOrange),
          ),
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
            const Text('Task Complete!',
                style: TextStyle(
                    color: kDark, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 6),
                Text('+$coins coins',
                    style: const TextStyle(
                        color: kDark, fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionSheet extends StatelessWidget {
  final DailyTask task;
  const _CompletionSheet({required this.task});

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
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: kYellowLight, shape: BoxShape.circle),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text('${task.title} Complete!',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
          const SizedBox(height: 8),
          Text(
            'You earned ${task.coinReward + task.bonusCoins} coins',
            style: const TextStyle(fontSize: 14, color: kGrey),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Awesome! 🎉',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}