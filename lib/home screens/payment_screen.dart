
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mrcoach/theme_notifier.dart';


class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedServices;
  final int totalAmount;
  final String customerName;
  final String customerPhone;
  final String address;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;
  

  const PaymentScreen({
    super.key,
    required this.selectedServices,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.bookingDate,
    required this.bookingTime, 
    //required int totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; 
  bool _isLoading = false;

  static const String _merchantUpiId   = "yourname@okaxis";
  static const String _merchantName    = "MrCoach Fitness";
  

  String get _bookingDateStr {
    final d = widget.bookingDate;
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String get _bookingTimeStr {
    final t = widget.bookingTime;
    final hour   = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }
  Uri _upiUri({String? customSchema}) {
    final base = customSchema ?? "upi";
    final params = {
      "pa": _merchantUpiId,
      "pn": _merchantName,
      "tn": "MrCoach Booking - ${widget.selectedServices.map((s) => s["title"]).join(", ")}",
      "cu": "INR",
    };
    return Uri(
      scheme: base,
      host:   "pay",
      queryParameters: params,
    );
  }

  Future<void> _launchGPay() async {
    final gpayUri = _upiUri(customSchema: "gpay");
    final upiUri  = _upiUri();

    try {
      if (await canLaunchUrl(gpayUri)) {
        await launchUrl(gpayUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      } else {
        _showNotInstalledDialog("Google Pay");
      }
    } catch (_) {
      _showNotInstalledDialog("Google Pay");
    }
  }
  Future<void> _launchPhonePe() async {
    final uri = _upiUri(customSchema: "phonepe");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(_upiUri(), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _showNotInstalledDialog("PhonePe");
    }
  }

  Future<void> _launchPaytm() async {
    final uri = _upiUri(customSchema: "paytmmp");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(_upiUri(), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _showNotInstalledDialog("Paytm");
    }
  }

  Future<void> _launchUPI() async {
    final uri = _upiUri();
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showError("Could not open UPI. Please try another method.");
    }
  }

  void _confirmCash() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cash Payment"),
        content: Text(
          "You have selected Cash on Delivery.\n\n"
          "Please keep exact change ready for your trainer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _onPaymentSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 187, 0),
              foregroundColor: Colors.black,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showNotInstalledDialog(String appName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("$appName not found"),
        content: Text(
          "$appName is not installed on your device. "
          "Please install it or choose another payment method.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor:  Color.fromARGB(255, 255, 187, 0),
              foregroundColor: Colors.black,
            ),
            child:  Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[400]),
    );
  }

  void _pay() {
    switch (_selectedMethod) {
      case 0: _launchGPay();    break;
      case 1: _launchPhonePe(); break;
      case 2: _launchPaytm();   break;
      case 3: _launchUPI();     break;
      case 4: _confirmCash();   break;
    }
  }

  void _onPaymentSuccess() {
    Navigator.popUntil(context, (r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text("🎉 Booking confirmed! See you soon."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF8FAFB),
      appBar: AppBar(
        title:  Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme:  IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
             SizedBox(height: 20),

            
             Text(
              "Choose Payment Method",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),

            _PaymentOption(
              index:    0,
              selected: _selectedMethod,
              label:    "Google Pay",
              subtitle: "Pay instantly via GPay",
              assetPath:   null,
              iconWidget: _gpayIcon(),
              onTap: () => setState(() => _selectedMethod = 0),
            ),
            _PaymentOption(
              index:    1,
              selected: _selectedMethod,
              label:    "PhonePe",
              subtitle: "Pay via PhonePe UPI",
              iconWidget: _phonepeIcon(),
              onTap: () => setState(() => _selectedMethod = 1),
            ),
            _PaymentOption(
              index:    2,
              selected: _selectedMethod,
              label:    "Paytm",
              subtitle: "Pay via Paytm wallet / UPI",
              iconWidget: _paytmIcon(),
              onTap: () => setState(() => _selectedMethod = 2),
            ),
            _PaymentOption(
              index:    3,
              selected: _selectedMethod,
              label:    "Other UPI",
              subtitle: "BHIM, any bank UPI app",
              iconWidget: _upiIcon(),
              onTap: () => setState(() => _selectedMethod = 3),
            ),
            _PaymentOption(
              index:    4,
              selected: _selectedMethod,
              label:    "Cash",
              subtitle: "Pay to trainer at session",
              iconWidget: const Icon(Icons.money, color: Colors.green, size: 32),
              onTap: () => setState(() => _selectedMethod = 4),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _pay,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 255, 187, 0),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                     : 
                     Text('')
                    //     _selectedMethod == 4
                    //         ? "Confirm Cash Booking  •  ₹${widget.totalAmount}"
                    //         : "Pay  ₹${widget.totalAmount}",
                    //     style: const TextStyle(
                    //         fontSize: 16, fontWeight: FontWeight.bold),
                    //   ),
              ),
            ),

            const SizedBox(height: 12),    
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  "Secured by UPI / 256-bit encryption",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booking Summary",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 12),

         
          ...widget.selectedServices.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(s["title"] as String,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Text("₹${s["price"]}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),

          const Divider(height: 20),

          
          _SummaryRow(icon: Icons.person_outline,     value: widget.customerName),
          _SummaryRow(icon: Icons.phone_outlined,     value: widget.customerPhone),
          _SummaryRow(icon: Icons.location_on_outlined, value: widget.address),
          _SummaryRow(
              icon:  Icons.calendar_today_outlined,
              value: "$_bookingDateStr  •  $_bookingTimeStr"),

          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              // Text(
              //   "₹${widget.totalAmount}",
              //   style: const TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 20,
              //       color: Color(0xFF1A1A2E)),
              // ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _gpayIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE8F0FE),
      ),
      child: const Center(
        child: Text("G", style: TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }

  Widget _phonepeIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFEDE7F6),
      ),
      child: const Center(
        child: Text("₱", style: TextStyle(color: Color(0xFF5C2D91), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _paytmIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE3F2FD),
      ),
      child: const Center(
        child: Text("P", style: TextStyle(color: Color(0xFF0052C2), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }

  Widget _upiIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE8F5E9),
      ),
      child: const Center(
        child: Text("UPI", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }
}
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _SummaryRow({required this.icon, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
class _PaymentOption extends StatelessWidget {
  final int index;
  final int selected;
  final String label;
  final String subtitle;
  final Widget iconWidget;
  final String? assetPath;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.index,
    required this.selected,
    required this.label,
    required this.subtitle,
    required this.iconWidget,
    this.assetPath,
    required this.onTap,
  });

  bool get _isSelected => index == selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isSelected ? const Color(0xFFFFF8E1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isSelected
                ? const Color.fromARGB(255, 255, 187, 0)
                : const Color(0xFFE0E0E0),
            width: _isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset:  Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            iconWidget,
             SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: _isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                          color:  Color(0xFF1A1A2E))),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            if (_isSelected)
               Icon(Icons.check_circle,
                  color: Color.fromARGB(255, 200, 145, 0), size: 22)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }
}