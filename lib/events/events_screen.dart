import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../webview_screen.dart';

// Imports for navigation:
import '../home screens/home2_screen.dart';
import '../home screens/services_page.dart';
import '../profile_settings_pages/profile_screen.dart';

const kYellow = Color(0xFFF9C413);
const kYellowBg = Color(0xFFFFF8E7);
const kWhite = Color(0xFFFFFFFF);
const kDark = Color(0xFF0D0D0D);

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Completed
  List<dynamic> _upcomingEvents = [];
  List<dynamic> _completedEvents = [];
  bool _isLoading = true;

  // Active filters applied to queries
  DateTime? _selectedDate;
  String? _selectedMonth;
  String? _selectedYear;
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 2000);

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = ['2025', '2026', '2027'];
  final List<String> _categories = ['All', 'Fitness', 'Marathon', 'Kids Events'];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // Build the query parameter map
    final Map<String, String> filters = {};
    if (_selectedDate != null) {
      final y = _selectedDate!.year.toString();
      final m = _selectedDate!.month.toString().padLeft(2, '0');
      final d = _selectedDate!.day.toString().padLeft(2, '0');
      filters['date'] = "$y-$m-$d";
    }
    if (_selectedMonth != null) {
      final index = _months.indexOf(_selectedMonth!) + 1;
      filters['month'] = index.toString();
    }
    if (_selectedYear != null) {
      filters['year'] = _selectedYear!;
    }
    if (_selectedCategory != null && _selectedCategory != 'All') {
      filters['category'] = _selectedCategory!;
    }
    filters['minPrice'] = _priceRange.start.round().toString();
    filters['maxPrice'] = _priceRange.end.round().toString();

    final upcoming = await ApiService.getUpcomingEvents(filters);
    final completed = await ApiService.getCompletedEvents(filters);

    if (mounted) {
      setState(() {
        _upcomingEvents = upcoming;
        _completedEvents = completed;
        _isLoading = false;
      });
    }
  }

  void _shareEvent(String title, String url) {
    Share.share('Join me at $title! Register here: $url');
  }

  // Modern bottom sheet filter dialog (BookMyShow/District Style)
  void _openFilterBottomSheet() {
    DateTime? tempDate = _selectedDate;
    String? tempMonth = _selectedMonth;
    String? tempYear = _selectedYear;
    String? tempCategory = _selectedCategory ?? 'All';
    RangeValues tempPriceRange = _priceRange;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Picker Selection
                    const Text(
                      'Specific Date',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: tempDate ?? DateTime.now(),
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: kYellow,
                                  onPrimary: Colors.black,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (selected != null) {
                          setModalState(() {
                            tempDate = selected;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tempDate == null
                                  ? 'Choose a Date'
                                  : "${tempDate!.day.toString().padLeft(2, '0')}-${tempDate!.month.toString().padLeft(2, '0')}-${tempDate!.year}",
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Month & Year Row Dropdowns
                    Row(
                      children: [
                        // Month Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Month',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: tempMonth,
                                    hint: const Text('Any Month'),
                                    isExpanded: true,
                                    items: _months.map((m) {
                                      return DropdownMenuItem<String>(
                                        value: m,
                                        child: Text(m),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setModalState(() {
                                        tempMonth = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Year Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Year',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: tempYear,
                                    hint: const Text('Any Year'),
                                    isExpanded: true,
                                    items: _years.map((y) {
                                      return DropdownMenuItem<String>(
                                        value: y,
                                        child: Text(y),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setModalState(() {
                                        tempYear = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Price Slider range selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price Range',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          '₹${tempPriceRange.start.round()} - ₹${tempPriceRange.end.round()}',
                          style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: tempPriceRange,
                      min: 0,
                      max: 2000,
                      divisions: 20,
                      activeColor: kYellow,
                      inactiveColor: Colors.grey[200],
                      labels: RangeLabels(
                        '₹${tempPriceRange.start.round()}',
                        '₹${tempPriceRange.end.round()}',
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          tempPriceRange = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Selector
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = tempCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: kYellow,
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : Colors.grey[700],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    tempCategory = cat;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Reset and Apply Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempDate = null;
                                tempMonth = null;
                                tempYear = null;
                                tempCategory = 'All';
                                tempPriceRange = const RangeValues(0, 2000);
                              });
                            },
                            child: const Text(
                              'Reset Filters',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = tempDate;
                                _selectedMonth = tempMonth;
                                _selectedYear = tempYear;
                                _selectedCategory = tempCategory;
                                _priceRange = tempPriceRange;
                              });
                              Navigator.pop(context);
                              _loadEvents();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kYellow,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: 110,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 110,
          height: 130,
          color: Colors.grey[200],
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      );
    } else {
      return Image.network(
        imagePath,
        width: 110,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 110,
          height: 130,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final currentEvents = _selectedTab == 0 ? _upcomingEvents : _completedEvents;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.jpeg',
              height: 36,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'MC',
                    style: TextStyle(color: kYellow, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Events',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text(
                  '100',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(width: 4),
                Icon(Icons.monetization_on, color: Colors.amber, size: 16),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Custom Tabs (Upcoming / Completed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildTabButton('Upcoming', 0),
                      const SizedBox(width: 24),
                      _buildTabButton('Completed', 1),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: (_selectedDate != null ||
                            _selectedMonth != null ||
                            _selectedYear != null ||
                            (_selectedCategory != null && _selectedCategory != 'All') ||
                            _priceRange.start > 0 ||
                            _priceRange.end < 2000)
                        ? Colors.green
                        : Colors.black,
                  ),
                  onPressed: _openFilterBottomSheet,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // Events list content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kYellow),
                    ),
                  )
                : currentEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        color: kYellow,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: currentEvents.length,
                          itemBuilder: (context, index) {
                            final ev = currentEvents[index];
                            return _buildEventCard(ev);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(bottomSafe),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 48,
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic ev) {
    final title = ev['title'] ?? '';
    final location = ev['location'] ?? '';
    final image = ev['image'] ?? '';
    final websiteUrl = ev['websiteUrl'] ?? '';
    final price = ev['price'] ?? 0;

    // Parse date fields using standard Dart formatting
    String displayDate = '';
    String displayTime = '';
    final List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    try {
      if (ev['startDate'] != null) {
        final start = DateTime.parse(ev['startDate'].toString());
        final dayStr = start.day.toString().padLeft(2, '0');
        final monthStr = monthNames[start.month - 1];
        final yearStr = start.year.toString();
        displayDate = "$dayStr $monthStr $yearStr";

        final hour = start.hour > 12 ? start.hour - 12 : (start.hour == 0 ? 12 : start.hour);
        final ampm = start.hour >= 12 ? 'PM' : 'AM';
        final minuteStr = start.minute.toString().padLeft(2, '0');
        displayTime = "${hour.toString().padLeft(2, '0')}:$minuteStr $ampm";
      }
    } catch (_) {}

    // Dynamic completion status check based on date or backend field
    final bool isCompleted = ev['isCompleted'] == true || _selectedTab == 1;

    Widget cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Poster Image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: _buildEventImage(image),
        ),
        // Event Details Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ENDED',
                          style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Date & Time Row
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      displayDate,
                      style: const TextStyle(fontSize: 10, color: Colors.black87),
                    ),
                    if (displayTime.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        displayTime,
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Location Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Price & Category Row
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      price == 0 ? 'Free' : '₹$price',
                      style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Action Row (Consistent Yellow buttons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventWebViewScreen(
                                title: title,
                                url: websiteUrl,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kYellow,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isCompleted ? 'VIEW DETAILS' : 'VIEW EVENT',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Share Button
                    GestureDetector(
                      onTap: () => _shareEvent(title, websiteUrl),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          size: 15,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // Apply muted opacity styling for completed events
    if (isCompleted) {
      cardContent = Opacity(
        opacity: 0.72,
        child: cardContent,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kYellowBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: cardContent,
    );
  }

  Widget _buildBottomNav(double bottomSafe) {
    final items = [
      {
        'icon': Icons.design_services_outlined,
        'label': 'Services',
        'onTap': () => Navigator.pushReplacement(context, _route(ServiceScreen())),
      },
      {
        'icon': Icons.calendar_today_rounded,
        'label': 'Events',
        'onTap': () {},
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'Shop',
        'onTap': () => Navigator.pushReplacement(context, _route(const Shop1Screen())),
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'onTap': () => Navigator.pushReplacement(context, _route(ProfilePage())),
      },
    ];

    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: Colors.white,
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.12),
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(items[0], false),
            _buildNavItem(items[1], true),
            const SizedBox(width: 48), // FAB spacing
            _buildNavItem(items[2], false),
            _buildNavItem(items[3], false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(Map<String, dynamic> item, bool isSelected) {
    final color = isSelected ? kYellow : const Color(0xFF7A746C);
    return InkWell(
      onTap: item['onTap'] as void Function(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item['icon'] as IconData, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              item['label'] as String,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() => GestureDetector(
        onTap: () => Navigator.pushReplacement(context, _route(const Home2Screen())),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: kYellow,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kYellow.withOpacity(0.55),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
      );

  PageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}